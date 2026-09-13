import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import '../widgets/animal.dart';
import '../widgets/task_sheet.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, required this.store});
  final AppStore store;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late final PageController _ctrl;
  String? _toast;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: 10);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final lang = store.lang;
    final selected = fromIso(store.selected);
    final today = todayIso();
    final isToday = store.selected == today;
    final L = lunarOf(selected);
    final days = List.generate(21, (i) => addDays(selected, i - 10));
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              if (!isToday)
                IconButton(
                  tooltip: t(lang, 'today'),
                  onPressed: () => store.goToDate(today),
                  icon: const Icon(Icons.today),
                ),
              if (L.isSilDay)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Chip(label: Text(t(lang, 'silDay')), avatar: const Icon(Icons.brightness_2, size: 16)),
                ),
              const Spacer(),
              IconButton(
                tooltip: t(lang, 'addTask'),
                onPressed: () => showTaskSheet(context, store: store, date: store.selected),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) {
              if (i >= 0 && i < days.length) store.goToDate(isoOf(days[i]));
            },
            itemCount: days.length,
            itemBuilder: (ctx, i) {
              final day = days[i];
              final iso = isoOf(day);
              final lunar = lunarOf(day);
              final pair = animalPair(lunar);
              final items = observancesOn(iso, store.events);
              final hols = items.where((e) => e.kind == Kind.holiday).toList();
              final tasks = store.events.where((e) => e.date == iso).toList();
              final wdays = weekdaysFull(lang);
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text('${day.day} ${wdays[day.weekday % 7]}', style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lunar.lunarDateText, style: Theme.of(ctx).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: lunar.fullText));
                                setState(() => _toast = t(lang, 'copied'));
                                await Future<void>.delayed(const Duration(seconds: 2));
                                if (mounted) setState(() => _toast = null);
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: Text(t(lang, 'copy')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _animalCol(pair[0], lang),
                          Text('X', style: TextStyle(color: cs.outline, fontWeight: FontWeight.w700)),
                          _animalCol(pair[1], lang),
                        ],
                      ),
                    ),
                  ),
                  for (final h in hols) ...[
                    const SizedBox(height: 8),
                    Card(
                      color: cs.primaryContainer,
                      child: ListTile(
                        title: Text(obsTitle(h, lang), style: TextStyle(color: cs.onPrimaryContainer)),
                        onTap: () => showHolidayInfo(context, store, h),
                      ),
                    ),
                  ],
                  if (tasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          for (final e in tasks)
                            ListTile(
                              leading: Checkbox(
                                value: e.done ?? false,
                                onChanged: (_) => store.toggleEventDone(e.id),
                              ),
                              title: Text(
                                e.title,
                                style: TextStyle(decoration: e.done == true ? TextDecoration.lineThrough : null),
                              ),
                              onTap: () => showTaskSheet(context, store: store, editing: e),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        if (_toast != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Chip(label: Text(_toast!)),
          ),
      ],
    );
  }

  Widget _animalCol(String a, Lang lang) {
    return Column(
      children: [
        AnimalArt(animal: a, size: 48),
        const SizedBox(height: 6),
        Text(animalLabel(a, lang)),
      ],
    );
  }
}

Future<void> showHolidayInfo(BuildContext context, AppStore store, Observance item) {
  final lang = store.lang;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(obsTitle(item, lang)),
      content: Text(item.kind == Kind.sil ? t(lang, 'silBlurb') : (lang == Lang.en ? (item.subtitleEn ?? '') : (item.subtitle ?? ''))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t(lang, 'close')))],
    ),
  );
}
