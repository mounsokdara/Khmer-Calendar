# Embeds an .ico into a Windows exe (the exe's file/taskbar icon).
#
# `dart compile exe` has no icon option, so this uses the Win32 resource API
# (BeginUpdateResource / UpdateResource / EndUpdateResource), no extra tools.
#
# Dart appends the compiled program to the exe, and rewriting resources can in theory
# damage that, so the icon is written to a COPY first. The copy is run with -ProbeArgs
# and must exit with -ExpectExit, the same as the original. Only then does it replace
# the original. If anything fails the original is kept as it was (the build goes on,
# the exe just has the default icon) and a warning is printed.
param(
  [Parameter(Mandatory = $true)][string]$Exe,
  [Parameter(Mandatory = $true)][string]$Icon,
  [string[]]$ProbeArgs = @(),
  [int]$ExpectExit = 0,
  [int]$ProbeTimeoutSec = 30
)

$ErrorActionPreference = 'Stop'
$exePath = (Resolve-Path $Exe).Path
$icoPath = (Resolve-Path $Icon).Path

function Invoke-Probe([string]$path) {
  $p = Start-Process -FilePath $path -ArgumentList $ProbeArgs -PassThru -WindowStyle Hidden
  if (-not $p.WaitForExit($ProbeTimeoutSec * 1000)) {
    try { $p.Kill() } catch {}
    return -9999
  }
  return $p.ExitCode
}

try {
  Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class KcResUpdate {
  [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
  public static extern IntPtr BeginUpdateResource(string file, bool deleteExisting);
  [DllImport("kernel32.dll", SetLastError = true)]
  public static extern bool UpdateResource(IntPtr h, IntPtr type, IntPtr name, ushort lang, byte[] data, uint cb);
  [DllImport("kernel32.dll", SetLastError = true)]
  public static extern bool EndUpdateResource(IntPtr h, bool discard);
}
"@ -ErrorAction SilentlyContinue

  $before = Invoke-Probe $exePath
  if ($before -ne $ExpectExit) { throw "original exe probe returned $before, expected $ExpectExit (cannot verify an icon change)" }

  # --- read the .ico: header, entries, image data ---
  $ico = [System.IO.File]::ReadAllBytes($icoPath)
  if ([BitConverter]::ToUInt16($ico, 0) -ne 0 -or [BitConverter]::ToUInt16($ico, 2) -ne 1) { throw "$icoPath is not an .ico" }
  $count = [BitConverter]::ToUInt16($ico, 4)
  $group = New-Object System.IO.MemoryStream
  $gw = New-Object System.IO.BinaryWriter($group)
  $gw.Write([UInt16]0); $gw.Write([UInt16]1); $gw.Write([UInt16]$count)
  $images = @()
  for ($i = 0; $i -lt $count; $i++) {
    $e = 6 + 16 * $i
    $size = [BitConverter]::ToUInt32($ico, $e + 8)
    $off = [BitConverter]::ToUInt32($ico, $e + 12)
    $data = New-Object byte[] $size
    [Array]::Copy($ico, $off, $data, 0, $size)
    $images += , $data
    # GRPICONDIRENTRY = ICONDIRENTRY without the file offset, plus the resource id
    $gw.Write($ico[$e]); $gw.Write($ico[$e + 1]); $gw.Write($ico[$e + 2]); $gw.Write($ico[$e + 3])
    $gw.Write([BitConverter]::ToUInt16($ico, $e + 4)); $gw.Write([BitConverter]::ToUInt16($ico, $e + 6))
    $gw.Write([UInt32]$size); $gw.Write([UInt16]($i + 1))
  }
  $gw.Flush()
  $groupBytes = $group.ToArray()

  # --- write the resources into a copy ---
  $tmp = "$exePath.icon-tmp.exe"
  Copy-Item $exePath $tmp -Force
  $RT_ICON = [IntPtr]3; $RT_GROUP_ICON = [IntPtr]14
  $h = [KcResUpdate]::BeginUpdateResource($tmp, $false)
  if ($h -eq [IntPtr]::Zero) { throw "BeginUpdateResource failed ($([Runtime.InteropServices.Marshal]::GetLastWin32Error()))" }
  $ok = $true
  for ($i = 0; $i -lt $count -and $ok; $i++) {
    $ok = [KcResUpdate]::UpdateResource($h, $RT_ICON, [IntPtr]($i + 1), 0, $images[$i], [uint32]$images[$i].Length)
  }
  if ($ok) { $ok = [KcResUpdate]::UpdateResource($h, $RT_GROUP_ICON, [IntPtr]1, 0, $groupBytes, [uint32]$groupBytes.Length) }
  $endOk = [KcResUpdate]::EndUpdateResource($h, (-not $ok))
  if (-not ($ok -and $endOk)) { throw "UpdateResource failed ($([Runtime.InteropServices.Marshal]::GetLastWin32Error()))" }

  # --- the patched copy must still behave the same ---
  $after = Invoke-Probe $tmp
  if ($after -ne $ExpectExit) { throw "patched exe probe returned $after, expected $ExpectExit" }

  Move-Item $tmp $exePath -Force
  Write-Host "icon embedded in $exePath ($count sizes)"
} catch {
  Write-Host "::warning title=Icon not embedded::$($_.Exception.Message) ($exePath keeps the default icon)"
  if ($tmp -and (Test-Path $tmp)) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
}
