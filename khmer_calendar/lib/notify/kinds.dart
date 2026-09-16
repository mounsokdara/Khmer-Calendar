import 'package:flutter/foundation.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';

class ReminderShot {
  const ReminderShot(this.key, this.title, this.body, this.when);
  final String key;
  final String title;
  final String body;
  final DateTime when;
}

abstract class ReminderKind {
  const ReminderKind();
  bool enabled(AppStore store);
  bool get nativeAndroid => false;
  List<ReminderShot> collect(AppStore store, DateTime now);
}

const reminderKinds = <ReminderKind>[
  DailyReminder(),
  SilReminder(),
  HolidayReminder(),
  EventReminder(),
  TaskReminder(),
];

class DailyReminder extends ReminderKind {
  const DailyReminder();

  @override
  bool enabled(AppStore store) => store.notifyDaily;

  @override
  bool get nativeAndroid => true;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) {
    var when = DateTime(now.year, now.month, now.day, 7);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    final lang = store.lang;
    return [
      ReminderShot('daily-${isoOf(when)}', t(lang, 'appName'), t(lang, 'remindDailySub'), when),
    ];
  }
}

class SilReminder extends ReminderKind {
  const SilReminder();

  @override
  bool enabled(AppStore store) => store.notifySil;

  @override
  bool get nativeAndroid => true;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) {
    final lang = store.lang;
    final out = <ReminderShot>[];
    var d = DateTime(now.year, now.month, now.day);
    for (var i = 0; i < 180; i++) {
      final info = lunarOf(d);
      if (info.isSilDay) {
        final when = DateTime(d.year, d.month, d.day, 7);
        if (when.isAfter(now)) {
          out.add(
            ReminderShot(
              'sil-${isoOf(d)}',
              t(lang, 'silDay'),
              lang == Lang.en ? lunarLabel(isoOf(d), lang) : info.lunarDateText,
              when,
            ),
          );
        }
      }
      d = addDays(d, 1);
      if (out.length >= 12) break;
    }
    return out;
  }
}

class HolidayReminder extends ReminderKind {
  const HolidayReminder();

  @override
  bool enabled(AppStore store) => store.notifyHolidays;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) {
    final lang = store.lang;
    final prefix = t(lang, 'reminderPrefix');
    final out = <ReminderShot>[];
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
        out.add(ReminderShot('hol-${h.date}', '$prefix: $title', t(lang, 'kindHoliday'), DateTime(day.year, day.month, day.day, 8)));
      }
    }
    return out;
  }
}

class EventReminder extends ReminderKind {
  const EventReminder();

  @override
  bool enabled(AppStore store) => store.notifyEvents;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) {
    final prefix = t(store.lang, 'reminderPrefix');
    final out = <ReminderShot>[];
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
      out.add(ReminderShot('event-${e.id}', '$prefix: ${e.title}', (e.notes ?? '').isEmpty ? e.title : e.notes!, DateTime(day.year, day.month, day.day, hour, minute)));
    }
    return out;
  }
}

class TaskReminder extends ReminderKind {
  const TaskReminder();

  @override
  bool enabled(AppStore store) => store.notifyTasks;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) {
    final prefix = t(store.lang, 'reminderPrefix');
    final out = <ReminderShot>[];
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
      out.add(ReminderShot('task-${e.id}', '$prefix: ${e.title}', (e.notes ?? '').isEmpty ? e.title : e.notes!, DateTime(day.year, day.month, day.day, hour, minute)));
    }
    return out;
  }
}

bool get androidNativeAlarms => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

List<String> upcomingSilDates({int days = 200}) {
  final out = <String>[];
  var d = DateTime.now();
  d = DateTime(d.year, d.month, d.day);
  for (var i = 0; i < days; i++) {
    if (lunarOf(d).isSilDay) out.add(isoOf(d));
    d = addDays(d, 1);
  }
  return out;
}
