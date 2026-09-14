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

class OsPerms {
  const OsPerms({
    required this.notify,
    required this.background,
    required this.autoLaunch,
    required this.location,
    this.autoStartQueryable = false,
  });

  final bool notify;
  final bool background;
  final bool autoLaunch;
  final bool location;
  final bool autoStartQueryable;
}

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

Future<Map<String, bool>> _androidStatus() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return {};
  try {
    final r = await _channel.invokeMethod<dynamic>('checkStatus');
    if (r is Map) {
      return r.map((k, v) => MapEntry('$k', v == true));
    }
  } catch (e) {
    debugPrint('checkStatus: $e');
  }
  return {};
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

Future<bool> notificationsAllowed() async {
  if (kIsWeb) return webnotify.isBrowserNotificationGranted();
  if (_android) {
    final native = (await _androidStatus())['notify'] ?? false;
    PermissionStatus status = PermissionStatus.denied;
    try {
      status = await Permission.notification.status;
    } catch (_) {}
    return native || status.isGranted || status.isLimited || status.isProvisional;
  }
  try {
    final status = await Permission.notification.status;
    return status.isGranted || status.isLimited || status.isProvisional;
  } catch (_) {
    return false;
  }
}

Future<bool> backgroundAllowed() async {
  if (kIsWeb) return false;
  if (_android) {
    final s = await _androidStatus();
    if (s['battery'] == true) return true;
    try {
      return (await Permission.ignoreBatteryOptimizations.status).isGranted;
    } catch (_) {
      return false;
    }
  }
  if (_apple) return notificationsAllowed();
  return true;
}

Future<bool> autoLaunchAllowed() async {
  if (kIsWeb) return false;
  if (_desktop) {
    try {
      return await autostart.isDesktopAutostartEnabled();
    } catch (_) {
      return false;
    }
  }
  if (_android) {
    final s = await _androidStatus();
    if (s['stock'] == true) return true;
    if (s['autoStartQueryable'] == true) return s['autoStart'] == true;
    return false;
  }
  return false;
}

Future<bool> locationAllowed() async {
  try {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  } catch (_) {
    return false;
  }
}

/// Read the OS. Never trust a local flag.
Future<OsPerms> readOsPermissions() async {
  final notify = await notificationsAllowed();
  final background = await backgroundAllowed();
  final autoLaunch = await autoLaunchAllowed();
  final location = await locationAllowed();
  var queryable = false;
  if (_android) {
    queryable = (await _androidStatus())['autoStartQueryable'] == true;
  } else if (_desktop) {
    queryable = true;
  }
  return OsPerms(
    notify: notify,
    background: background,
    autoLaunch: autoLaunch,
    location: location,
    autoStartQueryable: queryable,
  );
}

/// Turn flags off when the OS no longer allows them. Never turns flags on.
Future<void> keepOnlyGranted(AppStore store) async {
  final os = await readOsPermissions();
  if (store.notifyOn && !os.notify) store.setNotifyOn(false);
  if (store.backgroundOn && !os.background) store.setBackgroundOn(false);
  if (store.autoLaunchOn && !os.autoLaunch) store.setAutoLaunchOn(false);
  if (store.locationOn && !os.location) store.setLocationOn(false);
  await _syncNativeFlags(store);
  if (!store.backgroundOn) await _native('stopKeepAlive');
  if (!store.notifyOn) await cancelAllReminders();
}

/// After Continue asked the OS, store only what is actually allowed.
Future<void> writeGrantedFlags(AppStore store) async {
  final os = await readOsPermissions();
  store.setNotifyOn(os.notify);
  store.setBackgroundOn(os.background);
  store.setAutoLaunchOn(os.autoLaunch);
  store.setLocationOn(os.location);
  await _syncNativeFlags(store);
  if (os.background && !kIsWeb) {
    await _native('startKeepAlive');
  } else {
    await _native('stopKeepAlive');
  }
  if (os.notify) {
    await initReminderEngine();
    await syncReminders(store);
  } else {
    await cancelAllReminders();
  }
}

