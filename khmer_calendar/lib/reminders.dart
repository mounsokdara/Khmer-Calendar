import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'calendar/chhankitek.dart';
import 'dates.dart';
import 'i18n.dart';
import 'notify_stub.dart' if (dart.library.html) 'notify_web.dart' as webnotify;
import 'store.dart';

final _plugin = FlutterLocalNotificationsPlugin();
var _ready = false;
var _bound = false;
Timer? _syncDebounce;
Timer? _webTick;
final _fired = <String>{};
var _webShots = <_Shot>[];

class _Shot {
  const _Shot(this.key, this.title, this.body, this.when);
  final String key;
  final String title;
  final String body;
  final DateTime when;
}

const _details = NotificationDetails(
  android: AndroidNotificationDetails(
    'khmer_reminders',
    'Reminders',
    channelDescription: 'Task and holiday reminders',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_stat_notify',
  ),
  iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
  macOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
  linux: LinuxNotificationDetails(),
);

void bindReminderSync(AppStore store) {
  if (_bound) return;
  _bound = true;
  store.addListener(() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 400), () => syncReminders(store));
  });
}

Future<void> initReminderEngine() async {
  if (_ready) return;
  if (kIsWeb) {
    _ready = true;
    return;
  }
  try {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Phnom_Penh'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
    const android = AndroidInitializationSettings('ic_stat_notify');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');
    const windows = WindowsInitializationSettings(
      appName: 'Khmer Calendar',
      appUserModelId: 'MounSokdara.KhmerCalendar',
      guid: 'c4e8f1a2-9b7d-4c3e-8f16-2a91d05b6e44',
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
      windows: windows,
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

Future<bool> requestOsNotificationPermission() async {
  if (kIsWeb) return webnotify.requestBrowserNotification();
  await initReminderEngine();
  var ok = false;
  try {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final a = await android?.requestNotificationsPermission();
    if (a == true) ok = true;
    try {
      await android?.requestExactAlarmsPermission();
    } catch (_) {}
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
  if (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.windows) {
    ok = ok || _ready;
  }
  return ok;
}

Future<void> cancelAllReminders() async {
  _webTick?.cancel();
  _webTick = null;
  _webShots = [];
  if (!_ready || kIsWeb) return;
  try {
    await _plugin.cancelAll();
  } catch (_) {}
}

List<_Shot> _collect(AppStore store) {
  final now = DateTime.now();
  final lang = store.lang;
  final prefix = t(lang, 'reminderPrefix');
  final out = <_Shot>[];

  if (store.notifyTasks) {
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
      out.add(_Shot('task-${e.id}-$when', '$prefix: ${e.title}', (e.notes ?? '').isEmpty ? e.title : e.notes!, when));
    }
  }

  if (store.notifyEvents) {
    for (final e in store.events) {
      if (e.done == true) continue;
      if (e.date.isEmpty) continue;
      if (store.notifyTasks && (e.reminderDate ?? '') == e.date) continue;
      final day = fromIso(e.date);
      var hour = 9;
      var minute = 0;
      final tm = e.startTime ?? '';
      if (e.allDay != true && tm.contains(':')) {
        final p = tm.split(':');
        hour = int.tryParse(p[0]) ?? 9;
        minute = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
      }
      final when = DateTime(day.year, day.month, day.day, hour, minute);
      out.add(_Shot('event-${e.id}-$when', '$prefix: ${e.title}', (e.notes ?? '').isEmpty ? e.title : e.notes!, when));
    }
  }

  if (store.notifyHolidays) {
    for (final y in {now.year, now.year + 1}) {
      List<Holiday> list;
      try {
        list = holidaysOfYear(y);
      } catch (_) {
        continue;
      }
      for (final h in list) {
        final day = fromIso(h.date);
        final title = lang == Lang.en ? h.nameEn : h.nameKm;
        final when = DateTime(day.year, day.month, day.day, 8, 0);
        out.add(_Shot('hol-${h.date}', '$prefix: $title', t(lang, 'kindHoliday'), when));
      }
    }
  }
  return out;
}

void _fireWebDue() {
  if (!webnotify.isBrowserNotificationGranted()) return;
  final now = DateTime.now();
  for (final p in _webShots) {
    if (_fired.contains(p.key)) continue;
    final late = now.difference(p.when);
    if (late.isNegative && late.abs() > const Duration(seconds: 15)) continue;
    if (late > const Duration(minutes: 2)) continue;
    _fired.add(p.key);
    webnotify.showBrowserNotification(p.title, p.body, tag: p.key);
  }
}

void _armWeb(List<_Shot> shots) {
  _webShots = shots;
  _webTick?.cancel();
  _webTick = Timer.periodic(const Duration(seconds: 15), (_) => _fireWebDue());
  _fireWebDue();
}

Future<void> _scheduleNative(_Shot shot, int id, bool exact) async {
  if (shot.when.isBefore(DateTime.now())) return;
  final when = tz.TZDateTime.from(shot.when, tz.local);
  Future<void> run(AndroidScheduleMode mode) {
    return _plugin.zonedSchedule(id, shot.title, shot.body, when, _details, androidScheduleMode: mode);
  }

  try {
    await run(exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle);
  } catch (err) {
    debugPrint('schedule $id: $err');
    if (exact) {
      try {
        await run(AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (err2) {
        debugPrint('schedule fallback $id: $err2');
      }
    }
  }
}

Future<void> syncReminders(AppStore store) async {
  if (!_ready) {
    if (store.notifyOn) await initReminderEngine();
    if (!_ready) return;
  }
  if (!store.notifyOn) {
    await cancelAllReminders();
    return;
  }
  final shots = _collect(store);
  if (kIsWeb) {
    _armWeb(shots);
    return;
  }
  try {
    await _plugin.cancelAll();
  } catch (_) {}
  var id = 1;
  for (final shot in shots) {
    await _scheduleNative(shot, id++, store.backgroundOn);
  }
}
