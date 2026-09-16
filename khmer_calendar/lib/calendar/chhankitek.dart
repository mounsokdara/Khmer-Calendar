// Khmer Chhankitek lunar engine, ported from the original APK calculator.

enum HolidayType { public, religious, traditional }

class Holiday {
  const Holiday({
    required this.date,
    required this.nameKm,
    required this.nameEn,
    required this.type,
  });

  final String date;
  final String nameKm;
  final String nameEn;
  final HolidayType type;

  Holiday copy() => Holiday(date: date, nameKm: nameKm, nameEn: nameEn, type: type);
}

class LunarDay {
  const LunarDay({
    required this.gregorianDate,
    required this.dayOfWeek,
    required this.buddhistEraYear,
    required this.buddhistEraYearKhmer,
    required this.khmerYear,
    required this.khmerYearKhmer,
    required this.khmerMonth,
    required this.moonStatus,
    required this.moonDay,
    required this.moonDayKhmer,
    required this.animalYear,
    required this.sak,
    required this.isLeapMonth,
    required this.isSilDay,
    required this.lunarDateText,
    required this.gregorianDateText,
    required this.gregorianDayText,
    required this.gregorianMonthText,
    required this.gregorianYearText,
    this.observanceText,
    required this.fullText,
    this.holidays,
  });

  final String gregorianDate;
  final String dayOfWeek;
  final int buddhistEraYear;
  final String buddhistEraYearKhmer;
  final int khmerYear;
  final String khmerYearKhmer;
  final String khmerMonth;
  final String moonStatus;
  final int moonDay;
  final String moonDayKhmer;
  final String animalYear;
  final String sak;
  final bool isLeapMonth;
  final bool isSilDay;
  final String lunarDateText;
  final String gregorianDateText;
  final String gregorianDayText;
  final String gregorianMonthText;
  final String gregorianYearText;
  final String? observanceText;
  final String fullText;
  final List<Holiday>? holidays;

  LunarDay withHolidays(List<Holiday> list) => LunarDay(
        gregorianDate: gregorianDate,
        dayOfWeek: dayOfWeek,
        buddhistEraYear: buddhistEraYear,
        buddhistEraYearKhmer: buddhistEraYearKhmer,
        khmerYear: khmerYear,
        khmerYearKhmer: khmerYearKhmer,
        khmerMonth: khmerMonth,
        moonStatus: moonStatus,
        moonDay: moonDay,
        moonDayKhmer: moonDayKhmer,
        animalYear: animalYear,
        sak: sak,
        isLeapMonth: isLeapMonth,
        isSilDay: isSilDay,
        lunarDateText: lunarDateText,
        gregorianDateText: gregorianDateText,
        gregorianDayText: gregorianDayText,
        gregorianMonthText: gregorianMonthText,
        gregorianYearText: gregorianYearText,
        observanceText: observanceText,
        fullText: fullText,
        holidays: list,
      );
}

const monthEn = {
  'ចេត្រ': 'Chet',
  'ពិសាខ': 'Vesak',
  'ជេស្ឋ': 'Jeṭṭha',
  'អាសាឍ': 'Asadha',
  'បឋមាសាឍ': 'Pathamasadha',
  'ទុតិយាសាឍ': 'Tutiyasadha',
  'ស្រាពណ៍': 'Srapon',
  'ភទ្របទ': 'Photrobot',
  'អស្សុជ': 'Assuj',
  'កត្តិក': 'Kattik',
  'មិគសិរ': 'Migasir',
  'បុស្ស': 'Pous',
  'មាឃ': 'Magha',
  'ផល្គុន': 'Phalguna',
};

const zodiac = ['ជូត', 'ឆ្លូវ', 'ខាល', 'ថោះ', 'រោង', 'ម្សាញ់', 'មមី', 'មមែ', 'វក', 'រកា', 'ច', 'កុរ'];

const zodiacEn = {
  'ជូត': 'Rat',
  'ឆ្លូវ': 'Ox',
  'ខាល': 'Tiger',
  'ថោះ': 'Rabbit',
  'រោង': 'Dragon',
  'ម្សាញ់': 'Snake',
  'មមី': 'Horse',
  'មមែ': 'Goat',
  'វក': 'Monkey',
  'រកា': 'Rooster',
  'ច': 'Dog',
  'កុរ': 'Pig',
};

