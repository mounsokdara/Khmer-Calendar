import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'dates.dart';
import 'store.dart';

final _plugin = FlutterLocalNotificationsPlugin();
var _ready = false;
var _bound = false;

void bindReminderSync(AppStore store) {
  if (_bound) return;
  _bound = true;
  store.addListener(() => syncReminders(store));
}

Future<void> initReminderEngine() async {
  if (_ready) return;
  try {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    const android = AndroidInitializationSettings('ic_stat_notify');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
    );
    await _plugin.initialize(settings);
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'khmer_reminders',
        'Reminders',
        description: 'Task and holiday reminders',
        importance: Importance.high,
      ),
    );
    _ready = true;
  } catch (e) {
    debugPrint('reminders init: $e');
  }
}

/// Always call the OS notification prompt. Never skip because of a cached status.
Future<bool> requestOsNotificationPermission() async {
  if (kIsWeb) return false;
  await initReminderEngine();
  var ok = false;
  try {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final a = await android?.requestNotificationsPermission();
    if (a == true) ok = true;
  } catch (e) {
    debugPrint('android notify request: $e');
  }
  try {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final i = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    if (i == true) ok = true;
  } catch (e) {
    debugPrint('ios notify request: $e');
  }
  try {
    final mac = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    final m = await mac?.requestPermissions(alert: true, badge: true, sound: true);
    if (m == true) ok = true;
  } catch (e) {
    debugPrint('mac notify request: $e');
  }
  if (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows) {
    ok = ok || _ready;
  }
  return ok;
}

Future<void> cancelAllReminders() async {
  if (!_ready) return;
  try {
    await _plugin.cancelAll();
  } catch (_) {}
}

Future<void> syncReminders(AppStore store) async {
  if (!_ready) {
    if (store.notifyOn) await initReminderEngine();
    if (!_ready) return;
  }
  try {
    await _plugin.cancelAll();
  } catch (_) {}
  if (!store.notifyOn) return;
  var id = 1;
  final now = DateTime.now();
  for (final e in store.events) {
    if (e.done == true) continue;
    if ((e.reminderDate ?? '').isEmpty) continue;
    final day = fromIso(e.reminderDate!);
    var hour = 9;
    var minute = 0;
    final tm = e.reminderTime ?? '';
    if (tm.contains(':')) {
      final p = tm.split(':');
      hour = int.tryParse(p[0]) ?? 9;
      minute = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
    }
    final when = DateTime(day.year, day.month, day.day, hour, minute);
    if (when.isBefore(now)) continue;
    try {
      await _plugin.zonedSchedule(
        id++,
        e.title,
        e.notes?.isNotEmpty == true ? e.notes : e.title,
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'khmer_reminders',
            'Reminders',
            channelDescription: 'Task and holiday reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_stat_notify',
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: store.backgroundOn
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (err) {
      debugPrint('schedule $id: $err');
    }
  }
}