/// Ask the OS for notification permission, then re-read whether it is allowed.
Future<bool> requestNotifications(AppStore store) async {
  try {
    if (kIsWeb) {
      await webnotify.requestBrowserNotification();
    } else {
      await requestOsNotificationPermission();
      try {
        await Permission.notification.request();
      } catch (e) {
        debugPrint('permission_handler notify: $e');
      }
    }
  } catch (e) {
    debugPrint('requestNotifications: $e');
  }
  final ok = await notificationsAllowed();
  store.setNotifyOn(ok);
  if (ok && !kIsWeb) {
    await initReminderEngine();
    await syncReminders(store);
  } else if (!ok) {
    await cancelAllReminders();
  }
  return ok;
}

/// Ask battery / exact-alarm, then keep background on only if the OS allowed it.
Future<bool> requestBackground(AppStore store, {BuildContext? context}) async {
  if (kIsWeb) {
    store.setBackgroundOn(false);
    return false;
  }
  try {
    if (_android) {
      try {
        await Permission.ignoreBatteryOptimizations.request();
      } catch (e) {
        debugPrint('battery handler: $e');
      }
      if (!await backgroundAllowed()) {
        await _pause();
        await _native('requestBatteryExemption');
      }
      try {
        await Permission.scheduleExactAlarm.request();
      } catch (_) {}
      await _pause();
      await _native('requestExactAlarm');
    } else if (_apple) {
      await requestOsNotificationPermission();
    }
  } catch (e) {
    debugPrint('requestBackground: $e');
  }
  final ok = await backgroundAllowed();
  store.setBackgroundOn(ok);
  await _syncNativeFlags(store);
  if (ok) {
    await _native('startKeepAlive');
    await initReminderEngine();
    await syncReminders(store);
  } else {
    await _native('stopKeepAlive');
  }
  return ok;
}

Future<void> stopBackground(AppStore store) async {
  store.setBackgroundOn(false);
  await _syncNativeFlags(store);
  await _native('stopKeepAlive');
}

/// Open OEM auto-start / desktop login items, then re-read whether it is allowed.
Future<bool> requestAutoLaunch(AppStore store, {BuildContext? context}) async {
  if (kIsWeb) {
    store.setAutoLaunchOn(false);
    return false;
  }
  try {
    if (_android) {
      final s = await _androidStatus();
      if (s['stock'] != true) {
        await _pause();
        await _native('openAutoStart');
      }
      var os = await readOsPermissions();
      if (s['stock'] != true && !os.autoStartQueryable) {
        final ctx = context;
        if (ctx != null && ctx.mounted) {
          final confirmed = await _confirm(ctx, store.lang, 'autoLaunchConfirm', 'autoLaunchConfirmSub');
          store.setAutoLaunchOn(confirmed);
          await _syncNativeFlags(store);
          return confirmed;
        }
        store.setAutoLaunchOn(false);
        await _syncNativeFlags(store);
        return false;
      }
    } else if (_desktop) {
      try {
        await autostart.enableDesktopAutostart();
      } catch (e) {
        debugPrint('desktop autostart: $e');
      }
    }
  } catch (e) {
    debugPrint('requestAutoLaunch: $e');
  }
  final ok = await autoLaunchAllowed();
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
  GpsResult r = GpsResult.denied;
  try {
    r = await requestNearbyCity(store);
  } catch (e) {
    debugPrint('requestLocationPerm: $e');
  }
  final ok = await locationAllowed();
  store.setLocationOn(ok);
  if (!ok) {
    if (r != GpsResult.disabled) r = GpsResult.denied;
  }
  return r;
}

/// Continue: ask every OS prompt, then store only what the OS actually allowed.
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
  await writeGrantedFlags(store);
}

/// Re-apply saved flags after boot / hydrate, but drop any the OS no longer allows.
Future<void> applyStoredPermissions(AppStore store) async {
  await keepOnlyGranted(store);
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