const sak = [
  'ឯកស័ក',
  'ទោស័ក',
  'ត្រីស័ក',
  'ចត្វាស័ក',
  'បញ្ចស័ក',
  'ឆស័ក',
  'សប្តស័ក',
  'អដ្ឋស័ក',
  'នព្វស័ក',
  'សំរឹទ្ធិស័ក',
];

const sakEn = {
  'ឯកស័ក': 'Aekasak',
  'ទោស័ក': 'Tosak',
  'ត្រីស័ក': 'Treisak',
  'ចត្វាស័ក': 'Chatvasak',
  'បញ្ចស័ក': 'Panchasak',
  'ឆស័ក': 'Chhasak',
  'សប្តស័ក': 'Saptasak',
  'អដ្ឋស័ក': 'Atthasak',
  'នព្វស័ក': 'Navasak',
  'សំរឹទ្ធិស័ក': 'Samriddhisak',
};

const _waxing = 'កើត';
const _waning = 'រោច';
const weekdaysKm = ['អាទិត្យ', 'ចន្ទ', 'អង្គារ', 'ពុធ', 'ព្រហស្បតិ៍', 'សុក្រ', 'សៅរ៍'];
const _monthsKm = ['មករា', 'កុម្ភៈ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា', 'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ'];
const _khmerDigits = ['០', '១', '២', '៣', '៤', '៥', '៦', '៧', '៨', '៩'];

const _epoch = 1900;
const _epochMonth = 2;
const _epochDay = 1;
const _normalYear = 354;
const _leapDayYear = 355;
const _leapMonthYear = 384;
const _smallMonth = 29;
const _bigMonth = 30;

const _normalMonths = ['មិគសិរ', 'បុស្ស', 'មាឃ', 'ផល្គុន', 'ចេត្រ', 'ពិសាខ', 'ជេស្ឋ', 'អាសាឍ', 'ស្រាពណ៍', 'ភទ្របទ', 'អស្សុជ', 'កត្តិក'];
const _leapMonths = ['មិគសិរ', 'បុស្ស', 'មាឃ', 'ផល្គុន', 'ចេត្រ', 'ពិសាខ', 'ជេស្ឋ', 'បឋមាសាឍ', 'ទុតិយាសាឍ', 'ស្រាពណ៍', 'ភទ្របទ', 'អស្សុជ', 'កត្តិក'];

final _yearHolidays = <int, List<Holiday>>{};
final _newYearCache = <int, ({DateTime gregorianStartDate, int totalDays})>{};
final _vesak16 = <int, DateTime>{};
final _dayCache = <String, LunarDay>{};
final _yearCursorCache = <int, ({int month, int day})>{};

int _mod(int e, int t) => (e % t + t) % t;

DateTime _dateOnly(DateTime e) => DateTime(e.year, e.month, e.day);

DateTime _addDays(DateTime e, int t) => DateTime(e.year, e.month, e.day + t);

bool _onOrAfter(DateTime e, DateTime t) => !_dateOnly(e).isBefore(_dateOnly(t));

int _jsWeekday(DateTime d) => d.weekday % 7;

