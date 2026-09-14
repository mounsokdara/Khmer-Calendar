import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'autostart_io.dart' if (dart.library.html) 'autostart_stub.dart' as autostart;
import 'i18n.dart';
import 'location.dart';
import 'notify_stub.dart' if (dart.library.html) 'notify_web.dart' as webnotify;
import 'reminders.dart';
import 'store.dart';

const _channel = MethodChannel('khmer.permissions');

Future<bool> _native(String method, [Map<String, dynamic>? args]) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    final r = await _channel.invokeMethod<bool>(method, args);
    return r ?? false;
  } catch (e) {
    debugPrint('native $method: $e');
    return false;
  }
}

bool get _android {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android;
}

bool get _apple {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
}

bool get _desktop {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

Future<void> _syncNativeFlags(AppStore store) async {
  await _native('setFlags', {
    'background': store.backgroundOn,
    'autoLaunch': store.autoLaunchOn,
  });
}

Future<void> _pause() async {
  await Future<void>.delayed(const Duration(milliseconds: 280));
}

Future<bool> _confirm(
  BuildContext? context,
  Lang lang,
  String titleKey,
  String bodyKey,
) async {
  final ctx = context;
  if (ctx == null || !ctx.mounted) return false;
  final ok = await showDialog<bool>(
    context: ctx,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(t(lang, titleKey)),
      content: Text(t(lang, bodyKey)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t(lang, 'cancel'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t(lang, 'ok'))),
      ],
    ),
  );
  return ok == true;
}

/// Ask the OS for notification permission. Always calls request() — never skips.
Future<bool> requestNotifications(AppStore store) async {
  var ok = false;
  try {
    if (kIsWeb) {
      ok = await webnotify.requestBrowserNotification();
    } else {
      ok = await requestOsNotificationPermission();
      PermissionStatus status = PermissionStatus.denied;
      try {
        status = await Permission.notification.request();
      } catch (e) {
        debugPrint('permission_handler notify: $e');
      }
      ok = ok || status.isGranted || status.isLimited || status.isProvisional;
    }
  } catch (e) {
    debugPrint('requestNotifications: $e');
  }
  store.setNotifyOn(ok);
  if (ok && !kIsWeb) {
    await initReminderEngine();
    await syncReminders(store);
  }
  return ok;
}

/// Keep the reminder engine alive: battery exemption, exact alarms, FGS.
Future<bool> requestBackground(AppStore store, {BuildContext? context}) async {
  if (kIsWeb) {
    await _confirm(context, store.lang, 'permBackground', 'webBgBlock');
    store.setBackgroundOn(false);
    return false;
  }
  var ok = false;
  try {
    if (_android) {
      PermissionStatus bat = PermissionStatus.denied;
      try {
        bat = await Permission.ignoreBatteryOptimizations.request();
      } catch (e) {
        debugPrint('battery handler: $e');
      }
      ok = bat.isGranted || await _native('isIgnoringBattery');
      if (!ok) {
        await _pause();
        ok = await _native('requestBatteryExemption');
      }
      try {
        await Permission.scheduleExactAlarm.request();
      } catch (_) {}
      await _pause();
      await _native('requestExactAlarm');
      final started = await _native('startKeepAlive');
      ok = started || ok || await _native('isIgnoringBattery');
    } else if (_apple) {
      await requestOsNotificationPermission();
      final appleCtx = context;
      if (appleCtx != null && appleCtx.mounted) {
        ok = await _confirm(appleCtx, store.lang, 'permBackground', 'permBackgroundSub');
      } else {
        ok = appleCtx == null;
      }
    } else {
      final deskCtx = context;
      if (deskCtx != null && deskCtx.mounted) {
        ok = await _confirm(deskCtx, store.lang, 'permBackground', 'permBackgroundSub');
      } else {
        ok = deskCtx == null;
      }
    }
  } catch (e) {
    debugPrint('requestBackground: $e');
    ok = false;
  }
  store.setBackgroundOn(ok);
  await _syncNativeFlags(store);
  if (ok) {
    await initReminderEngine();
    await syncReminders(store);
  }
  return ok;
}

Future<void> stopBackground(AppStore store) async {
  store.setBackgroundOn(false);
  await _syncNativeFlags(store);
  await _native('stopKeepAlive');
}

