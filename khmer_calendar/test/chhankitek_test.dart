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
    expect(list.length, 26);
    expect(list.any((h) => h.date == '2026-04-14' && h.nameEn == 'Khmer New Year'), isTrue);
    expect(list.any((h) => h.date == '2026-02-02' && h.nameEn == 'Meak Bochea' && h.type == HolidayType.religious), isTrue);
    expect(list.any((h) => h.nameKm == 'វិសាខបូជា' && h.type == HolidayType.religious), isTrue);
    expect(list.any((h) => h.nameKm == 'វិសាខបូជា' && h.type == HolidayType.public), isTrue);
  });

  test('khmer numerals', () {
    expect(khmerNum(2026), '២០២៦');
  });
}
