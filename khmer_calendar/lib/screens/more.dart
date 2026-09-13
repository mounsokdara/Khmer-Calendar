import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../calendar/chhankitek.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import '../theme.dart';
import '../weather.dart';
import '../widgets/overlay_page.dart';

const _release = 'https://github.com/mounsokdara/Khmer-Carlendar/releases/latest/download';

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(t(lang, 'moreTitle'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: cs.surfaceContainerLow,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(t(lang, 'settingsTitle')),
                subtitle: Text(t(lang, 'settingsSub')),
                onTap: () => context.push('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.build),
                title: Text(t(lang, 'toolsTitle')),
                subtitle: Text(t(lang, 'toolsPageSub')),
                onTap: () => context.push('/tools'),
              ),
            ],
          ),
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: ListTile(
              leading: const Icon(Icons.install_mobile),
              title: Text(t(lang, 'installerTitle')),
              subtitle: Text(t(lang, 'installerSub')),
              onTap: () => context.push('/download'),
            ),
          ),
        ],
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final days = weekdaysFull(lang);
    final cs = Theme.of(context).colorScheme;
    return OverlayScaffold(
      title: t(lang, 'settingsTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: Text(t(lang, 'themePageTitle')),
                  subtitle: Text(t(lang, 'themePageSub')),
                  onTap: () => context.push('/settings/theme'),
                ),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(t(lang, 'language')),
                  subtitle: Text(store.langPref == 'auto' ? t(lang, 'langAuto') : (store.langPref == 'km' ? 'ខ្មែរ' : 'English')),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) => ListView(
                        shrinkWrap: true,
                        children: [
                          for (final p in ['auto', 'km', 'en'])
                            ListTile(
                              leading: Icon(store.langPref == p ? Icons.radio_button_checked : Icons.radio_button_off),
                              title: Text(p == 'auto' ? t(lang, 'langAuto') : (p == 'km' ? 'ខ្មែរ' : 'English')),
                              subtitle: p == 'auto' ? Text(t(lang, 'langAutoSub')) : null,
                              onTap: () {
                                store.setLang(p);
                                Navigator.pop(ctx);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_week),
                  title: Text(t(lang, 'weekStartsOn')),
                  subtitle: Text(days[store.weekStartsOn]),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) => ListView(
                        shrinkWrap: true,
                        children: [
                          for (final d in [0, 1, 6])
                            ListTile(
                              leading: Icon(store.weekStartsOn == d ? Icons.radio_button_checked : Icons.radio_button_off),
                              title: Text(days[d]),
                              onTap: () {
                                store.setWeekStartsOn(d);
                                Navigator.pop(ctx);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: Text(t(lang, 'privacyTitle')),
                  subtitle: Text(t(lang, 'privacySub')),
                  onTap: () => context.push('/settings/privacy'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: Text(t(lang, 'clearTitle')),
                  subtitle: Text(t(lang, 'clearSub')),
                  onTap: () => context.push('/settings/clear'),
                ),
                if (kIsWeb)
                  ListTile(
                    leading: const Icon(Icons.install_mobile),
                    title: Text(t(lang, 'installerTitle')),
                    subtitle: Text(t(lang, 'installerSub')),
                    onTap: () => context.push('/download'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemePage extends StatelessWidget {
  const ThemePage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cs = Theme.of(context).colorScheme;
    return OverlayScaffold(
      title: t(lang, 'themePageTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t(lang, 'modeSystem'), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'light', label: Text(t(lang, 'modeLight'))),
              ButtonSegment(value: 'dark', label: Text(t(lang, 'modeDark'))),
              ButtonSegment(value: 'system', label: Text(t(lang, 'modeSystem'))),
            ],
            selected: {store.theme},
            onSelectionChanged: (s) => store.setTheme(s.first),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: SwitchListTile(
              title: Text(t(lang, 'extraDark')),
              subtitle: Text(t(lang, 'extraDarkSub')),
              value: store.extraDark,
              onChanged: store.brightness == Brightness.dark || store.theme == 'dark' || store.theme == 'system' ? store.setExtraDark : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(t(lang, 'accent'), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final s in schemes)
            Card(
              elevation: 0,
              color: cs.surfaceContainerLow,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: s.circle),
                title: Text(s.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                trailing: store.colorScheme == s.id ? Icon(Icons.check, color: cs.primary) : null,
                selected: store.colorScheme == s.id,
                onTap: () => store.setColorScheme(s.id),
              ),
            ),
        ],
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cs = Theme.of(context).colorScheme;
    return OverlayScaffold(
      title: t(lang, 'privacyTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(t(lang, 'permNotify')),
                  subtitle: Text(t(lang, 'permNotifySub')),
                  value: store.notifyOn,
                  onChanged: store.setNotifyOn,
                ),
                SwitchListTile(
                  title: Text(t(lang, 'permBackground')),
                  subtitle: Text(t(lang, 'permBackgroundSub')),
                  value: store.backgroundOn,
                  onChanged: kIsWeb
                      ? (v) {
                          if (v) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(lang, 'webBgBlock'))));
                          }
                        }
                      : store.setBackgroundOn,
                ),
                SwitchListTile(
                  title: Text(t(lang, 'permLocation')),
                  subtitle: Text(t(lang, 'permLocationSub')),
                  value: store.locationOn,
                  onChanged: store.setLocationOn,
                ),
                SwitchListTile(
                  title: Text(t(lang, 'autoLaunch')),
                  subtitle: Text(t(lang, 'autoLaunchSub')),
                  value: store.autoLaunchOn,
                  onChanged: kIsWeb ? null : store.setAutoLaunchOn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClearPage extends StatelessWidget {
  const ClearPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cs = Theme.of(context).colorScheme;
    Future<void> confirm(String key, VoidCallback run) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t(lang, key)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t(lang, 'cancel'))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t(lang, 'ok'))),
          ],
        ),
      );
      if (ok == true) {
        run();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(lang, 'clearDone'))));
      }
    }

    return OverlayScaffold(
      title: t(lang, 'clearTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.cached),
              title: Text(t(lang, 'clearCache')),
              subtitle: Text(t(lang, 'clearCacheSub')),
              onTap: () => confirm('confirmClearCache', () {}),
            ),
          ),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.alarm_off),
              title: Text(t(lang, 'clearReminders')),
              subtitle: Text(t(lang, 'clearRemindersSub')),
              onTap: () => confirm('confirmClearReminders', store.clearEventReminders),
            ),
          ),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.cloud_off),
              title: Text(t(lang, 'clearWeather')),
              subtitle: Text(t(lang, 'clearWeatherSub')),
              onTap: () => confirm('confirmClearWeather', store.resetWeatherCities),
            ),
          ),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: cs.error),
              title: Text(t(lang, 'clearAll')),
              subtitle: Text(t(lang, 'clearAllSub')),
              onTap: () => confirm('confirmClearAll', store.resetAppData),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cs = Theme.of(context).colorScheme;
    return OverlayScaffold(
      title: t(lang, 'toolsTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: ListTile(
              leading: const Icon(Icons.calculate),
              title: Text(t(lang, 'calcTitle')),
              subtitle: Text(t(lang, 'calcSub')),
              onTap: () => context.push('/tools/datecalculator'),
            ),
          ),
        ],
      ),
    );
  }
}

