import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/calendar/chhankitek.dart';
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
}
