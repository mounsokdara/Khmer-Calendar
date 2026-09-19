import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/calendar/chhankitek.dart';
import 'package:khmer_calendar/dates.dart';
import 'package:khmer_calendar/i18n.dart';
import 'package:khmer_calendar/notify/kinds.dart';
import 'package:khmer_calendar/store.dart';

void main() {
  test('other holiday notify list comes from the generator, not a 24-day cap', () {
    final others = upcomingOtherHolidays();
    expect(others.length, greaterThan(24));
    expect(others.any((h) => h['en'] == 'Christmas Day'), isTrue);
    expect(others.any((h) => h['en'] == "New Year's Eve"), isTrue);
    expect(others.any((h) => h['en'] == 'Human Rights Day'), isTrue);
    expect(others.map((h) => h['d']).toSet().length, greaterThan(24));
  });

  test('public holiday notify list uses holidaysOfYear', () {
    final pubs = upcomingHolidays(HolidayType.public);
    expect(pubs, isNotEmpty);
    expect(pubs.any((h) => h['d']!.endsWith('-11-09')), isTrue);
    expect(pubs.any((h) => h['en']!.contains('Independence')), isTrue);
  });

  test('sil dates cover more than twelve days and stretch past 200 days', () {
    final sils = upcomingSilDates();
    expect(sils.length, greaterThan(12));
    final last = DateTime.parse(sils.last);
    final horizon = DateTime.now().add(const Duration(days: 400));
    expect(last.isAfter(horizon), isTrue);
  });

  test('reminder shots follow the generator lists', () {
    final store = AppStore()..lang = Lang.en;
    final now = DateTime.now();
    expect(const OtherHolidayReminder().collect(store, now).length, greaterThan(24));
    expect(const SilReminder().collect(store, now).length, greaterThan(12));
    expect(const PublicHolidayReminder().collect(store, now), isNotEmpty);
  });

  test('task without reminderDate still notifies on the event date', () {
    final day = DateTime.now().add(const Duration(days: 3));
    final store = AppStore()
      ..lang = Lang.en
      ..notifyOn = true
      ..notifyTasks = true
      ..events = [
        CalendarEvent(id: '1', title: 'Meet', date: isoOf(day), startTime: '14:30'),
      ];
    final shots = const TaskReminder().collect(store, DateTime.now());
    expect(shots, isNotEmpty);
    expect(shots.first.title, 'Meet');
    expect(shots.first.when.hour, 14);
    expect(shots.first.when.minute, 30);
    expect(isoOf(shots.first.when), isoOf(day));
  });

  test('task with reminderDate uses that date, not the event date', () {
    final eventDay = DateTime.now().add(const Duration(days: 10));
    final remindDay = DateTime.now().add(const Duration(days: 2));
    final store = AppStore()
      ..lang = Lang.en
      ..notifyOn = true
      ..notifyTasks = true
      ..events = [
        CalendarEvent(
          id: '2',
          title: 'Trip',
          date: isoOf(eventDay),
          reminderDate: isoOf(remindDay),
          reminderTime: '09:15',
        ),
      ];
    final shots = const TaskReminder().collect(store, DateTime.now());
    expect(shots.length, 1);
    expect(isoOf(shots.first.when), isoOf(remindDay));
    expect(shots.first.when.hour, 9);
    expect(shots.first.when.minute, 15);
  });

  test('date-range event notifies each day when no reminderDate is set', () {
    final start = DateTime.now().add(const Duration(days: 4));
    final end = addDays(start, 2);
    final store = AppStore()
      ..lang = Lang.en
      ..notifyOn = true
      ..notifyTasks = true
      ..events = [
        CalendarEvent(id: '3', title: 'Festival', date: isoOf(start), endDate: isoOf(end), allDay: true),
      ];
    final shots = const TaskReminder().collect(store, DateTime.now());
    expect(shots.length, 3);
    expect(shots.map((s) => isoOf(s.when)).toSet(), {isoOf(start), isoOf(addDays(start, 1)), isoOf(end)});
  });

  test('notifyItemsOf lists generator days and user events, not a daily digest', () {
    final day = DateTime.now().add(const Duration(days: 5));
    final store = AppStore()
      ..lang = Lang.en
      ..notifyOn = true
      ..notifySil = true
      ..notifyPublic = true
      ..notifyOthers = true
      ..notifyTasks = true
      ..notifyDaily = true
      ..events = [
        CalendarEvent(id: '4', title: 'Meet', date: isoOf(day)),
      ];
    final items = notifyItemsOf(store);
    expect(items.any((i) => i['ch'] == 'public'), isTrue);
    expect(items.any((i) => i['ch'] == 'sil'), isTrue);
    expect(items.any((i) => i['ch'] == 'others'), isTrue);
    expect(items.any((i) => i['ch'] == 'tasks' && i['title'] == 'Meet'), isTrue);
    expect(items.any((i) => i['ch'] == 'daily'), isFalse);
    expect(items.length, greaterThan(24));
  });
}