/// Boot / login auto-start so reminders fire after reboot.
Future<bool> requestAutoLaunch(AppStore store, {BuildContext? context}) async {
  if (kIsWeb) {
    await _confirm(context, store.lang, 'autoLaunch', 'webBgBlock');
    store.setAutoLaunchOn(false);
    return false;
  }
  var ok = false;
  try {
    if (_android) {
      store.setAutoLaunchOn(true);
      await _syncNativeFlags(store);
      await _pause();
      ok = await _native('openAutoStart');
    } else if (_desktop) {
      try {
        ok = await autostart.enableDesktopAutostart();
      } catch (e) {
        debugPrint('desktop autostart: $e');
        ok = false;
      }
      if (!ok) {
        final deskCtx = context;
        if (deskCtx != null && deskCtx.mounted) {
          ok = await _confirm(deskCtx, store.lang, 'autoLaunch', 'autoLaunchSub');
        }
      }
    } else {
      final iosCtx = context;
      if (iosCtx != null && iosCtx.mounted) {
        ok = await _confirm(iosCtx, store.lang, 'autoLaunch', 'autoLaunchSub');
      }
    }
  } catch (e) {
    debugPrint('requestAutoLaunch: $e');
    ok = false;
  }
  store.setAutoLaunchOn(ok);
  await _syncNativeFlags(store);
  return ok;
}

Future<void> stopAutoLaunch(AppStore store) async {
  store.setAutoLaunchOn(false);
  await _syncNativeFlags(store);
  if (_desktop) {
    try {
      await autostart.disableDesktopAutostart();
    } catch (_) {}
  }
}

Future<GpsResult> requestLocationPerm(AppStore store) async {
  var r = await requestNearbyCity(store);
  if (r == GpsResult.denied && _android) {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.deniedForever) {
        await _native('openAppSettings');
        r = await requestNearbyCity(store);
      }
    } catch (_) {}
  }
  store.setLocationOn(r == GpsResult.added || r == GpsResult.already);
  return r;
}

/// Continue / setup: ask every permission in order. Never skip the OS dialogs.
Future<void> requestAllPermissions(
  AppStore store, {
  BuildContext? context,
  void Function(String key)? onStep,
}) async {
  onStep?.call('askingNotify');
  try {
    await requestNotifications(store);
  } catch (e) {
    debugPrint('all/notify: $e');
  }
  await _pause();
  onStep?.call('askingBackground');
  try {
    final bgCtx = context;
    await requestBackground(store, context: bgCtx != null && bgCtx.mounted ? bgCtx : null);
  } catch (e) {
    debugPrint('all/bg: $e');
  }
  await _pause();
  onStep?.call('askingAutoLaunch');
  try {
    final autoCtx = context;
    await requestAutoLaunch(store, context: autoCtx != null && autoCtx.mounted ? autoCtx : null);
  } catch (e) {
    debugPrint('all/auto: $e');
  }
  await _pause();
  onStep?.call('askingLocation');
  try {
    await requestLocationPerm(store);
  } catch (e) {
    debugPrint('all/gps: $e');
  }
}

/// Re-apply saved flags after boot / hydrate (start FGS, reschedule reminders).
Future<void> applyStoredPermissions(AppStore store) async {
  await _syncNativeFlags(store);
  bindReminderSync(store);
  if (store.backgroundOn && !kIsWeb) {
    await _native('startKeepAlive');
  }
  if (store.notifyOn) {
    await initReminderEngine();
    await syncReminders(store);
  }
  if (store.autoLaunchOn && _desktop) {
    try {
      await autostart.enableDesktopAutostart();
    } catch (_) {}
  }
}

String permSnack(Lang lang, String kind, bool ok) {
  if (ok) {
    switch (kind) {
      case 'notify':
        return t(lang, 'notifyGranted');
      case 'background':
        return t(lang, 'bgGranted');
      case 'auto':
        return t(lang, 'autoGranted');
      default:
        return t(lang, 'permGranted');
    }
  }
  switch (kind) {
    case 'notify':
      return t(lang, 'notifyDenied');
    case 'background':
      return t(lang, 'bgDenied');
    case 'auto':
      return t(lang, 'autoDenied');
    default:
      return t(lang, 'permDenied');
  }
}

void showPermSnack(BuildContext context, Lang lang, String kind, bool ok) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(permSnack(lang, kind, ok))));
}
