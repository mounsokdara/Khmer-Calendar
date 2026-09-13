import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/sil_mark.dart';
import '../widgets/task_sheet.dart';
import 'today.dart';

class MonthsPage extends StatefulWidget {
  const MonthsPage({super.key, required this.store});
  final AppStore store;

  @override
  State<MonthsPage> createState() => _MonthsPageState();
}

class _MonthsPageState extends State<MonthsPage> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: 1);
    widget.store.addListener(_onStore);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    _ctrl.dispose();
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  AppStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cursor = fromIso(store.cursor);
    final selected = store.selected;
    final heads = weekdaysStarting(lang, store.weekStartsOn);
    final obs = monthObservances(cursor, store.events).where((i) => i.kind != Kind.sil).toList();
    final cs = Theme.of(context).colorScheme;
    final today = todayIso();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _pickMonth(context),
                  child: Text(formatMonthTitle(cursor, lang), style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              if (!sameMonth(cursor, fromIso(today)))
                IconButton(
                  tooltip: t(lang, 'today'),
                  onPressed: () => store.goToDate(today),
                  icon: const Icon(Icons.today),
                ),
              IconButton(
                tooltip: t(lang, 'addTask'),
                onPressed: () => showTaskSheet(context, store: store, date: selected),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              for (final h in heads)
                Expanded(
                  child: Center(
                    child: Text(h, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 292,
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) {
              if (i == 1) return;
              store.setCursor(isoOf(addMonths(cursor, i == 2 ? 1 : -1)));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_ctrl.hasClients) _ctrl.jumpToPage(1);
              });
            },
            itemCount: 3,
            itemBuilder: (ctx, i) {
              final month = addMonths(cursor, i - 1);
              return _MonthGrid(
                month: month,
                store: store,
                interactive: i == 1,
              );
            },
          ),
        ),
        Expanded(
          child: obs.isEmpty
              ? Center(child: Text(t(lang, 'noHolidaysMonth'), style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: obs.length,
                  itemBuilder: (ctx, i) {
                    final item = obs[i];
                    final tone = colorKind(item);
                    return Card(
                      elevation: 0,
                      color: cs.surfaceContainerLow,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        selected: item.date == selected,
                        leading: CircleAvatar(
                          backgroundColor: dayToneColor(context, tone).withValues(alpha: 0.15),
                          child: Text(
                            '${fromIso(item.date).day}',
                            style: TextStyle(color: dayToneColor(context, tone), fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(obsTitle(item, lang), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        onTap: () {
                          store.goToDate(item.date);
                          if (item.kind == Kind.event && item.eventId != null) {
                            final ev = store.events.where((e) => e.id == item.eventId).firstOrNull;
                            if (ev != null) showTaskSheet(context, store: store, editing: ev);
                          } else {
                            showHolidayInfo(context, store, item);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final lang = store.lang;
    final cursor = fromIso(store.cursor);
    var month = cursor.month - 1;
    var year = cursor.year;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return SizedBox(
              height: 280,
              child: Column(
                children: [
                  Text(t(lang, 'change'), style: Theme.of(ctx).textTheme.titleMedium),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 44,
                            perspective: 0.002,
                            onSelectedItemChanged: (i) => setSt(() => month = i),
                            controller: FixedExtentScrollController(initialItem: month),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 12,
                              builder: (_, i) => Center(child: Text(monthsOf(lang)[i])),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 44,
                            perspective: 0.002,
                            onSelectedItemChanged: (i) => setSt(() => year = 1900 + i),
                            controller: FixedExtentScrollController(initialItem: year - 1900),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 200,
                              builder: (_, i) => Center(child: Text(lang == Lang.en ? '${1900 + i}' : khmerNum(1900 + i))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      store.setCursor(isoOf(DateTime(year, month + 1, 1)));
                      Navigator.pop(ctx);
                    },
                    child: Text(t(lang, 'ok')),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.store, required this.interactive});
  final DateTime month;
  final AppStore store;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final grid = monthGrid(month, store.weekStartsOn);
    final today = todayIso();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.92,
        children: [
          for (final d in grid)
            _DayCell(
              day: d,
              inMonth: sameMonth(d, month),
              selected: isoOf(d) == store.selected,
              isToday: isoOf(d) == today,
              store: store,
              interactive: interactive,
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.isToday,
    required this.store,
    required this.interactive,
  });
  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool isToday;
  final AppStore store;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final iso = isoOf(day);
    final tone = dayTone(iso, inMonth);
    final mark = hasDayMark(iso, store.events);
    final lunar = lunarOf(day);
    final cs = Theme.of(context).colorScheme;
    final color = dayToneColor(context, tone);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: !interactive
          ? null
          : () {
              store.goToDate(iso);
              store.setLastTab(TabId.today);
              context.go('/day');
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : (isToday ? cs.secondaryContainer.withValues(alpha: 0.6) : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lunar.isSilDay && inMonth) const SilMark(size: 12) else const SizedBox(height: 12),
            Text('${day.day}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
            Text(
              '${lunar.moonDay}${lunar.moonStatus == 'កើត' ? 'ក' : 'រ'}',
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9),
            ),
            if (mark)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
