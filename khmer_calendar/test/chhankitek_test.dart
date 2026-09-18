import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/calendar/chhankitek.dart';

void main() {
  test('lunar of 2026-09-13', () {
    final d = lunarOf('2026-09-13');
    expect(d.gregorianDate, '2026-09-13');
    expect(d.dayOfWeek, 'អាទិត្យ');
    expect(d.khmerMonth, 'ភទ្របទ');
    expect(d.moonStatus, 'កើត');
    expect(d.moonDay, 2);
    expect(d.animalYear, 'មមី');
    expect(d.sak, 'អដ្ឋស័ក');
    expect(d.buddhistEraYear, 2570);
    expect(d.isSilDay, isFalse);
    expect(d.lunarDateText, contains('ភទ្របទ'));
  });

  test('holidays of 2026 include Khmer New Year', () {
    final list = holidaysOfYear(2026);
    expect(list.any((h) => h.date == '2026-04-14' && h.nameEn.contains('Khmer New Year') && h.type == HolidayType.public), isTrue);
    expect(list.any((h) => h.date == '2026-04-14' && h.nameEn.contains('Moha Sangkran')), isTrue);
    expect(list.any((h) => h.date == '2026-02-02' && h.nameEn == 'Meak Bochea' && h.type == HolidayType.religious), isTrue);
    expect(list.any((h) => h.nameKm == 'វិសាខបូជា' && h.type == HolidayType.religious), isTrue);
    expect(list.any((h) => h.nameKm == 'វិសាខបូជា' && h.type == HolidayType.public), isTrue);
  });

  test('2026 global and extra Buddhist events', () {
    final list = holidaysOfYear(2026);
    expect(list.any((h) => h.date == '2026-02-14' && h.nameEn == "Valentine's Day" && h.type == HolidayType.international), isTrue);
    expect(list.any((h) => h.date == '2026-12-25' && h.nameEn == 'Christmas Day' && h.type == HolidayType.international), isTrue);
    expect(list.any((h) => h.date == '2026-12-10' && h.nameEn == 'Human Rights Day' && h.type == HolidayType.international), isTrue);
    expect(list.any((h) => h.date == '2026-12-10' && h.type == HolidayType.public), isFalse);
    expect(list.any((h) => h.nameEn == 'Entering Vassa' && h.type == HolidayType.religious), isTrue);
    expect(list.any((h) => h.nameEn == 'Leaving Vassa' && h.type == HolidayType.religious), isTrue);
    expect(list.any((h) => h.nameEn == 'Kathina' && h.type == HolidayType.religious), isTrue);
    expect(list.any((h) => h.nameEn == 'Trasat Sangkran' && h.type == HolidayType.traditional), isTrue);
    expect(list.where((h) => h.type == HolidayType.public).length, greaterThanOrEqualTo(16));
    expect(list.where((h) => h.type == HolidayType.international).length, 28);
  });

  test('khmer numerals', () {
    expect(khmerNum(2026), '២០២៦');
  });
}
