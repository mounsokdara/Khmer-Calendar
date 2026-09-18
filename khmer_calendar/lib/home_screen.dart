import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'calendar/chhankitek.dart';
import 'calendar/observances.dart';
import 'dates.dart';
import 'i18n.dart';
import 'net.dart';
import 'notify/kinds.dart';
import 'store.dart';
import 'weather.dart';
import 'wx_cache.dart';

const _ch = MethodChannel('khmer.permissions');
var _bound = false;
Timer? _widgetDebounce;
String _widgetSig = '';

bool get canPinHomeWidget {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android;
}

void bindHomeWidget(AppStore store) {
  if (_bound) return;
  _bound = true;
  store.addListener(() {
    _widgetDebounce?.cancel();
    _widgetDebounce = Timer(const Duration(milliseconds: 450), () async {
      await syncHomeWidget(store);
      await syncNativeAlarms(store);
    });
  });
  syncHomeWidget(store);
  syncWeatherWidget(store);
  syncNativeAlarms(store);
  _ch.setMethodCallHandler((call) async {
    if (call.method == 'open') applyWidgetLaunch(store, call.arguments);
  });
  _ch.invokeMethod<dynamic>('getLaunch').then((raw) => applyWidgetLaunch(store, raw)).catchError((_) {});
}

void applyWidgetLaunch(AppStore store, Object? raw) {
  if (raw is! Map) return;
  final tab = raw['tab']?.toString() ?? '';
  final date = raw['date']?.toString() ?? '';
  if (tab.isEmpty && date.isEmpty) return;
  store.applyLaunch(tab: tab, date: date);
}

Future<void> syncHomeWidget(AppStore store) async {
  if (!canPinHomeWidget) return;
  final sig =
      '${store.lang}|${store.weekStartsOn}|${store.notifyOn}|${store.notifyDaily}|${store.notifySil}|${store.notifyPublic}|${store.notifyReligious}|${store.events.length}|${todayIso()}';
  if (sig == _widgetSig) return;
  _widgetSig = sig;
  final now = DateTime.now();
  final iso = todayIso();
  final lunar = lunarOf(now);
  final lang = store.lang;
  final lunarText = lang == Lang.en ? lunarLabel(iso, lang) : lunar.lunarDateText;
  final hols = observancesOn(iso, store.events).where((e) => e.kind == Kind.holiday);
  final holiday = hols.isEmpty ? '' : obsTitle(hols.first, lang);
  final days = <String, Map<String, String>>{};
  for (var i = 0; i < 16; i++) {
    final d = DateTime(now.year, now.month, now.day + i);
    final di = isoOf(d);
    final lu = lunarOf(d);
    final hs = observancesOn(di, store.events).where((e) => e.kind == Kind.holiday);
    days[di] = {
      'lunar': lang == Lang.en ? lunarLabel(di, lang) : lu.lunarDateText,
      'holiday': hs.isEmpty ? '' : obsTitle(hs.first, lang),
      'weekday': weekdaysFull(lang)[d.weekday % 7],
      'gregorian': lang == Lang.en ? gregorianLabel(d, lang) : lu.gregorianDateText,
      'be': lang == Lang.en ? 'B.E. ${lu.buddhistEraYear}' : 'ព.ស. ${lu.buddhistEraYearKhmer}',
      'moon': silPhaseLabel(lu, lang),
      'sil': lu.isSilDay ? '1' : '',
      'hkind': hs.isEmpty
          ? ''
          : (hs.first.holidayType == HolidayType.public
              ? 'public'
              : hs.first.holidayType == HolidayType.religious
                  ? 'religious'
                  : hs.first.holidayType == HolidayType.international
                      ? 'international'
                      : 'traditional'),
    };
  }
  final marks = <String, String>{};
  final names = <String, String>{};
  void flag(String iso, String f) {
    final cur = marks[iso] ?? '';
    if (!cur.contains(f)) marks[iso] = '$cur$f';
  }
  for (var y = now.year - 5; y <= now.year + 5; y++) {
    for (final o in yearObservances(y, store.events)) {
      if (o.date.isEmpty) continue;
      if (o.kind == Kind.holiday) {
        if (o.holidayType == HolidayType.public) {
          flag(o.date, 'p');
        } else if (o.holidayType == HolidayType.religious || o.holidayType == HolidayType.traditional) {
          flag(o.date, 'h');
        }
        names.putIfAbsent(o.date, () => obsTitle(o, lang));
      } else if (o.kind == Kind.event) {
        flag(o.date, 't');
        names.putIfAbsent(o.date, () => obsTitle(o, lang));
      } else if (o.kind == Kind.sil) {
        flag(o.date, 's');
      }
    }
  }
  try {
    await _ch.invokeMethod<void>('updateWidget', {
      'iso': iso,
      'day': '${now.day}',
      'weekday': weekdaysFull(lang)[now.weekday % 7],
      'lunar': lunarText,
      'holiday': holiday,
      'title': t(lang, 'appName'),
      'days': jsonEncode(days),
      'marks': jsonEncode(marks),
      'names': jsonEncode(names),
      'lang': lang == Lang.en ? 'en' : 'km',
      'weekStartsOn': store.weekStartsOn,
      'notifyOn': store.notifyOn,
      'notifyDaily': store.notifyDaily,
      'notifySil': store.notifySil,
      'notifyPublic': store.notifyPublic,
      'notifyReligious': store.notifyReligious,
      'sil_days': store.notifySil ? upcomingSilDates().join(',') : '',
      'public_hols': jsonEncode(upcomingHolidays(HolidayType.public)),
      'religious_hols': jsonEncode(upcomingBlueHolidays()),
    });
  } catch (_) {}
}

