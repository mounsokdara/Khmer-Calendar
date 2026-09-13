import 'package:flutter/material.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/task_sheet.dart';
import 'today.dart';

class MonthsPage extends StatelessWidget {
  const MonthsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cursor = fromIso(store.cursor);
    final selected = store.selected;
    final grid = monthGrid(cursor, store.weekStartsOn);
    final heads = weekdaysStarting(lang, store.weekStartsOn);
    final obs = monthObservances(cursor, store.events);
    final cs = Theme.of(context).colorScheme;
    final today = todayIso();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(onPressed: () => store.setCursor(isoOf(addMonths(cursor, -1))), icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: TextButton(
                  onPressed: () => _pickMonth(context),
                  child: Text(formatMonthTitle(cursor, lang), style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              IconButton(onPressed: () => store.setCursor(isoOf(addMonths(cursor, 1))), icon: const Icon(Icons.chevron_right)),
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
        Padding(
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
                  inMonth: sameMonth(d, cursor),
                  selected: isoOf(d) == selected,
                  isToday: isoOf(d) == today,
                  store: store,
                ),
            ],
          ),
        ),
        Expanded(
          child: obs.isEmpty
              ? Center(child: Text(t(lang, 'noHolidaysMonth'), style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.builder(
                  itemCount: obs.length,
                  itemBuilder: (ctx, i) {
                    final item = obs[i];
                    final tone = colorKind(item);
                    return ListTile(
                      selected: item.date == selected,
                      leading: CircleAvatar(
                        backgroundColor: dayToneColor(context, tone).withValues(alpha: 0.15),
                        child: Text(
                          '${fromIso(item.date).day}',
                          style: TextStyle(color: dayToneColor(context, tone), fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(obsTitle(item, lang)),
                      onTap: () {
                        store.goToDate(item.date);
                        if (item.kind == Kind.event && item.eventId != null) {
                          final ev = store.events.where((e) => e.id == item.eventId).firstOrNull;
                          if (ev != null) showTaskSheet(context, store: store, editing: ev);
                        } else {
                          showHolidayInfo(context, store, item);
                        }
                      },
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.isToday,
    required this.store,
  });
  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool isToday;
  final AppStore store;

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
      onTap: () => store.goToDate(iso),
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
            Text('${day.day}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
            Text(
              '${lunar.moonDay}${lunar.moonStatus == 'កើត' ? 'ក' : 'រ'}',
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9),
            ),
            if (lunar.isSilDay || mark)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: lunar.isSilDay ? cs.tertiary : cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
