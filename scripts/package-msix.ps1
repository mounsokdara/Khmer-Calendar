# Build an MSIX for the Microsoft Store from an existing `flutter build windows` output.
param(
  [Parameter(Mandatory = $true)][string]$IdentityName,
  [Parameter(Mandatory = $true)][string]$Publisher,
  [Parameter(Mandatory = $true)][string]$PublisherDisplayName,
  [Parameter(Mandatory = $true)][string]$OutDir
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path pubspec.yaml)) { throw "run this from the Flutter project folder (pubspec.yaml not found)" }

$ver = (Select-String -Path pubspec.yaml -Pattern '^version:\s*(\S+)').Matches[0].Groups[1].Value -replace '\+.*$', ''
if ($ver -notmatch '^\d+\.\d+\.\d+$') { throw "unexpected app version '$ver' (want x.y.z)" }
$msixVer = "$ver.0"
Write-Host "app version $ver -> msix version $msixVer"

New-Item -ItemType Directory -Force $OutDir | Out-Null
$OutDir = (Resolve-Path $OutDir).Path

flutter pub add --dev msix
if ($LASTEXITCODE -ne 0) { throw "flutter pub add msix failed" }

dart run msix:create --store --build-windows false `
  --display-name "Khmer Calendar" `
  --publisher-display-name $PublisherDisplayName `
  --identity-name $IdentityName `
  --publisher $Publisher `
  --version $msixVer `
  --logo-path assets/icons/icon-512.png `
  --capabilities "internetClient,location" `
  --output-path $OutDir --output-name KhmerCalendar
if ($LASTEXITCODE -ne 0) { throw "msix:create failed" }

$msix = Get-ChildItem $OutDir -Filter *.msix | Select-Object -First 1
if (-not $msix) { throw "no .msix produced in $OutDir" }
Write-Host ("produced {0} ({1:N1} MB)" -f $msix.Name, ($msix.Length / 1MB))
Write-Host "OK: MSIX ready for Partner Center upload"
