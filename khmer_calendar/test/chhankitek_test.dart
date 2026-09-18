import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/calendar/chhankitek.dart';
import 'package:khmer_calendar/calendar/observances.dart';

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
    expect(list.where((h) => h.type == HolidayType.international).length, 55);
    expect(list.any((h) => h.nameEn == 'Asalha Puja' && h.type == HolidayType.religious), isTrue);
  });

  test('video-checked Chinese and international dates stay valid', () {
    bool has(int year, String iso, String en, HolidayType type) =>
        holidaysOfYear(year).any((h) => h.date == iso && h.nameEn == en && h.type == type);

    expect(has(2012, '2012-01-17', 'Kitchen God Festival', HolidayType.traditional), isTrue);
    expect(has(2012, '2012-01-22', "Chinese New Year's Eve", HolidayType.traditional), isTrue);
    expect(has(2012, '2012-01-23', 'Chinese New Year', HolidayType.traditional), isTrue);
    expect(has(2012, '2012-01-24', 'Chinese New Year', HolidayType.traditional), isTrue);
    expect(has(2012, '2012-01-25', 'Chinese New Year', HolidayType.traditional), isTrue);
    expect(has(2015, '2015-02-12', 'Kitchen God Festival', HolidayType.traditional), isTrue);
    expect(has(2015, '2015-02-18', "Chinese New Year's Eve", HolidayType.traditional), isTrue);
    expect(has(2015, '2015-02-19', 'Chinese New Year', HolidayType.traditional), isTrue);
    expect(has(2020, '2020-01-25', 'Chinese New Year', HolidayType.traditional), isTrue);
    expect(has(2025, '2025-01-23', 'Kitchen God Festival', HolidayType.traditional), isTrue);
    expect(has(2025, '2025-01-28', "Chinese New Year's Eve", HolidayType.traditional), isTrue);
    expect(has(2025, '2025-01-29', 'Chinese New Year', HolidayType.traditional), isTrue);
    expect(has(2028, '2028-01-20', 'Kitchen God Festival', HolidayType.traditional), isTrue);
    expect(has(2028, '2028-01-26', 'Chinese New Year', HolidayType.traditional), isTrue);

    expect(has(2010, '2010-09-22', 'Mid-Autumn Festival', HolidayType.traditional), isTrue);
    expect(has(2015, '2015-09-27', 'Mid-Autumn Festival', HolidayType.traditional), isTrue);
    expect(has(2016, '2016-09-15', 'Mid-Autumn Festival', HolidayType.traditional), isTrue);
    expect(has(2017, '2017-09-05', 'Hungry Ghost Festival', HolidayType.traditional), isTrue);
    expect(has(2022, '2022-08-12', 'Hungry Ghost Festival', HolidayType.traditional), isTrue);
    expect(has(2025, '2025-09-06', 'Hungry Ghost Festival', HolidayType.traditional), isTrue);
    expect(has(2028, '2028-09-03', 'Hungry Ghost Festival', HolidayType.traditional), isTrue);

    expect(has(2013, '2013-06-12', 'Sticky Rice Festival', HolidayType.traditional), isTrue);
    expect(has(2019, '2019-06-07', 'Sticky Rice Festival', HolidayType.traditional), isTrue);
    expect(has(2027, '2027-06-09', 'Sticky Rice Festival', HolidayType.traditional), isTrue);
    expect(has(2013, '2013-12-22', 'Winter Solstice', HolidayType.traditional), isTrue);
    expect(has(2021, '2021-12-21', 'Winter Solstice', HolidayType.traditional), isTrue);
    expect(has(2030, '2030-12-22', 'Winter Solstice', HolidayType.traditional), isTrue);
    expect(has(2014, '2014-07-03', 'Cambodia UNESCO Membership Day', HolidayType.international), isTrue);
    expect(has(2010, '2010-09-16', 'International Day for the Preservation of the Ozone Layer', HolidayType.international), isTrue);
    expect(has(2013, '2013-12-12', 'International Day of Neutrality', HolidayType.international), isTrue);
    expect(has(2014, '2014-07-11', 'Asalha Puja', HolidayType.religious), isTrue);
    expect(has(2024, '2024-07-20', 'Asalha Puja', HolidayType.religious), isTrue);
    expect(has(2030, '2030-07-15', 'Asalha Puja', HolidayType.religious), isTrue);

    expect(has(2011, '2011-05-08', "Mother's Day", HolidayType.international), isTrue);
    expect(has(2013, '2013-06-16', "Father's Day", HolidayType.international), isTrue);
    expect(has(2019, '2019-06-16', "Father's Day", HolidayType.international), isTrue);
    expect(has(2027, '2027-06-20', "Father's Day", HolidayType.international), isTrue);
    expect(has(2010, '2010-09-08', 'International Literacy Day', HolidayType.international), isTrue);
    expect(has(2010, '2010-09-15', 'International Day of Democracy', HolidayType.international), isTrue);
    expect(has(2011, '2011-05-03', 'World Press Freedom Day', HolidayType.international), isTrue);
    expect(has(2012, '2012-10-31', 'Halloween', HolidayType.international), isTrue);
    expect(has(2012, '2012-10-23', 'Paris Peace Agreements Day', HolidayType.international), isTrue);
    expect(has(2014, '2014-07-01', 'National Fish Day', HolidayType.international), isTrue);
    expect(has(2014, '2014-07-09', 'Arbor Day', HolidayType.international), isTrue);
    expect(has(2021, '2021-04-04', 'Tomb-Sweeping Day', HolidayType.international), isTrue);
    expect(has(2023, '2023-04-05', 'Tomb-Sweeping Day', HolidayType.international), isTrue);
    expect(has(2026, '2026-04-05', 'Tomb-Sweeping Day', HolidayType.international), isTrue);
    expect(has(2029, '2029-04-04', 'Tomb-Sweeping Day', HolidayType.international), isTrue);

    expect(has(2010, '2010-01-30', 'Meak Bochea', HolidayType.religious), isTrue);
    expect(holidaysOfYear(2010).any((h) => h.date == '2010-01-30' && h.type == HolidayType.public), isFalse);
    expect(holidaysOfYear(2011).where((h) => h.nameEn == "King's Birthday").map((h) => h.date).toSet(), {'2011-05-14'});
    expect(holidaysOfYear(2013).any((h) => h.date == '2013-12-10' && h.type == HolidayType.public), isFalse);
  });

  test('day numbers: public red, other holidays blue', () {
    expect(dayTone('2012-01-01', true), 'sunday');
    expect(dayTone('2012-01-23', true), 'holiday');
    expect(dayTone('2010-09-08', true), 'holiday');
    expect(dayTone('2026-12-10', true), 'holiday');
    expect(dayTone('2026-04-14', true), 'sunday');
  });

  test('khmer numerals', () {
    expect(khmerNum(2026), '២០២៦');
  });
}
