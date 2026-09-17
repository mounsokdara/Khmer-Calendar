import 'package:flutter/foundation.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';

class ReminderShot {
  const ReminderShot(this.key, this.title, this.body, this.when, {this.channel = 'tasks'});
  final String key;
  final String title;
  final String body;
  final DateTime when;
  final String channel;
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
  PublicHolidayReminder(),
  ReligiousHolidayReminder(),
  TaskReminder(),
];

String silPhaseLabel(LunarDay info, Lang lang) {
  if (lang == Lang.en) {
    final wax = info.moonStatus == 'កើត' ? 'waxing' : 'waning';
    return '${info.moonDay} $wax';
  }
  return '${info.moonDayKhmer}${info.moonStatus}';
}

String calendarDetail(DateTime day, Lang lang) {
  final info = lunarOf(day);
  final lunar = lang == Lang.en ? lunarLabel(isoOf(day), lang) : info.lunarDateText;
  final greg = lang == Lang.en ? gregorianLabel(day, lang) : info.gregorianDateText;
  return '$lunar\n$greg';
}

String dayNotifyBody(DateTime day, AppStore store) {
  final lang = store.lang;
  final iso = isoOf(day);
  final info = lunarOf(day);
  final lines = <String>[calendarDetail(day, lang)];
  if (info.isSilDay && store.notifySil) {
    lines.add('${t(lang, 'silDay')} (${silPhaseLabel(info, lang)})');
  }
  for (final h in holidaysOn(iso)) {
    final name = lang == Lang.en ? h.nameEn : h.nameKm;
    lines.add('${holidayTypeLabel(h.type, lang)}: $name');
  }
  final tasks = store.events.where((e) => e.date == iso && e.done != true).toList();
  if (tasks.isNotEmpty) {
    lines.add('${t(lang, 'tasks')}: ${tasks.map((e) => e.title).join(', ')}');
  }
  return lines.join('\n');
}

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
      ReminderShot(
        'daily-${isoOf(when)}',
        t(lang, 'notifyTodayTitle'),
        dayNotifyBody(when, store),
        when,
        channel: 'daily',
      ),
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
          final phase = silPhaseLabel(info, lang);
          out.add(
            ReminderShot(
              'sil-${isoOf(d)}',
              t(lang, 'silDay'),
              '${t(lang, 'silDay')} ($phase)\n${calendarDetail(d, lang)}',
              when,
              channel: 'sil',
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

List<ReminderShot> _holidayShots(AppStore store, DateTime now, HolidayType type, String channel) {
  final lang = store.lang;
  final out = <ReminderShot>[];
  for (final y in {now.year, now.year + 1}) {
    List<Holiday> list;
    try {
      list = holidaysOfYear(y);
    } catch (_) {
      continue;
    }
    for (final h in list) {
      if (h.type != type) continue;
      final day = fromIso(h.date);
      final when = DateTime(day.year, day.month, day.day, 8);
      if (!when.isAfter(now)) continue;
      final name = lang == Lang.en ? h.nameEn : h.nameKm;
      out.add(
        ReminderShot(
          'hol-${h.type.name}-${h.date}',
          name,
          '${holidayTypeLabel(h.type, lang)}\n${calendarDetail(day, lang)}',
          when,
          channel: channel,
        ),
      );
    }
  }
  return out;
}

class PublicHolidayReminder extends ReminderKind {
  const PublicHolidayReminder();

  @override
  bool enabled(AppStore store) => store.notifyPublic;

  @override
  bool get nativeAndroid => true;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) =>
      _holidayShots(store, now, HolidayType.public, 'public');
}

class ReligiousHolidayReminder extends ReminderKind {
  const ReligiousHolidayReminder();

  @override
  bool enabled(AppStore store) => store.notifyReligious;

  @override
  bool get nativeAndroid => true;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) =>
      _holidayShots(store, now, HolidayType.religious, 'religious');
}

class TaskReminder extends ReminderKind {
  const TaskReminder();

  @override
  bool enabled(AppStore store) => store.notifyTasks;

  @override
  List<ReminderShot> collect(AppStore store, DateTime now) {
    final lang = store.lang;
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
      final when = DateTime(day.year, day.month, day.day, hour, minute);
      final time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      final notes = (e.notes ?? '').trim();
      final lines = <String>[
        t(lang, 'notifyTaskKind'),
        calendarDetail(day, lang),
        time,
      ];
      if (notes.isNotEmpty) lines.add(notes);
      out.add(ReminderShot('task-${e.id}', e.title, lines.join('\n'), when, channel: 'tasks'));
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

List<Map<String, String>> upcomingHolidays(HolidayType type, {int years = 2}) {
  final now = DateTime.now();
  final today = isoOf(DateTime(now.year, now.month, now.day));
  final out = <Map<String, String>>[];
  final seen = <String>{};
  for (var y = now.year; y <= now.year + years; y++) {
    List<Holiday> list;
    try {
      list = holidaysOfYear(y);
    } catch (_) {
      continue;
    }
    for (final h in list) {
      if (h.type != type) continue;
      if (h.date.compareTo(today) < 0) continue;
      final key = '${h.date}-${h.nameKm}';
      if (!seen.add(key)) continue;
      out.add({'d': h.date, 'km': h.nameKm, 'en': h.nameEn});
    }
  }
  return out;
}
