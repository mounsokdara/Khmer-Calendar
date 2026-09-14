import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dates.dart';
import 'i18n.dart';
import 'theme.dart';

class CalendarEvent {
  CalendarEvent({
    required this.id,
    required this.title,
    this.notes,
    required this.date,
    this.endDate,
    this.startTime,
    this.endTime,
    this.allDay,
    this.reminderDate,
    this.reminderTime,
    this.done,
  });

  String id;
  String title;
  String? notes;
  String date;
  String? endDate;
  String? startTime;
  String? endTime;
  bool? allDay;
  String? reminderDate;
  String? reminderTime;
  bool? done;

  CalendarEvent copy() => CalendarEvent(
        id: id,
        title: title,
        notes: notes,
        date: date,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        allDay: allDay,
        reminderDate: reminderDate,
        reminderTime: reminderTime,
        done: done,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'date': date,
        'endDate': endDate,
        'startTime': startTime,
        'endTime': endTime,
        'allDay': allDay,
        'reminderDate': reminderDate,
        'reminderTime': reminderTime,
        'done': done,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> j) => CalendarEvent(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        notes: j['notes'] as String?,
        date: j['date'] as String? ?? '',
        endDate: j['endDate'] as String?,
        startTime: j['startTime'] as String?,
        endTime: j['endTime'] as String?,
        allDay: j['allDay'] as bool?,
        reminderDate: j['reminderDate'] as String?,
        reminderTime: j['reminderTime'] as String?,
        done: j['done'] as bool?,
      );
}

enum TabId { today, months, events, weather, more }

const _legacyDefaultCities = ['phnom-penh', 'banteay-meanchey', 'kampong-cham', 'kratie'];

class AppStore extends ChangeNotifier {
  List<CalendarEvent> events = [];
  String cursor = todayIso();
  String selected = todayIso();
  String theme = 'system';
  ColorSchemeId colorScheme = ColorSchemeId.slate;
  bool materialYou = true;
  bool extraDark = false;
  String langPref = 'auto';
  Lang lang = deviceLang();
  bool setupDone = false;
  TabId lastTab = TabId.months;
  String lastEventsPane = 'holidays';
  List<String> weatherCities = [];
  bool installed = false;
  bool notifyOn = false;
  bool backgroundOn = false;
  bool locationOn = false;
  bool autoLaunchOn = false;
  int weekStartsOn = 1;
  bool hydrated = false;

