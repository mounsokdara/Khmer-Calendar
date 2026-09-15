import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'calendar/chhankitek.dart';
import 'calendar/observances.dart';
import 'dates.dart';
import 'i18n.dart';
import 'store.dart';

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
}

Future<void> syncHomeWidget(AppStore store) async {
  if (!canPinHomeWidget) return;
  final day = DateTime.now();
  final iso = todayIso();
  final lunar = lunarOf(day);
  final lang = store.lang;
  final lunarText = lang == Lang.en ? lunarLabel(iso, lang) : lunar.lunarDateText;
  final hols = observancesOn(iso, store.events).where((e) => e.kind == Kind.holiday);
  final holiday = hols.isEmpty ? '' : obsTitle(hols.first, lang);
  try {
    await _ch.invokeMethod<void>('updateWidget', {
      'iso': iso,
      'day': '${day.day}',
      'weekday': weekdaysFull(lang)[day.weekday % 7],
      'lunar': lunarText,
      'holiday': holiday,
      'title': t(lang, 'appName'),
    });
  } catch (_) {}
}

Future<bool> pinHomeWidget() async {
  if (!canPinHomeWidget) return false;
  try {
    return await _ch.invokeMethod<bool>('pinWidget') ?? false;
  } catch (_) {
    return false;
  }
}
