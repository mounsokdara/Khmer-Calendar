import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../location.dart';
import '../net.dart';
import '../permissions.dart';
import '../reminders.dart';
import '../store.dart';
import '../theme.dart';
import '../web_install.dart';
import '../widgets/os_logo.dart';
import '../widgets/overlay_page.dart';
import '../widgets/scheme_chips.dart';
import '../widgets/segmented_list.dart';
import '../widgets/dialog_actions.dart';

const _release = 'https://github.com/mounsokdara/Khmer-Calendar/releases/latest/download';

Future<void> openPackDownload(BuildContext context, {required Lang lang, required String file}) async {
  if (NetStatus.isOffline) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(lang, 'downloadOffline'))));
    return;
  }
  await launchUrl(Uri.parse('$_release/$file'), mode: LaunchMode.externalApplication);
}

Future<void> openBrowserInstall(BuildContext context, {required AppStore store, required Lang lang}) async {
  if (browserIsStandalone()) {
    store.setInstalled(true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(lang, 'exportInstalled'))));
    }
    return;
  }
  final ok = await promptBrowserInstall();
  if (ok) {
    store.setInstalled(true);
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      title: Text(t(lang, 'shortcutTitle')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t(lang, 'shortcutAsk')),
          const SizedBox(height: 12),
          Text(t(lang, 'shortcutAndroid')),
          const SizedBox(height: 8),
          Text(t(lang, 'shortcutIos')),
          const SizedBox(height: 8),
          Text(t(lang, 'shortcutDesktop')),
        ],
      ),
      actions: equalDialogActions([
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx),
          style: dialogBtnStyle(),
          child: dlgLabel(t(lang, 'cancel')),
        ),
        FilledButton(
          onPressed: () {
            store.setInstalled(true);
            Navigator.pop(ctx);
          },
          style: dialogBtnStyle(),
          child: dlgLabel(t(lang, 'shortcutAdd')),
        ),
      ]),
    ),
  );
}

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
                    leading: const Icon(Icons.notifications_outlined),
                    title: t(lang, 'notifyPageTitle'),
                    subtitle: t(lang, 'notifyPageSub'),
                    onTap: () => context.push('/settings/notifications'),
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
                  SegmentedSwitch(
                    icon: Icons.wallpaper,
                    title: t(lang, 'dynamicColor'),
                    subtitle: t(lang, 'dynamicColorSub'),
                    value: store.dynamicColor,
                    onChanged: store.setDynamicColor,
                  ),
                ],
              ),
              IgnorePointer(
                ignoring: store.dynamicColor,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: store.dynamicColor ? 0.38 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedGroup(
                        children: [
                          SegmentedSwitch(
                            icon: Icons.palette,
                            title: t(lang, 'materialYou'),
                            subtitle: t(lang, 'materialYouSub'),
                            value: store.materialYou,
                            onChanged: store.dynamicColor ? null : store.setMaterialYou,
                          ),
                        ],
                      ),
                      SchemeChipScroller(store: store),
                      SegmentedGroup(
                        children: [
                          SegmentedSwitch(
                            icon: Icons.contrast,
                            title: t(lang, 'extraDark'),
                            subtitle: t(lang, 'extraDarkSub'),
                            value: store.extraDark,
                            onChanged: store.dynamicColor ? null : store.setExtraDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SegmentedGroup(
                        children: [
                          ColorRow(
                            title: t(lang, 'accent'),
                            subtitle: t(lang, 'accentSub'),
                            value: store.accentColor,
                            icon: Icons.brush,
                            disabled: store.materialYou && !store.dynamicColor,
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
                            icon: Icons.highlight,
                            disabled: store.materialYou && !store.dynamicColor,
                            onPick: () => showColorPicker(
                              context,
                              lang: lang,
                              title: t(lang, 'highlight'),
                              value: store.highlightColor,
                              onSave: store.setHighlightColor,
                            ),
                          ),
                        ],
                      ),
                      Opacity(
                        opacity: store.materialYou && !store.dynamicColor ? 0.38 : 1,
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
                                onChanged: (store.materialYou || store.dynamicColor)
                                    ? null
                                    : (n) => store.setHighlightAlpha(n / 100),
                              ),
                            ],
                          ),
                        ),
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

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key, required this.store});
  final AppStore store;

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  void initState() {
    super.initState();
    keepOnlyGranted(widget.store).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
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
                  SegmentedSwitch(
                    icon: Icons.notifications,
                    title: t(lang, 'permNotify'),
                    subtitle: t(lang, 'permNotifySub'),
                    value: store.notifyOn,
                    onChanged: (v) async {
                      if (!v) {
                        store.setNotifyOn(false);
                        await cancelAllReminders();
                        return;
                      }
                      final ok = await requestNotifications(store);
                      if (!ok && context.mounted) {
                        await promptIfDenied(store, context: context, kind: 'notify', allowed: notificationsAllowed);
                        store.setNotifyOn(await notificationsAllowed());
                      }
                      if (context.mounted) showPermSnack(context, lang, 'notify', store.notifyOn);
                    },
                  ),
                  SegmentedSwitch(
                    icon: Icons.sync,
                    title: t(lang, 'permBackground'),
                    subtitle: t(lang, 'permBackgroundSub'),
                    value: store.backgroundOn,
                    onChanged: (v) async {
                      if (!v) {
                        await stopBackground(store);
                        return;
                      }
                      if (kIsWeb) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(lang, 'webBgBlock'))));
                        }
                        return;
                      }
                      final ok = await requestBackground(store, context: context);
                      if (!ok && context.mounted) {
                        await promptIfDenied(store, context: context, kind: 'background', allowed: backgroundAllowed);
                        store.setBackgroundOn(await backgroundAllowed());
                      }
                      if (context.mounted) showPermSnack(context, lang, 'background', store.backgroundOn);
                    },
                  ),
                  SegmentedSwitch(
                    icon: Icons.rocket_launch,
                    title: t(lang, 'autoLaunch'),
                    subtitle: t(lang, 'autoLaunchSub'),
                    value: store.autoLaunchOn,
                    onChanged: (v) async {
                      if (!v) {
                        await stopAutoLaunch(store);
                        return;
                      }
                      if (kIsWeb) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(lang, 'webBgBlock'))));
                        }
                        return;
                      }
                      final ok = await requestAutoLaunch(store, context: context);
                      if (!ok && context.mounted) {
                        await promptIfDenied(store, context: context, kind: 'auto', allowed: autoLaunchAllowed);
                        store.setAutoLaunchOn(await autoLaunchAllowed());
                      }
                      if (context.mounted) showPermSnack(context, lang, 'auto', store.autoLaunchOn);
                    },
                  ),
                  SegmentedSwitch(
                    icon: Icons.location_on,
                    title: t(lang, 'permLocation'),
                    subtitle: t(lang, 'permLocationSub'),
                    value: store.locationOn,
                    onChanged: (v) async {
                      if (!v) {
                        store.setLocationOn(false);
                        return;
                      }
                      final r = await requestLocationPerm(store);
                      if (!store.locationOn && context.mounted) {
                        await promptIfDenied(store, context: context, kind: 'location', allowed: locationAllowed);
                        store.setLocationOn(await locationAllowed());
                      }
                      if (context.mounted) showGpsSnack(context, store.lang, store.locationOn ? r : GpsResult.denied);
                    },
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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: store,
      builder: (context, store) {
        final lang = store.lang;

        Future<void> toggle(bool v, void Function(bool) set) async {
          if (!v) {
            set(false);
            await syncReminders(store);
            return;
          }
          if (!store.notifyOn) {
            final ok = await requestNotifications(store);
            if (!ok && context.mounted) {
              await promptIfDenied(store, context: context, kind: 'notify', allowed: notificationsAllowed);
            }
            if (!store.notifyOn) return;
          }
          set(true);
          await syncReminders(store);
        }

        return OverlayScaffold(
          title: t(lang, 'notifyPageTitle'),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SegmentedGroup(
                children: [
                  SegmentedSwitch(
                    icon: Icons.event,
                    title: t(lang, 'remindEvents'),
                    subtitle: t(lang, 'remindEventsSub'),
                    value: store.notifyEvents,
                    onChanged: (v) => toggle(v, store.setNotifyEvents),
                  ),
                  SegmentedSwitch(
                    icon: Icons.celebration,
                    title: t(lang, 'remindHolidays'),
                    subtitle: t(lang, 'remindHolidaysSub'),
                    value: store.notifyHolidays,
                    onChanged: (v) => toggle(v, store.setNotifyHolidays),
                  ),
                  SegmentedSwitch(
                    icon: Icons.task_alt,
                    title: t(lang, 'remindTasks'),
                    subtitle: t(lang, 'remindTasksSub'),
                    value: store.notifyTasks,
                    onChanged: (v) => toggle(v, store.setNotifyTasks),
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
              actions: equalDialogActions([
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: dialogBtnStyle(),
                  child: dlgLabel(t(lang, 'cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: dialogBtnStyle(),
                  child: dlgLabel(t(lang, 'ok')),
                ),
              ]),
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
          ('android', 'KhmerCalendar.apk', 'exportApk', 'exportApkSub'),
          ('windows', 'KhmerCalendar-windows.zip', 'exportWindows', 'exportWindowsSub'),
          ('macos', 'KhmerCalendar.dmg', 'exportMac', 'exportMacSub'),
          ('linux', 'KhmerCalendar-linux.tar.gz', 'exportLinux', 'exportLinuxSub'),
          ('project', 'KhmerCalendar-project.zip', 'downloadProject', 'downloadProjectSub'),
        ];
        return OverlayScaffold(
          title: t(lang, 'downloadTitle'),
          body: ValueListenableBuilder<bool>(
            valueListenable: NetStatus.online,
            builder: (context, online, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(t(lang, 'downloadSub')),
                  const SizedBox(height: 12),
                  if (kIsWeb) ...[
                    SegmentedGroup(
                      padding: EdgeInsets.zero,
                      children: [
                        SegmentedTile(
                          leading: const Icon(Icons.install_mobile),
                          title: t(lang, store.installed || browserIsStandalone() ? 'exportInstalled' : 'exportBrowser'),
                          subtitle: t(lang, 'exportBrowserSub'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => openBrowserInstall(context, store: store, lang: lang),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  SegmentedGroup(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final p in packs)
                        SegmentedTile(
                          dim: !online,
                          leading: p.$1 == 'project' ? const Icon(Icons.folder_zip) : OsLogo(p.$1),
                          title: t(lang, p.$3),
                          subtitle: t(lang, p.$4),
                          trailing: const Icon(Icons.download),
                          onTap: () => openPackDownload(context, lang: lang, file: p.$2),
                        ),
                    ],
                  ),
                ],
              );
            },
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
                  SegmentedTile(
                    leading: const Icon(Icons.language),
                    title: t(lang, 'website'),
                    subtitle: appWebsiteUrl,
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => launchUrl(Uri.parse(appWebsiteUrl), mode: LaunchMode.externalApplication),
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

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key, required this.store});
  final AppStore store;

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  String step = 'language';
  bool notify = false;
  bool bg = false;
  bool auto = false;
  bool gps = false;
  bool busy = false;
  String asking = '';

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

  Future<void> _askNotify(bool v) async {
    final store = widget.store;
    if (!v) {
      setState(() => notify = false);
      store.setNotifyOn(false);
      await cancelAllReminders();
      return;
    }
    await requestNotifications(store);
    if (!mounted) return;
    if (!store.notifyOn) {
      if (await promptIfDenied(store, context: context, kind: 'notify', allowed: notificationsAllowed)) {
        if (!mounted) return;
        await requestNotifications(store);
      }
    }
    if (!mounted) return;
    setState(() => notify = store.notifyOn);
    showPermSnack(context, store.lang, 'notify', store.notifyOn);
  }

  Future<void> _askBg(bool v) async {
    final store = widget.store;
    if (!v) {
      setState(() => bg = false);
      await stopBackground(store);
      return;
    }
    if (kIsWeb) {
      setState(() => bg = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(store.lang, 'webBgBlock'))));
      }
      return;
    }
    await requestBackground(store, context: context);
    if (!mounted) return;
    if (!store.backgroundOn) {
      if (await promptIfDenied(store, context: context, kind: 'background', allowed: backgroundAllowed)) {
        if (!mounted) return;
        await requestBackground(store, context: context);
      }
    }
    if (!mounted) return;
    setState(() => bg = store.backgroundOn);
    showPermSnack(context, store.lang, 'background', store.backgroundOn);
  }

  Future<void> _askAuto(bool v) async {
    final store = widget.store;
    if (!v) {
      setState(() => auto = false);
      await stopAutoLaunch(store);
      return;
    }
    if (kIsWeb) {
      setState(() => auto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(store.lang, 'webBgBlock'))));
      }
      return;
    }
    await requestAutoLaunch(store, context: context);
    if (!mounted) return;
    if (!store.autoLaunchOn) {
      if (await promptIfDenied(store, context: context, kind: 'auto', allowed: autoLaunchAllowed)) {
        if (!mounted) return;
        await requestAutoLaunch(store, context: context);
      }
    }
    if (!mounted) return;
    setState(() => auto = store.autoLaunchOn);
    showPermSnack(context, store.lang, 'auto', store.autoLaunchOn);
  }

  Future<void> _askGps(bool v) async {
    final store = widget.store;
    if (!v) {
      setState(() => gps = false);
      store.setLocationOn(false);
      return;
    }
    final r = await requestLocationPerm(store);
    if (!mounted) return;
    if (!store.locationOn) {
      await promptIfDenied(store, context: context, kind: 'location', allowed: locationAllowed);
    }
    if (!mounted) return;
    setState(() => gps = store.locationOn);
    showGpsSnack(context, store.lang, store.locationOn ? r : GpsResult.denied);
  }

  Future<void> _continue() async {
    if (busy) return;
    final store = widget.store;
    setState(() {
      busy = true;
      asking = 'askingNotify';
    });
    final allOk = await requestAllPermissions(
      store,
      context: context,
      onStep: (key) {
        if (!mounted) return;
        setState(() {
          asking = key;
          notify = store.notifyOn;
          bg = store.backgroundOn;
          auto = store.autoLaunchOn;
          gps = store.locationOn;
        });
      },
    );
    if (!mounted) return;
    setState(() {
      notify = store.notifyOn;
      bg = store.backgroundOn;
      auto = store.autoLaunchOn;
      gps = store.locationOn;
      busy = false;
      asking = '';
    });
    if (!allOk) return;
    store.setSetupDone(true);
    if (!mounted) return;
    context.go('/months');
  }

  Future<void> _skip() async {
    if (busy) return;
    final store = widget.store;
    setState(() => busy = true);
    await keepOnlyGranted(store);
    if (!mounted) return;
    store.setSetupDone(true);
    context.go('/months');
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
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: NetStatus.online,
                    builder: (context, online, _) {
                      return ListView(
                        children: [
                          if (kIsWeb)
                            SegmentedGroup(
                              padding: EdgeInsets.zero,
                              children: [
                                SegmentedTile(
                                  leading: const Icon(Icons.install_mobile),
                                  title: t(ui, 'exportBrowser'),
                                  subtitle: t(ui, 'exportBrowserSub'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => openBrowserInstall(context, store: store, lang: ui),
                                ),
                              ],
                            ),
                          if (kIsWeb) const SizedBox(height: 12),
                          SegmentedGroup(
                            padding: EdgeInsets.zero,
                            children: [
                              for (final p in [
                                ('android', 'KhmerCalendar.apk', 'exportApk', 'exportApkSub'),
                                ('windows', 'KhmerCalendar-windows.zip', 'exportWindows', 'exportWindowsSub'),
                                ('macos', 'KhmerCalendar.dmg', 'exportMac', 'exportMacSub'),
                                ('linux', 'KhmerCalendar-linux.tar.gz', 'exportLinux', 'exportLinuxSub'),
                              ])
                                SegmentedTile(
                                  dim: !online,
                                  leading: OsLogo(p.$1),
                                  title: t(ui, p.$3),
                                  subtitle: t(ui, p.$4),
                                  trailing: const Icon(Icons.download),
                                  onTap: () => openPackDownload(context, lang: ui, file: p.$2),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                FilledButton(
                  onPressed: () => setState(() => step = 'permissions'),
                  child: Text(t(ui, 'setupNext')),
                ),
                TextButton(onPressed: () => setState(() => step = 'permissions'), child: Text(t(ui, 'setupSkip'))),
              ] else ...[
                Text(t(ui, 'setupPermTitle'), style: Theme.of(context).textTheme.headlineSmall),
                Text(t(ui, 'setupPermSub')),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.notifications_outlined),
                        title: Text(t(ui, 'setupAllowNotify')),
                        subtitle: Text(t(ui, 'permNotifySub')),
                        value: notify,
                        onChanged: busy ? null : _askNotify,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.sync),
                        title: Text(t(ui, 'setupAllowBackground')),
                        subtitle: Text(t(ui, 'permBackgroundSub')),
                        value: bg,
                        onChanged: busy ? null : _askBg,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.rocket_launch_outlined),
                        title: Text(t(ui, 'setupAllowAutoLaunch')),
                        subtitle: Text(t(ui, 'autoLaunchSub')),
                        value: auto,
                        onChanged: busy ? null : _askAuto,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.location_on_outlined),
                        title: Text(t(ui, 'setupAllowGps')),
                        subtitle: Text(t(ui, 'permLocationSub')),
                        value: gps,
                        onChanged: busy ? null : _askGps,
                      ),
                    ],
                  ),
                ),
                if (busy) ...[
                  const LinearProgressIndicator(minHeight: 3),
                  const SizedBox(height: 8),
                  Text(t(ui, asking.isEmpty ? 'loading' : asking), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  onPressed: busy ? null : _continue,
                  child: Text(t(ui, 'setupContinue')),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: busy ? null : _skip,
                  child: Text(t(ui, 'setupSkip')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
