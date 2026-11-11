import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _ch = MethodChannel('khmer.windows');

const kWindowsAumid = 'MounSokdara.KhmerCalendar';
const kWindowsAppName = 'Khmer Calendar';

bool get _isWindows =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

/// Registers AppUserModelId + Start Menu shortcut so Windows toasts show the
/// correct app name/icon (works for unpackaged builds, no admin needed).
Future<bool> registerWindowsNotifyApp({
  String appName = kWindowsAppName,
  String aumid = kWindowsAumid,
  String? iconPath,
}) async {
  if (!_isWindows) return false;
  try {
    final r = await _ch.invokeMethod<bool>('registerNotifyApp', {
      'appName': appName,
      'aumid': aumid,
      if (iconPath != null && iconPath.isNotEmpty) 'iconPath': iconPath,
    });
    return r == true;
  } on MissingPluginException {
    return false;
  } catch (e) {
    debugPrint('registerWindowsNotifyApp: $e');
    return false;
  }
}

/// Runs a PowerShell script hidden without blocking the app. Returns true if
/// the PowerShell process was started.
Future<bool> runWindowsPowerShell(String script) async {
  if (!_isWindows) return false;
  if (script.trim().isEmpty) return false;
  try {
    final r = await _ch.invokeMethod<bool>('runPowerShell', {
      'script': script,
    });
    return r == true;
  } on MissingPluginException {
    return false;
  } catch (e) {
    debugPrint('runWindowsPowerShell: $e');
    return false;
  }
}

/// Example helper matching the common "custom toast app" PowerShell pattern,
/// but using HKCU (no admin) and the app's real AUMID.
Future<bool> setupWindowsToastIdentity() => registerWindowsNotifyApp();

const _toastScript = r'''
$ErrorActionPreference = 'Stop'
try {
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
  [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null
  $title = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('__TITLE__'))
  $body = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('__BODY__'))
  $aumid = '__AUMID__'
  if (-not (Test-Path "HKCU:\Software\Classes\AppUserModelId\$aumid")) {
    $aumid = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
  }
  $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
  $texts = $xml.GetElementsByTagName('text')
  $texts.Item(0).AppendChild($xml.CreateTextNode($title)) > $null
  $texts.Item(1).AppendChild($xml.CreateTextNode($body)) > $null
  $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
  [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($aumid).Show($toast)
} catch {
  try { Add-Content -Path (Join-Path $env:TEMP 'khmer_calendar_toast.log') -Value ("{0} {1}" -f (Get-Date -Format o), $_) } catch {}
}
''';

/// Shows a toast through a hidden PowerShell (works for unpackaged apps).
/// Returns true if PowerShell was started; false means the caller should fall
/// back to the plugin.
Future<bool> showWindowsToast(String title, String body) {
  String b64(String v) => base64Encode(utf8.encode(v));
  final script = _toastScript
      .replaceFirst('__TITLE__', b64(title))
      .replaceFirst('__BODY__', b64(body))
      .replaceFirst('__AUMID__', kWindowsAumid);
  return runWindowsPowerShell(script);
}