String toIso(DateTime e) {
  final y = e.year.toString().padLeft(4, '0');
  final m = e.month.toString().padLeft(2, '0');
  final d = e.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime parseDate(Object e) {
  if (e is DateTime) {
    if (e.year < _epoch) throw ArgumentError('Dates before $_epoch-01-01 are not supported.');
    return _dateOnly(e);
  }
  if (e is String) {
    final t = e.trim();
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(t);
    if (iso != null) {
      final y = int.parse(iso.group(1)!);
      final m = int.parse(iso.group(2)!);
      final d = int.parse(iso.group(3)!);
      final r = DateTime(y, m, d);
      if (r.year != y || r.month != m || r.day != d) throw ArgumentError('Invalid date provided.');
      if (y < _epoch) throw ArgumentError('Dates before $_epoch-01-01 are not supported.');
      return r;
    }
  }
  throw ArgumentError('Invalid date provided.');
}

String khmerNum(Object v) => v.toString().replaceAllMapped(RegExp(r'\d'), (m) => _khmerDigits[int.parse(m[0]!)]);

List<int> _normHms(int e, int t, int n) {
  var r = e, i = t, a = n;
  while (a >= 60) {
    a -= 60;
    i += 1;
  }
  while (a < 0) {
    a += 60;
    i -= 1;
  }
  while (i >= 30) {
    i -= 30;
    r += 1;
  }
  while (i < 0) {
    i += 30;
    r -= 1;
  }
  r = _mod(r, 12);
  return [r, i, a];
}

List<int> _addHms(List<int> e, List<int> t) => _normHms(e[0] + t[0], e[1] + t[1], e[2] + t[2]);
List<int> _subHms(List<int> e, List<int> t) => _normHms(e[0] - t[0], e[1] - t[1], e[2] - t[2]);

int _wc(int e) => 800 - _mod(e * 292207 + 373, 800);

List<int> _gc(int e, int t) {
  final n = t * 800 + e;
  final r = n ~/ 24350;
  final i = n % 24350;
  final a = i ~/ 811;
  final o = i % 811;
  return [r, a, o ~/ 14 - 3];
}

List<int> _kc(List<int> e) {
  final t = e[0] - 2;
  final n = [t, e[1] - 20, e[2]];
  late List<int> r;
  switch (t) {
    case 0:
    case 1:
    case 2:
      r = [t, 0, 0];
      break;
    case 3:
    case 4:
    case 5:
      r = _subHms([5, 29, 60], n);
      break;
    case 6:
    case 7:
    case 8:
      r = _subHms(n, [6, 0, 0]);
      break;
    default:
      r = _subHms([11, 29, 60], n);
  }
  final i = r[0] * 2 + 1;
  final a = ((r[1] - 15) * 60 + 30) * i;
  final o = a ~/ 900 + 129;
  return [0, o ~/ 60, o % 60];
}

bool _hasDup(List<List<int>> e) {
  final t = <int, int>{};
  for (final n in e) {
    t[n[1]] = (t[n[1]] ?? 0) + 1;
  }
  return t.values.any((e) => e > 1);
}

int _newYearLengthHint(int e) {
  final t = _wc(e - 638 - 1);
  final n = <List<int>>[];
  for (var i = 0; i < 4; i += 1) {
    final r = _gc(t, 363 + i);
    n.add(_addHms(r, _kc(r)));
  }
  return _hasDup(n) ? 2 : 1;
}

bool _isLeapGregorian(int e) => e % 4 == 0 && (e % 100 != 0 || e % 400 == 0);
int _gregorianLength(int e) => _isLeapGregorian(e) ? 366 : 365;
int _beOf(int e) => e + 544;
int _iw(int e) => ((_beOf(e) * 292207 + 499) ~/ 800) + 4;
int _aw(int e) => (11 * _iw(e) + 25) % 692;
int _ow(int e) {
  final t = _iw(e);
  return (((11 * t + 25) ~/ 692) + t + 29) % 30;
}

bool _sw(int e) => 800 - (_beOf(e) * 292207 + 499) % 800 <= 207;

int _cw(int e) {
  final t = _aw(e);
  final n = _ow(e);
  var r = n >= 25 || n <= 5;
  var i = false;
  if (_sw(e)) {
    i = t <= 126;
  } else if (t <= 137) {
    i = _aw(e + 1) != 0;
  }
  if (n == 25 && _ow(e + 1) == 5) r = false;
  if (n == 24 && _ow(e + 1) == 6) r = true;
  if (r && i) return 3;
  if (r) return 1;
  if (i) return 2;
  return 0;
}

String _yearType(int e) {
  final t = _cw(e);
  if (t == 3 || t == 1) return 'leap-month';
  if (t == 2 || _cw(e - 1) == 3) return 'leap-day';
  return 'normal';
}

int _yearLength(int e) {
  final t = _yearType(e);
  if (t == 'leap-month') return _leapMonthYear;
  if (t == 'leap-day') return _leapDayYear;
  return _normalYear;
}

int _monthCount(int e) => _yearType(e) == 'leap-month' ? _leapMonths.length : _normalMonths.length;

int _wrapMonth(int e, int t) => _mod(e - 1, _monthCount(t)) + 1;

String _monthName(int e, int t) {
  final n = _wrapMonth(e, t);
  return (_yearType(t) == 'leap-month' ? _leapMonths : _normalMonths)[n - 1];
}

int _monthLength(int e, int t) {
  final n = _wrapMonth(e, t);
  final r = _yearType(t);
  if (r == 'leap-month') {
    if (n == 8 || n == 9 || ((n > 9 ? n - 1 : n) % 2 == 0)) return _bigMonth;
    return _smallMonth;
  }
  if (n == 7) return r == 'leap-day' ? _bigMonth : _smallMonth;
  return n % 2 == 0 ? _bigMonth : _smallMonth;
}

int _dayOfYear(DateTime e) => e.difference(DateTime(e.year, 1, 1)).inDays;

({int month, int day}) _advance(int e, int t, int n, int r) {
  var i = e;
  var a = t;
  for (var k = 0; k < r; k += 1) {
    a += 1;
    if (a > _monthLength(i, n)) {
      a = 1;
      i = _wrapMonth(i + 1, n);
    }
  }
  return (month: i, day: a);
}

({int month, int day}) _cursorOf(int e) {
  final hit = _yearCursorCache[e];
  if (hit != null) return hit;
  var t = _epochMonth;
  var n = _epochDay;
  for (var r = _epoch; r < e; r += 1) {
    n += _gregorianLength(r) - _yearLength(r);
    while (n > _monthLength(t, r)) {
      n -= _monthLength(t, r);
      t = _wrapMonth(t + 1, r);
    }
    while (n <= 0) {
      t = _wrapMonth(t - 1, r);
      n += _monthLength(t, r);
    }
  }
  final out = (month: t, day: n);
  _yearCursorCache[e] = out;
  return out;
}

({String khmerMonth, int monthDay, int monthLength, String yearType}) _lunarParts(DateTime e) {
  final t = e.year;
  final n = _cursorOf(t);
  final r = _advance(n.month, n.day, t, _dayOfYear(e));
  return (
    khmerMonth: _monthName(r.month, t),
    monthDay: r.day,
    monthLength: _monthLength(r.month, t),
    yearType: _yearType(t),
  );
}

DateTime _locate(int year, String khmerMonth, int monthDay) {
  var n = DateTime(year, 4, 10);
  final r = DateTime(year, 6, 15);
  while (!n.isAfter(r)) {
    final parts = _lunarParts(n);
    if (parts.khmerMonth == khmerMonth && parts.monthDay == monthDay) return _dateOnly(n);
    n = _addDays(n, 1);
  }
  throw StateError('Unable to locate Khmer boundary date for Gregorian year $year.');
}

({String khmerMonth, int monthDay}) _newYearAnchor(int e) {
  final t = _ow(e);
  if (t >= 6) {
    return (khmerMonth: 'ចេត្រ', monthDay: t + (_cw(e - 1) == 3 ? 1 : 0));
  }
  return (khmerMonth: 'ពិសាខ', monthDay: t + 1);
}

({DateTime gregorianStartDate, int totalDays}) _khmerNewYear(int e) {
  final hit = _newYearCache[e];
  if (hit != null) return (gregorianStartDate: _dateOnly(hit.gregorianStartDate), totalDays: hit.totalDays);
  final n = _newYearLengthHint(e);
  final anchor = _newYearAnchor(e);
  final r = (
    gregorianStartDate: _addDays(_locate(e, anchor.khmerMonth, anchor.monthDay), -(n + 1)),
    totalDays: n + 2,
  );
  _newYearCache[e] = r;
  return (gregorianStartDate: _dateOnly(r.gregorianStartDate), totalDays: r.totalDays);
}

int _khmerYearOf(DateTime e) {
  final t = e.year;
  final n = _khmerNewYear(t).gregorianStartDate;
  return _onOrAfter(e, n) ? t : t - 1;
}

String _animalOf(int e) => zodiac[_mod(e - 2020, zodiac.length)];
String _sakOf(int e) => sak[_mod(e - 2019, sak.length)];

DateTime _vesak16Of(int e) {
  final t = _vesak16[e];
  if (t != null) return _dateOnly(t);
  final n = _locate(e, 'ពិសាខ', 16);
  _vesak16[e] = n;
  return _dateOnly(n);
}

({String moonStatus, int moonDay}) _moonOf(int e) {
  final t = e <= 15;
  return (moonStatus: t ? _waxing : _waning, moonDay: t ? e : e - 15);
}

bool _isLeapMonthName(String e) => e == 'បឋមាសាឍ' || e == 'ទុតិយាសាឍ';
bool _isSil(int e, int t) => e == 8 || e == 15 || e == 23 || e == t;

String? _silText(int e, String t, bool n) {
  if (e == 15 && t == _waxing) return 'ថ្ងៃនេះ ជាថ្ងៃសីល និងពេញបូណ៌មី';
  if (n) return 'ថ្ងៃនេះ ជាថ្ងៃសីល';
  return null;
}

String _lunarLine(String e, int t, String n, String r, String i, String a, int o) =>
    'ថ្ងៃ$e ${khmerNum(t)}$n ខែ$r ឆ្នាំ$i $a ពុទ្ធសករាជ ${khmerNum(o)}';

String _gregLine(DateTime e) => 'ថ្ងៃទី${khmerNum(e.day)} ខែ${_monthsKm[e.month - 1]} ឆ្នាំ${khmerNum(e.year)}';

String _fullLine(String e, String t, String? n) {
  final r = '$e ត្រូវនឹង$t';
  return n != null ? '$r $n' : r;
}

LunarDay lunarOf(Object d) {
  final e = parseDate(d);
  final t = _khmerYearOf(e);
  final n = _lunarParts(e);
  final moon = _moonOf(n.monthDay);
  final a = _onOrAfter(e, _vesak16Of(e.year)) ? e.year + 544 : e.year + 543;
  final s = _animalOf(t);
  final c = _sakOf(t);
  final l = weekdaysKm[_jsWeekday(e)];
  final u = _isSil(n.monthDay, n.monthLength);
  final observance = _silText(n.monthDay, moon.moonStatus, u);
  final h = _lunarLine(l, moon.moonDay, moon.moonStatus, n.khmerMonth, s, c, a);
  final g = _gregLine(e);
  return LunarDay(
    gregorianDate: toIso(e),
    dayOfWeek: l,
    buddhistEraYear: a,
    buddhistEraYearKhmer: khmerNum(a),
    khmerYear: a,
    khmerYearKhmer: khmerNum(a),
    khmerMonth: n.khmerMonth,
    moonStatus: moon.moonStatus,
    moonDay: moon.moonDay,
    moonDayKhmer: khmerNum(moon.moonDay),
    animalYear: s,
    sak: c,
    isLeapMonth: _isLeapMonthName(n.khmerMonth),
    isSilDay: u,
    lunarDateText: h,
    gregorianDateText: g,
    gregorianDayText: khmerNum(e.day),
    gregorianMonthText: _monthsKm[e.month - 1],
    gregorianYearText: khmerNum(e.year),
    observanceText: observance,
    fullText: _fullLine(h, g, observance),
  );
}

bool _lunarMatches(LunarDay e, {required String month, required String status, required List<int> days}) =>
    e.khmerMonth == month && e.moonStatus == status && days.contains(e.moonDay);

void _pushHoliday(List<Holiday> e, Holiday t) {
  final n = e.indexWhere((x) => x.date == t.date && (x.nameEn == t.nameEn || x.nameKm == t.nameKm));
  if (n == -1) {
    e.add(t);
    return;
  }
  if (e[n].type != HolidayType.public && t.type == HolidayType.public) e[n] = t;
}

void _applyLunarHolidays(List<Holiday> list, LunarDay t, String n) {
  void add(String km, String en, HolidayType type, bool ok) {
    if (ok) _pushHoliday(list, Holiday(date: n, nameKm: km, nameEn: en, type: type));
  }

  add('មាឃបូជា', 'Meak Bochea', HolidayType.religious, _lunarMatches(t, month: 'មាឃ', status: _waxing, days: const [15]));
  add('វិសាខបូជា', 'Visak Bochea', HolidayType.religious, _lunarMatches(t, month: 'ពិសាខ', status: _waxing, days: const [15]));
  add('វិសាខបូជា', 'Visak Bochea Day', HolidayType.public, _lunarMatches(t, month: 'ពិសាខ', status: _waxing, days: const [15]));
  add('ព្រះរាជពិធីច្រត់ព្រះនង្គ័ល', 'Royal Ploughing Ceremony', HolidayType.public,
      _lunarMatches(t, month: 'ពិសាខ', status: _waning, days: const [4]));
  add('ភ្ជុំបិណ្ឌ', 'Pchum Ben', HolidayType.religious, _lunarMatches(t, month: 'ភទ្របទ', status: _waning, days: const [15]));
  add(
    'ព្រះរាជពិធីបុណ្យភ្ជុំបិណ្ឌ',
    'Pchum Ben Festival',
    HolidayType.public,
    (_lunarMatches(t, month: 'ភទ្របទ', status: _waning, days: const [14, 15])) ||
        _lunarMatches(t, month: 'អស្សុជ', status: _waxing, days: const [1]),
  );
  add('ព្រះរាជពិធីបុណ្យអុំទូក', 'Water Festival', HolidayType.traditional,
      _lunarMatches(t, month: 'កត្តិក', status: _waxing, days: const [14, 15]));
  add(
    'ព្រះរាជពិធីបុណ្យអុំទូក',
    'Water Festival',
    HolidayType.public,
    _lunarMatches(t, month: 'កត្តិក', status: _waxing, days: const [14, 15]) ||
        _lunarMatches(t, month: 'កត្តិក', status: _waning, days: const [1]),
  );
}

List<Holiday> _khmerNewYearDays(int e) {
  final info = _khmerNewYear(e);
  return List.generate(
    info.totalDays,
    (n) => Holiday(
      date: toIso(_addDays(info.gregorianStartDate, n)),
      nameKm: 'បុណ្យចូលឆ្នាំខ្មែរ',
      nameEn: 'Khmer New Year',
      type: HolidayType.public,
    ),
  );
}

List<Holiday> _fixedHolidays(int e) => [
      Holiday(date: '$e-01-01', nameKm: 'បុណ្យចូលឆ្នាំសកល', nameEn: "International New Year's Day", type: HolidayType.public),
      Holiday(date: '$e-01-07', nameKm: 'ទិវាជ័យជម្នះលើរបបប្រល័យពូជសាសន៍', nameEn: 'Victory over Genocide Day', type: HolidayType.public),
      Holiday(date: '$e-03-08', nameKm: 'ទិវានារីអន្តរជាតិ', nameEn: "International Women's Day", type: HolidayType.public),
      ..._khmerNewYearDays(e),
      Holiday(date: '$e-05-01', nameKm: 'ទិវាពលកម្មអន្តរជាតិ', nameEn: 'International Labour Day', type: HolidayType.public),
      Holiday(date: '$e-05-14', nameKm: 'ព្រះរាជពិធីចម្រើនព្រះជន្ម ព្រះមហាក្សត្រ', nameEn: "King's Birthday", type: HolidayType.public),
      Holiday(date: '$e-06-18', nameKm: 'ព្រះរាជពិធីចម្រើនព្រះជន្ម ព្រះមហាក្សត្រី', nameEn: "Queen Mother's Birthday", type: HolidayType.public),
      Holiday(date: '$e-09-24', nameKm: 'ទិវារដ្ឋធម្មនុញ្ញ', nameEn: 'Constitution Day', type: HolidayType.public),
      Holiday(date: '$e-10-15', nameKm: 'ទិវាគោរពព្រះវិញ្ញាណក្ខន្ធ ព្រះបរមរតនកោដ្ឋ', nameEn: "Commemoration Day of King's Father", type: HolidayType.public),
      Holiday(date: '$e-10-29', nameKm: 'ព្រះរាជពិធីគ្រងរាជ្យ', nameEn: 'Coronation Day', type: HolidayType.public),
      Holiday(date: '$e-11-09', nameKm: 'បុណ្យឯករាជ្យជាតិ', nameEn: 'Independence Day', type: HolidayType.public),
      Holiday(date: '$e-12-29', nameKm: 'ទិវាសន្តិភាពនៅកម្ពុជា', nameEn: 'Peace Day in Cambodia', type: HolidayType.public),
    ];

List<Holiday> holidaysOfYear(int e) {
  if (e < _epoch) throw ArgumentError('Year must be $_epoch or later.');
  final hit = _yearHolidays[e];
  if (hit != null) return hit.map((x) => x.copy()).toList();
  final t = _fixedHolidays(e);
  var n = DateTime(e, 1, 1);
  final last = DateTime(e, 12, 31);
  while (!n.isAfter(last)) {
    _applyLunarHolidays(t, lunarOf(n), toIso(n));
    n = _addDays(n, 1);
  }
  t.sort((a, b) => a.date.compareTo(b.date));
  _yearHolidays[e] = t;
  return t.map((x) => x.copy()).toList();
}

LunarDay dayInfo(Object d) {
  final iso = toIso(parseDate(d));
  final cached = _dayCache[iso];
  if (cached != null) return cached;
  final n = lunarOf(iso);
  final r = holidaysOfYear(parseDate(iso).year).where((e) => e.date == n.gregorianDate).toList();
  final out = n.withHolidays(r);
  _dayCache[iso] = out;
  return out;
}

List<Holiday> holidaysOn(String iso) {
  final n = dayInfo(iso).holidays ?? const <Holiday>[];
  if (n.isNotEmpty) return n;
  final y = int.parse(iso.substring(0, 4));
  return holidaysOfYear(y).where((t) => t.date == iso).toList();
}

List<String> animalPair(LunarDay e) {
  final t = (e.moonDay + 10) % zodiac.length;
  return [zodiac[t], zodiac[(t + 6) % zodiac.length]];
}

bool silOf(LunarDay lunar) => lunar.isSilDay;