class DateCalcPage extends StatefulWidget {
  const DateCalcPage({super.key, required this.store});
  final AppStore store;

  @override
  State<DateCalcPage> createState() => _DateCalcPageState();
}

class _DateCalcPageState extends State<DateCalcPage> {
  late String from;
  late String to;
  String shift = '7';

  @override
  void initState() {
    super.initState();
    from = todayIso();
    to = todayIso();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.store.lang;
    final a = fromIso(from);
    final b = fromIso(to);
    final days = b.difference(a).inDays;
    final years = days.abs() ~/ 365;
    final months = (days.abs() % 365) ~/ 30;
    final rest = days.abs() - years * 365 - months * 30;
    final lunarFrom = lunarOf(a);
    final lunarTo = lunarOf(b);
    final shifted = isoOf(addDays(a, int.tryParse(shift) ?? 0));
    final shiftedLunar = lunarOf(fromIso(shifted));
    final cs = Theme.of(context).colorScheme;

    return OverlayScaffold(
      title: t(lang, 'calcTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t(lang, 'calcSub')),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            child: ListTile(
              title: Text(t(lang, 'calcFrom')),
              subtitle: Text(from),
              trailing: const Icon(Icons.event),
              onTap: () async {
                final p = await showDatePicker(context: context, initialDate: a, firstDate: DateTime(1900), lastDate: DateTime(2100));
                if (p != null) setState(() => from = isoOf(p));
              },
            ),
          ),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(t(lang, 'calcTo')),
              subtitle: Text(to),
              trailing: const Icon(Icons.event),
              onTap: () async {
                final p = await showDatePicker(context: context, initialDate: b, firstDate: DateTime(1900), lastDate: DateTime(2100));
                if (p != null) setState(() => to = isoOf(p));
              },
            ),
          ),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(lang, 'calcDuration')),
                  Text('$years ${t(lang, 'calcYears')} · $months ${t(lang, 'calcMonths')} · $rest ${t(lang, 'calcDays')}', style: Theme.of(context).textTheme.titleLarge),
                  Text('$days ${t(lang, 'calcTotalDays')}${days < 0 ? ' · ${t(lang, 'calcPast')}' : ''}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: ListTile(title: Text(t(lang, 'calcFrom')), subtitle: Text('${lunarFrom.lunarDateText}\n${lunarFrom.gregorianDateText}')),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: ListTile(title: Text(t(lang, 'calcTo')), subtitle: Text('${lunarTo.lunarDateText}\n${lunarTo.gregorianDateText}')),
          ),
          const SizedBox(height: 8),
          Text(t(lang, 'calcAdd')),
          Wrap(
            spacing: 8,
            children: [
              for (final n in ['7', '15', '30'])
                ChoiceChip(label: Text('+$n'), selected: shift == n, onSelected: (_) => setState(() => shift = n)),
            ],
          ),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '+'),
            onChanged: (v) => setState(() => shift = v),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: ListTile(title: Text(shifted), subtitle: Text(shiftedLunar.lunarDateText)),
          ),
        ],
      ),
    );
  }
}

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cs = Theme.of(context).colorScheme;
    final packs = [
      ('android', 'KhmerCalendar.apk', Icons.android, 'exportApk', 'exportApkSub'),
      ('windows', 'KhmerCalendar-windows.zip', Icons.desktop_windows, 'exportWindows', 'exportWindowsSub'),
      ('macos', 'KhmerCalendar.dmg', Icons.laptop_mac, 'exportMac', 'exportMacSub'),
      ('linux', 'KhmerCalendar-linux.tar.gz', Icons.computer, 'exportLinux', 'exportLinuxSub'),
      ('project', 'KhmerCalendar-project.zip', Icons.folder_zip, 'downloadProject', 'downloadProjectSub'),
    ];
    return OverlayScaffold(
      title: t(lang, 'downloadTitle'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t(lang, 'nativeAppSub')),
          const SizedBox(height: 12),
          for (final p in packs)
            Card(
              elevation: 0,
              color: cs.surfaceContainerLow,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(p.$3),
                title: Text(t(lang, p.$4), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(t(lang, p.$5)),
                trailing: const Icon(Icons.download),
                onTap: () => launchUrl(Uri.parse('$_release/${p.$2}'), mode: LaunchMode.externalApplication),
              ),
            ),
        ],
      ),
    );
  }
}

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key, required this.store});
  final AppStore store;

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  String step = 'language';
  bool notify = false;
  bool gps = false;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final ui = store.lang;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t(ui, 'appName'), style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (step == 'language') ...[
                Text(t(ui, 'languageTitle'), style: Theme.of(context).textTheme.headlineSmall),
                Text(t(ui, 'welcome')),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: cs.surfaceContainerLow,
                  child: Column(
                    children: [
                      for (final p in ['auto', 'km', 'en'])
                        ListTile(
                          leading: Icon(store.langPref == p ? Icons.radio_button_checked : Icons.radio_button_off),
                          title: Text(p == 'auto' ? t(ui, 'langAuto') : (p == 'km' ? 'ខ្មែរ' : 'English')),
                          subtitle: p == 'auto' ? Text(t(ui, 'langAutoSub')) : null,
                          onTap: () => store.setLang(p),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(onPressed: () => setState(() => step = kIsWeb ? 'install' : 'permissions'), child: Text(t(ui, 'setupNext'))),
              ] else if (step == 'install') ...[
                Text(t(ui, 'setupInstallTitle'), style: Theme.of(context).textTheme.headlineSmall),
                Text(t(ui, 'nativeAppSub')),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    launchUrl(Uri.parse('$_release/KhmerCalendar.apk'), mode: LaunchMode.externalApplication);
                    setState(() => step = 'permissions');
                  },
                  child: Text(t(ui, 'setupInstallAction')),
                ),
                TextButton(onPressed: () => setState(() => step = 'permissions'), child: Text(t(ui, 'setupSkip'))),
              ] else ...[
                Text(t(ui, 'setupPermTitle'), style: Theme.of(context).textTheme.headlineSmall),
                Text(t(ui, 'setupPermSub')),
                SwitchListTile(
                  title: Text(t(ui, 'setupAllowNotify')),
                  value: notify,
                  onChanged: (v) {
                    setState(() => notify = v);
                    store.setNotifyOn(v);
                  },
                ),
                SwitchListTile(
                  title: Text(t(ui, 'setupAllowGps')),
                  value: gps,
                  onChanged: (v) async {
                    setState(() => gps = v);
                    store.setLocationOn(v);
                    if (v) {
                      try {
                        final pos = await Geolocator.getCurrentPosition();
                        store.addWeatherCity(nearestCity(pos.latitude, pos.longitude).id);
                      } catch (_) {}
                    }
                  },
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    store.setSetupDone(true);
                    context.go('/months');
                  },
                  child: Text(t(ui, 'continue')),
                ),
                TextButton(
                  onPressed: () {
                    store.setSetupDone(true);
                    context.go('/months');
                  },
                  child: Text(t(ui, 'setupSkipAnyway')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(t(lang, 'appName'), style: Theme.of(context).textTheme.headlineMedium),
            Text(t(lang, 'splashTag')),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
