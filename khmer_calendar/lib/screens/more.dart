import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../location.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/overlay_page.dart';
import '../widgets/scheme_chips.dart';
import '../widgets/segmented_list.dart';

const _release = 'https://github.com/mounsokdara/Khmer-Carlendar/releases/latest/download';

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(t(lang, 'moreTitle'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            SegmentedGroup(
              padding: EdgeInsets.zero,
              children: [
                SegmentedTile(
                  leading: const Icon(Icons.settings),
                  title: t(lang, 'settingsTitle'),
                  subtitle: t(lang, 'settingsSub'),
                  onTap: () => context.push('/settings'),
                ),
                SegmentedTile(
                  leading: const Icon(Icons.build),
                  title: t(lang, 'toolsTitle'),
                  subtitle: t(lang, 'toolsPageSub'),
                  onTap: () => context.push('/tools'),
                ),
                SegmentedTile(
                  leading: const Icon(Icons.info_outline),
                  title: t(lang, 'aboutTitle'),
                  subtitle: t(lang, 'aboutSub'),
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 16),
              SegmentedGroup(
                padding: EdgeInsets.zero,
                children: [
                  SegmentedTile(
                    leading: const Icon(Icons.install_mobile),
                    title: t(lang, 'installerTitle'),
                    subtitle: t(lang, 'installerSub'),
                    onTap: () => context.push('/download'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
        final days = weekdaysFull(lang);
        return OverlayScaffold(
          title: t(lang, 'settingsTitle'),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SegmentedGroup(
                children: [
                  SegmentedTile(
                    leading: const Icon(Icons.palette),
                    title: t(lang, 'themePageTitle'),
                    subtitle: t(lang, 'themePageSub'),
                    onTap: () => context.push('/settings/theme'),
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.translate),
                    title: t(lang, 'language'),
                    subtitle: store.langPref == 'auto' ? t(lang, 'langAuto') : (store.langPref == 'km' ? 'ខ្មែរ' : 'English'),
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (ctx) => WatchStore(
                          store: store,
                          builder: (c, s) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: LangRadios(
                                store: s,
                                uiLang: s.lang,
                                onPicked: () => Navigator.pop(ctx),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.view_week),
                    title: t(lang, 'weekStartsOn'),
                    subtitle: days[store.weekStartsOn],
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
                  SegmentedTile(
                    leading: const Icon(Icons.verified_user),
                    title: t(lang, 'privacyTitle'),
                    subtitle: t(lang, 'privacySub'),
                    onTap: () => context.push('/settings/privacy'),
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.delete_sweep),
                    title: t(lang, 'clearTitle'),
                    subtitle: t(lang, 'clearSub'),
                    onTap: () => context.push('/settings/clear'),
                  ),
                  if (kIsWeb)
                    SegmentedTile(
                      leading: const Icon(Icons.install_mobile),
                      title: t(lang, 'installerTitle'),
                      subtitle: t(lang, 'installerSub'),
                      onTap: () => context.push('/download'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ThemePage extends StatelessWidget {
  const ThemePage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
        return OverlayScaffold(
          title: t(lang, 'themePageTitle'),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: LayoutBuilder(
                  builder: (ctx, box) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: box.maxWidth),
                        child: SegmentedButton<String>(
                          showSelectedIcon: box.maxWidth > 380,
                          segments: [
                            ButtonSegment(value: 'light', label: Text(t(lang, 'modeLight'))),
                            ButtonSegment(value: 'dark', label: Text(t(lang, 'modeDark'))),
                            ButtonSegment(value: 'system', label: Text(t(lang, 'modeSystem'))),
                          ],
                          selected: {store.theme},
                          onSelectionChanged: (s) => store.setTheme(s.first),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SegmentedGroup(
                children: [
                  SwitchListTile(
                    title: Text(t(lang, 'materialYou')),
                    subtitle: Text(t(lang, 'materialYouSub')),
                    value: store.materialYou,
                    onChanged: store.setMaterialYou,
                  ),
                ],
              ),
              SchemeChipScroller(store: store),
              SegmentedGroup(
                children: [
                  SwitchListTile(
                    title: Text(t(lang, 'extraDark')),
                    subtitle: Text(t(lang, 'extraDarkSub')),
                    value: store.extraDark,
                    onChanged: store.setExtraDark,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ColorRow(
                title: t(lang, 'accent'),
                subtitle: t(lang, 'accentSub'),
                value: store.accentColor,
                disabled: store.materialYou,
                onPick: () => showColorPicker(
                  context,
                  lang: lang,
                  title: t(lang, 'accent'),
                  value: store.accentColor,
                  onSave: store.setAccentColor,
                ),
              ),
              ColorRow(
                title: t(lang, 'highlight'),
                subtitle: t(lang, 'highlightSub'),
                value: store.highlightColor,
                disabled: store.materialYou,
                onPick: () => showColorPicker(
                  context,
                  lang: lang,
                  title: t(lang, 'highlight'),
                  value: store.highlightColor,
                  onSave: store.setHighlightColor,
                ),
              ),
              Opacity(
                opacity: store.materialYou ? 0.38 : 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t(lang, 'highlightAlpha'), style: Theme.of(context).textTheme.titleSmall),
                      Text(t(lang, 'highlightAlphaSub'), style: Theme.of(context).textTheme.bodySmall),
                      Slider(
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '${(store.highlightAlpha * 100).round()}%',
                        value: (store.highlightAlpha * 100).clamp(0, 100),
                        onChanged: store.materialYou ? null : (n) => store.setHighlightAlpha(n / 100),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
        return OverlayScaffold(
          title: t(lang, 'privacyTitle'),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SegmentedGroup(
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
                    onChanged: (v) async {
                      if (!v) {
                        store.setLocationOn(false);
                        return;
                      }
                      store.setLocationOn(true);
                      final r = await requestNearbyCity(store);
                      if (r == GpsResult.denied || r == GpsResult.disabled || r == GpsResult.failed) {
                        store.setLocationOn(false);
                      }
                      if (context.mounted) showGpsSnack(context, store.lang, r);
                    },
                  ),
                  SwitchListTile(
                    title: Text(t(lang, 'autoLaunch')),
                    subtitle: Text(t(lang, 'autoLaunchSub')),
                    value: store.autoLaunchOn,
                    onChanged: kIsWeb ? null : store.setAutoLaunchOn,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClearPage extends StatelessWidget {
  const ClearPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SegmentedGroup(
                children: [
                  SegmentedTile(
                    leading: const Icon(Icons.cached),
                    title: t(lang, 'clearCache'),
                    subtitle: t(lang, 'clearCacheSub'),
                    onTap: () => confirm('confirmClearCache', () {}),
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.alarm_off),
                    title: t(lang, 'clearReminders'),
                    subtitle: t(lang, 'clearRemindersSub'),
                    onTap: () => confirm('confirmClearReminders', store.clearEventReminders),
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.cloud_off),
                    title: t(lang, 'clearWeather'),
                    subtitle: t(lang, 'clearWeatherSub'),
                    onTap: () => confirm('confirmClearWeather', store.resetWeatherCities),
                  ),
                  SegmentedTile(
                    leading: Icon(Icons.delete_forever, color: cs.error),
                    title: t(lang, 'clearAll'),
                    subtitle: t(lang, 'clearAllSub'),
                    danger: true,
                    onTap: () => confirm('confirmClearAll', store.resetAppData),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
        return OverlayScaffold(
          title: t(lang, 'toolsTitle'),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SegmentedGroup(
                children: [
                  SegmentedTile(
                    leading: const Icon(Icons.calculate),
                    title: t(lang, 'calcTitle'),
                    subtitle: t(lang, 'calcSub'),
                    onTap: () => context.push('/tools/datecalculator'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
    widget.store.addListener(_onStore);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: widget.store,
      builder: (context, store) {
        final lang = store.lang;
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
            child: ListTile(
              title: Text(t(lang, 'calcFrom')),
              subtitle: Text(lang == Lang.en ? '${lunarLabel(from, lang)}\n${gregorianLabel(a, lang)}' : '${lunarFrom.lunarDateText}\n${lunarFrom.gregorianDateText}'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: cs.surfaceContainerLow,
            child: ListTile(
              title: Text(t(lang, 'calcTo')),
              subtitle: Text(lang == Lang.en ? '${lunarLabel(to, lang)}\n${gregorianLabel(b, lang)}' : '${lunarTo.lunarDateText}\n${lunarTo.gregorianDateText}'),
            ),
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
            child: ListTile(
              title: Text(shifted),
              subtitle: Text(lang == Lang.en ? lunarLabel(shifted, lang) : shiftedLunar.lunarDateText),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
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
              SegmentedGroup(
                padding: EdgeInsets.zero,
                children: [
                  for (final p in packs)
                    SegmentedTile(
                      leading: Icon(p.$3),
                      title: t(lang, p.$4),
                      subtitle: t(lang, p.$5),
                      trailing: const Icon(Icons.download),
                      onTap: () => launchUrl(Uri.parse('$_release/${p.$2}'), mode: LaunchMode.externalApplication),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
        return OverlayScaffold(
          title: t(lang, 'aboutTitle'),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SegmentedGroup(
                children: [
                  SegmentedTile(
                    leading: const Icon(Icons.person_outline),
                    title: t(lang, 'createdBy'),
                    subtitle: appAuthor,
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.tag),
                    title: t(lang, 'buildVersion'),
                    subtitle: '$appVersion ($appBuildNumber)',
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: t(lang, 'openSourceLicense'),
                    subtitle: t(lang, 'mitLicense'),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => context.push('/license'),
                  ),
                  SegmentedTile(
                    leading: const Icon(Icons.code),
                    title: t(lang, 'sourceCode'),
                    subtitle: appSourceUrl,
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => launchUrl(Uri.parse(appSourceUrl), mode: LaunchMode.externalApplication),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class OssLicensePage extends StatelessWidget {
  const OssLicensePage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;
        final cs = Theme.of(context).colorScheme;
        return OverlayScaffold(
          title: t(lang, 'openSourceLicense'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Text(t(lang, 'mitLicense'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SelectableText(
                mitLicenseText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: cs.onSurface,
                    ),
              ),
            ],
          ),
        );
      },
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
  void initState() {
    super.initState();
    widget.store.addListener(_onStore);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

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
                LangRadios(store: store, uiLang: ui),
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
                    if (!v) {
                      setState(() => gps = false);
                      store.setLocationOn(false);
                      return;
                    }
                    setState(() => gps = true);
                    final r = await requestNearbyCity(store);
                    if (!mounted) return;
                    final ok = r == GpsResult.added || r == GpsResult.already;
                    setState(() => gps = ok);
                    if (!ok) store.setLocationOn(false);
                    if (!context.mounted) return;
                    showGpsSnack(context, store.lang, r);
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
