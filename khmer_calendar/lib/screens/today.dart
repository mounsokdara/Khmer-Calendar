import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import '../widgets/animal.dart';
import '../widgets/holiday_info.dart';
import '../widgets/page_physics.dart';
import '../widgets/sil_mark.dart';
import '../widgets/swipe_delete.dart';
import '../widgets/task_sheet.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, required this.store});
  final AppStore store;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late final PageController _ctrl;
  late int _page;
  bool _fromSwipe = false;
  String? _toast;
  final _anchor = PageAnchor();

  @override
  void initState() {
    super.initState();
    _page = dayIndexOf(fromIso(widget.store.selected)).clamp(0, dayCount() - 1);
    _ctrl = PageController(initialPage: _page);
    widget.store.addListener(_onStore);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    _ctrl.dispose();
    super.dispose();
  }

  void _onStore() {
    if (!mounted) return;
    final wanted = dayIndexOf(fromIso(widget.store.selected)).clamp(0, dayCount() - 1);
    if (!_fromSwipe && wanted != _page) {
      _page = wanted;
      if (_ctrl.hasClients) _ctrl.jumpToPage(wanted);
    }
    setState(() {});
  }

  void _onPage(int i) {
    _page = i;
    final next = isoOf(dayFromIndex(i));
    if (next == widget.store.selected) {
      setState(() {});
      return;
    }
    _fromSwipe = true;
    widget.store.goToDate(next);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fromSwipe = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final lang = store.lang;
    final selected = fromIso(store.selected);
    final today = todayIso();
    final isToday = store.selected == today;
    final L = lunarOf(selected);

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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SilMark(size: 22),
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
            itemCount: dayCount(),
            pageSnapping: false,
            physics: OnePageScrollPhysics(parent: const ClampingScrollPhysics(), anchor: _anchor),
            onPageChanged: _onPage,
            itemBuilder: (ctx, i) {
              return _DayPanel(
                day: dayFromIndex(i),
                store: store,
                onCopy: (text) async {
                  await Clipboard.setData(ClipboardData(text: text));
                  setState(() => _toast = t(lang, 'copied'));
                  await Future<void>.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _toast = null);
                },
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
}

class _DayPanel extends StatelessWidget {
  const _DayPanel({required this.day, required this.store, required this.onCopy});
  final DateTime day;
  final AppStore store;
  final Future<void> Function(String text) onCopy;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final iso = isoOf(day);
    final lunar = lunarOf(day);
    final pair = animalPair(lunar);
    final items = observancesOn(iso, store.events);
    final hols = items.where((e) => e.kind == Kind.holiday).toList();
    final tasks = store.events.where((e) => e.date == iso).toList();
    final wdays = weekdaysFull(lang);
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('${day.day} ${wdays[day.weekday % 7]}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: cs.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lunar.lunarDateText, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => onCopy(lunar.fullText),
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
          elevation: 0,
          color: cs.surfaceContainerLow,
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
            elevation: 0,
            color: cs.primaryContainer,
            child: InkWell(
              onTap: () => showHolidayInfo(context, store, h),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(obsTitle(h, lang), style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
        if (tasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final e in tasks)
            swipeToDelete(
              context: context,
              key: 'day-${e.id}',
              confirm: true,
              lang: lang,
              onDelete: () => store.deleteEvent(e.id),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  value: e.done ?? false,
                  onChanged: (_) => store.toggleEventDone(e.id),
                ),
                title: Text(
                  e.title,
                  style: TextStyle(decoration: e.done == true ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold),
                ),
                onTap: () => showTaskSheet(context, store: store, editing: e),
              ),
            ),
        ],
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
