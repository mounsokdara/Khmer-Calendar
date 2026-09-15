import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'calendar/chhankitek.dart';
import 'calendar/observances.dart';
import 'dates.dart';
import 'i18n.dart';
import 'net.dart';
import 'store.dart';
import 'weather.dart';

const _ch = MethodChannel('khmer.permissions');
var _bound = false;

bool get canPinHomeWidget {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android;
}

void bindHomeWidget(AppStore store) {
  if (_bound) return;
  _bound = true;
  store.addListener(() => syncHomeWidget(store));
  syncHomeWidget(store);
  syncWeatherWidget(store);
}

Future<void> syncHomeWidget(AppStore store) async {
  if (!canPinHomeWidget) return;
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
    };
  }
  final marks = <String, String>{};
  void flag(String iso, String f) {
    final cur = marks[iso] ?? '';
    if (!cur.contains(f)) marks[iso] = '$cur$f';
  }
  for (var y = now.year - 5; y <= now.year + 5; y++) {
    for (final o in yearObservances(y, store.events)) {
      if (o.date.isEmpty) continue;
      if (o.kind == Kind.holiday) {
        flag(o.date, o.holidayType == HolidayType.public ? 'p' : 'h');
      } else if (o.kind == Kind.event) {
        flag(o.date, 't');
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
      'lang': lang == Lang.en ? 'en' : 'km',
      'weekStartsOn': store.weekStartsOn,
      'notifyOn': store.notifyOn,
    });
  } catch (_) {}
}

Future<void> syncWeatherWidget(AppStore store) async {
  if (!canPinHomeWidget) return;
  if (store.weatherCities.isEmpty) return;
  if (NetStatus.isOffline) return;
  final city = cityById(store.weatherCities.first);
  if (city == null) return;
  try {
    final snap = await fetchWeather(city);
    await pushWeather(store, city, snap);
  } catch (_) {}
}

Future<void> pushWeather(AppStore store, City city, WeatherSnap snap) async {
  if (!canPinHomeWidget) return;
  final meta = wmoOf(snap.code);
  try {
    await _ch.invokeMethod<void>('updateWidget', {
      'wx_city': city.name,
      'wx_city_en': city.nameEn,
      'wx_temp': '${snap.temp}',
      'wx_high': '${snap.high}',
      'wx_low': '${snap.low}',
      'wx_label': meta.km,
      'wx_label_en': meta.en,
      'lang': store.lang == Lang.en ? 'en' : 'km',
    });
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