  Brightness get brightness {
    if (theme == 'light') return Brightness.light;
    if (theme == 'dark') return Brightness.dark;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  Future<void> hydrate() async {
    final started = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('khmer-calendar-v4') ?? prefs.getString('khmer-calendar-v3');
      if (raw != null) {
        final p = jsonDecode(raw) as Map<String, dynamic>;
        events = ((p['events'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        theme = p['theme'] as String? ?? theme;
        final scheme = p['colorScheme'] as String?;
        if (scheme != null) {
          colorScheme = ColorSchemeId.values.firstWhere(
            (s) => s.name == scheme,
            orElse: () => ColorSchemeId.slate,
          );
        }
        materialYou = p['materialYou'] as bool? ?? true;
        extraDark = p['extraDark'] as bool? ?? false;
        langPref = p['langPref'] as String? ?? 'auto';
        setupDone = p['setupDone'] as bool? ?? false;
        final tab = p['lastTab'] as String?;
        if (tab != null) {
          lastTab = TabId.values.firstWhere((t) => t.name == tab, orElse: () => TabId.months);
        }
        lastEventsPane = p['lastEventsPane'] as String? ?? 'holidays';
        weatherCities = ((p['weatherCities'] as List?) ?? []).cast<String>();
        if (listEquals(weatherCities, _legacyDefaultCities)) weatherCities = [];
        installed = p['installed'] as bool? ?? false;
        notifyOn = p['notifyOn'] as bool? ?? false;
        backgroundOn = p['backgroundOn'] as bool? ?? false;
        locationOn = p['locationOn'] as bool? ?? false;
        autoLaunchOn = p['autoLaunchOn'] as bool? ?? false;
        weekStartsOn = p['weekStartsOn'] as int? ?? 1;
      }
    } catch (_) {
      /* first run */
    }
    lang = resolveLang(langPref);
    IntlHelper.localeName = lang == Lang.km ? 'km' : 'en';
    final wait = 720 - DateTime.now().difference(started).inMilliseconds;
    if (wait > 0) await Future<void>.delayed(Duration(milliseconds: wait));
    hydrated = true;
    notifyListeners();
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'khmer-calendar-v4',
      jsonEncode({
        'events': events.map((e) => e.toJson()).toList(),
        'theme': theme,
        'colorScheme': colorScheme.name,
        'materialYou': materialYou,
        'extraDark': extraDark,
        'langPref': langPref,
        'setupDone': setupDone,
        'lastTab': lastTab.name,
        'lastEventsPane': lastEventsPane,
        'weatherCities': weatherCities,
        'installed': installed,
        'notifyOn': notifyOn,
        'backgroundOn': backgroundOn,
        'locationOn': locationOn,
        'autoLaunchOn': autoLaunchOn,
        'weekStartsOn': weekStartsOn,
      }),
    );
  }

  void _touch() {
    notifyListeners();
    persist();
  }

  void addEvent(CalendarEvent e) {
    events = [...events, e];
    _touch();
  }

  void updateEvent(CalendarEvent e) {
    events = events.map((x) => x.id == e.id ? e : x).toList();
    _touch();
  }

  void deleteEvent(String id) {
    events = events.where((x) => x.id != id).toList();
    _touch();
  }

  void toggleEventDone(String id) {
    events = events.map((x) {
      if (x.id != id) return x;
      final c = x.copy();
      c.done = !(x.done ?? false);
      return c;
    }).toList();
    _touch();
  }

  void setCursor(String iso) {
    cursor = iso;
    _touch();
  }

  void setSelected(String iso) {
    selected = iso;
    _touch();
  }

  void goToDate(String iso) {
    cursor = iso;
    selected = iso;
    _touch();
  }

  void setTheme(String v) {
    theme = v;
    _touch();
  }

  void setColorScheme(ColorSchemeId id) {
    colorScheme = id;
    materialYou = true;
    _touch();
  }

  void setMaterialYou(bool v) {
    materialYou = v;
    _touch();
  }

  void setExtraDark(bool v) {
    extraDark = v;
    _touch();
  }

  void setLang(String pref) {
    langPref = pref;
    lang = resolveLang(pref);
    IntlHelper.localeName = lang == Lang.km ? 'km' : 'en';
    _touch();
  }

  void setSetupDone(bool v) {
    setupDone = v;
    _touch();
  }

  void setLastTab(TabId v) {
    lastTab = v;
    _touch();
  }

  void setLastEventsPane(String v) {
    lastEventsPane = v;
    _touch();
  }

  void addWeatherCity(String id) {
    if (weatherCities.contains(id)) return;
    weatherCities = [...weatherCities, id];
    _touch();
  }

  void removeWeatherCity(String id) {
    weatherCities = weatherCities.where((c) => c != id).toList();
    _touch();
  }

  void setNotifyOn(bool v) {
    notifyOn = v;
    _touch();
  }

  void setBackgroundOn(bool v) {
    backgroundOn = v;
    _touch();
  }

  void setLocationOn(bool v) {
    locationOn = v;
    _touch();
  }

  void setAutoLaunchOn(bool v) {
    autoLaunchOn = v;
    _touch();
  }

  void setWeekStartsOn(int v) {
    weekStartsOn = v;
    _touch();
  }

  void setInstalled(bool v) {
    installed = v;
    _touch();
  }

  void clearEventReminders() {
    events = events.map((e) {
      final c = e.copy();
      c.reminderDate = '';
      c.reminderTime = '';
      return c;
    }).toList();
    _touch();
  }

  void resetWeatherCities() {
    weatherCities = [];
    _touch();
  }

  void resetAppData() {
    events = [];
    theme = 'system';
    colorScheme = ColorSchemeId.slate;
    materialYou = true;
    extraDark = false;
    lastEventsPane = 'holidays';
    weatherCities = [];
    installed = false;
    notifyOn = false;
    backgroundOn = false;
    locationOn = false;
    autoLaunchOn = false;
    weekStartsOn = 1;
    _touch();
  }
}