Future<void> syncWeatherWidget(AppStore store) async {
  if (!canPinHomeWidget) return;
  if (store.weatherCities.isEmpty) return;
  if (NetStatus.isOffline) return;
  final cache = <String, WeatherSnap>{};
  for (final id in store.weatherCities) {
    final city = cityById(id);
    if (city == null) continue;
    try {
      cache[id] = await fetchWeather(city);
    } catch (_) {}
  }
  await pushWeatherList(store, cache);
}

Future<void> pushWeather(AppStore store, City city, WeatherSnap snap) async {
  await pushWeatherList(store, {city.id: snap}, selectId: city.id);
}

String encodeHourly(WeatherSnap snap) {
  final now = DateTime.now();
  return snap.hourly
      .where((h) {
        final t = DateTime.tryParse(h.time);
        return t != null && !t.isBefore(now.subtract(const Duration(minutes: 40)));
      })
      .take(6)
      .map((h) {
        final t = DateTime.tryParse(h.time);
        final hh = (t?.hour ?? 0).toString().padLeft(2, '0');
        return '$hh|${h.temp}|${h.code}';
      })
      .join(';');
}

Future<void> pushWeatherList(
  AppStore store,
  Map<String, WeatherSnap> cache, {
  String? selectId,
}) async {
  if (!canPinHomeWidget) return;
  final rows = <Map<String, String>>[];
  var index = 0;
  for (var i = 0; i < store.weatherCities.length; i++) {
    final id = store.weatherCities[i];
    final city = cityById(id);
    if (city == null) continue;
    final snap = cache[id];
    if (selectId != null && id == selectId) index = rows.length;
    final meta = snap == null ? null : wmoOf(snap.code);
    rows.add({
      'id': id,
      'name': city.name,
      'nameEn': city.nameEn,
      'temp': snap == null ? '' : '${snap.temp}',
      'high': snap == null ? '' : '${snap.high}',
      'low': snap == null ? '' : '${snap.low}',
      'label': meta?.km ?? '',
      'labelEn': meta?.en ?? '',
      'code': '${snap?.code ?? 2}',
      'daily': snap == null
          ? ''
          : snap.daily.take(7).map((d) => '${d.date}|${d.high}|${d.low}|${d.code}').join(';'),
      'hourly': snap == null ? '' : encodeHourly(snap),
      'clouds': '${snap?.clouds ?? 0}',
      'icon': '',
      'photo': '',
    });
  }
  if (rows.isEmpty) return;
  Future<void> send() async {
    final first = rows[index.clamp(0, rows.length - 1)];
    await _ch.invokeMethod<void>('updateWidget', {
      'wx_list': jsonEncode(rows),
      'wx_index': index,
      'wx_city': first['name'],
      'wx_city_en': first['nameEn'],
      'wx_temp': first['temp'],
      'wx_high': first['high'],
      'wx_low': first['low'],
      'wx_label': first['label'],
      'wx_label_en': first['labelEn'],
      'lang': store.lang == Lang.en ? 'en' : 'km',
    });
  }

  try {
    await send();
  } catch (_) {}
  for (final row in rows) {
    final id = row['id'] ?? '';
    final city = cityById(id);
    final snap = cache[id];
    if (city == null) continue;
    if (snap != null) {
      row['icon'] = await cacheUrl(wmoIconUrl(snap.code), 'wx_icon_$id.png') ?? '';
    }
    final remote = await cityPhotoUrl(city);
    if (remote != null) {
      row['photo'] = await cacheUrl(remote, 'wx_photo_$id.jpg') ?? '';
    }
  }
  try {
    await send();
  } catch (_) {}
}

Future<bool> pinHomeWidget([String kind = 'today']) async {
  if (!canPinHomeWidget) return false;
  try {
    return await _ch.invokeMethod<bool>('pinWidget', {'kind': kind}) ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> armDailyNotify({bool showNow = false}) async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('armDaily', {'showNow': showNow});
  } catch (_) {}
}

Future<void> cancelDailyNotify() async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('cancelDaily');
  } catch (_) {}
}

Future<void> armSilNotify({bool showNow = false}) async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('armSil', {'showNow': showNow});
  } catch (_) {}
}

Future<void> cancelSilNotify() async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('cancelSil');
  } catch (_) {}
}

Future<void> armPublicNotify({bool showNow = false}) async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('armPublic', {'showNow': showNow});
  } catch (_) {}
}

Future<void> cancelPublicNotify() async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('cancelPublic');
  } catch (_) {}
}

Future<void> armReligiousNotify({bool showNow = false}) async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('armReligious', {'showNow': showNow});
  } catch (_) {}
}

Future<void> cancelReligiousNotify() async {
  if (!canPinHomeWidget) return;
  try {
    await _ch.invokeMethod<void>('cancelReligious');
  } catch (_) {}
}

Future<void> syncNativeAlarms(AppStore store, {bool showNow = false}) async {
  if (!canPinHomeWidget) return;
  _widgetSig = '';
  await syncHomeWidget(store);
  if (store.notifyOn && store.notifyDaily) {
    await armDailyNotify();
  } else {
    await cancelDailyNotify();
  }
  if (store.notifyOn && store.notifySil) {
    await armSilNotify(showNow: showNow);
  } else {
    await cancelSilNotify();
  }
  if (store.notifyOn && store.notifyPublic) {
    await armPublicNotify(showNow: showNow);
  } else {
    await cancelPublicNotify();
  }
  if (store.notifyOn && store.notifyReligious) {
    await armReligiousNotify(showNow: showNow);
  } else {
    await cancelReligiousNotify();
  }
}
