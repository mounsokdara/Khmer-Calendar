import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../calendar/chhankitek.dart';
import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/holiday_info.dart';
import '../widgets/obs_row.dart';
import '../widgets/sil_mark.dart';
import '../widgets/task_sheet.dart';

class MonthsPage extends StatefulWidget {
  const MonthsPage({super.key, required this.store});
  final AppStore store;

  @override
  State<MonthsPage> createState() => _MonthsPageState();
}

class _MonthsPageState extends State<MonthsPage> {
  late final PageController _ctrl;
  bool _expanded = false;
  bool _jumping = false;

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

  void _onMonthPage(int i) {
    if (_jumping || i == 1) return;
    _jumping = true;
    store.setCursor(isoOf(addMonths(fromIso(store.cursor), i == 2 ? 1 : -1)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ctrl.hasClients) _ctrl.jumpToPage(1);
      _jumping = false;
    });
  }

  void _openObs(Observance item) {
    store.goToDate(item.date);
    if (item.kind == Kind.event && item.eventId != null) {
      final ev = store.events.where((e) => e.id == item.eventId).firstOrNull;
      if (ev != null) showTaskSheet(context, store: store, editing: ev);
      return;
    }
    showHolidayInfo(context, store, item);
  }

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final cursor = fromIso(store.cursor);
    final selected = store.selected;
    final items = monthObservances(cursor, store.events).where((i) => i.kind != Kind.sil).toList();
    final holidays = items.where((i) => i.kind != Kind.event).toList();
    final tasks = items.where((i) => i.kind == Kind.event).toList();
    final lunar = lunarOf(cursor);
    final today = todayIso();
    final wide = MediaQuery.sizeOf(context).width >= wideBreak && !_expanded;

    return Column(
      children: [
        _header(lang, cursor, today),
        Expanded(
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _lunarLine(lunar),
                          Expanded(child: _monthBlock(cursor, fill: true)),
                        ],
                      ),
                    ),
                    VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width >= xlBreak ? 400 : 360,
                      child: SingleChildScrollView(child: _sideList(lang, holidays, tasks, selected)),
                    ),
                  ],
                )
              : _expanded
                  ? _monthBlock(cursor, fill: true)
                  : ListView(
                      children: [
                        _lunarLine(lunar),
                        _monthBlock(cursor, fill: false),
                        _sideList(lang, holidays, tasks, selected),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _header(Lang lang, DateTime cursor, String today) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: () => _pickMonth(context),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      formatMonthTitle(cursor, lang),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
          ),
          if (!sameMonth(cursor, fromIso(today)))
            IconButton(
              tooltip: t(lang, 'today'),
              onPressed: () => store.goToDate(today),
              icon: const Icon(Icons.today),
            ),
          IconButton(
            tooltip: _expanded ? t(lang, 'collapse') : t(lang, 'expand'),
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? Icons.close_fullscreen : Icons.open_in_full),
          ),
          IconButton(
            tooltip: t(lang, 'addTask'),
            onPressed: () => showTaskSheet(context, store: store, date: store.selected),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _lunarLine(LunarDay lunar) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(lunar.lunarDateText, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.35)),
          ),
          const SizedBox(width: 12),
          Text(lunar.gregorianDateText, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _monthBlock(DateTime cursor, {required bool fill}) {
    final lang = store.lang;
    final heads = weekdaysStarting(lang, store.weekStartsOn);
    final sunAt = sundayIndex(store.weekStartsOn);
    final cs = Theme.of(context).colorScheme;
    final weekdays = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (var i = 0; i < heads.length; i++)
            Expanded(
              child: Center(
                child: Text(
                  heads[i],
                  style: TextStyle(
                    color: i == sunAt ? const Color(0xFFC62828) : cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    final pages = PageView.builder(
      controller: _ctrl,
      onPageChanged: _onMonthPage,
      itemCount: 3,
      itemBuilder: (ctx, i) {
        final month = addMonths(cursor, i - 1);
        return _MonthGrid(
          month: month,
          store: store,
          interactive: i == 1,
          expanded: _expanded,
          fill: fill,
        );
      },
    );
    if (fill) {
      return Column(
        children: [
          weekdays,
          const SizedBox(height: 4),
          Expanded(child: pages),
        ],
      );
    }
    final w = MediaQuery.sizeOf(context).width;
    final cell = ((w - 16) / 7).clamp(44.0, 68.0);
    return Column(
      children: [
        weekdays,
        const SizedBox(height: 4),
        SizedBox(height: cell * 6.15, child: pages),
      ],
    );
  }

  Widget _sideList(Lang lang, List<Observance> holidays, List<Observance> tasks, String selected) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
          child: Row(
            children: [
              Expanded(child: Text(t(lang, 'events'), style: Theme.of(context).textTheme.titleMedium)),
              CountChip(
                count: holidays.length,
                onTap: () {
                  store.setLastTab(TabId.events);
                  store.setLastEventsPane('holidays');
                  context.go('/events');
                },
              ),
            ],
          ),
        ),
        if (holidays.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Text(t(lang, 'noHolidaysMonth'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          )
        else
          for (final item in holidays)
            ObsRow(
              item: item,
              lang: lang,
              active: item.date == selected,
              onTap: () => _openObs(item),
            ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
          child: Row(
            children: [
              Expanded(child: Text(t(lang, 'tasks'), style: Theme.of(context).textTheme.titleMedium)),
              CountChip(
                count: tasks.length,
                onTap: () {
                  store.setLastTab(TabId.events);
                  store.setLastEventsPane('tasks');
                  context.go('/events');
                },
              ),
            ],
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Text(t(lang, 'noTasksMonth'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          )
        else
          for (final item in tasks)
            ObsRow(
              item: item,
              lang: lang,
              active: item.date == selected,
              onTap: () => _openObs(item),
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
  const _MonthGrid({
    required this.month,
    required this.store,
    required this.interactive,
    required this.expanded,
    required this.fill,
  });
  final DateTime month;
  final AppStore store;
  final bool interactive;
  final bool expanded;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final gridDays = monthGrid(month, store.weekStartsOn);
    final today = todayIso();
    final chips = interactive ? monthObservances(month, store.events).where((i) => i.kind != Kind.sil).toList() : const <Observance>[];
    Widget grid({required double aspect, required bool shrink}) {
      return GridView.count(
        crossAxisCount: 7,
        shrinkWrap: shrink,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: aspect,
        children: [
          for (final d in gridDays)
            _DayCell(
              day: d,
              inMonth: sameMonth(d, month),
              selected: isoOf(d) == store.selected,
              isToday: isoOf(d) == today,
              store: store,
              interactive: interactive,
              expanded: expanded,
              chips: expanded ? chips.where((c) => c.date == isoOf(d)).take(3).toList() : const [],
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: fill
          ? LayoutBuilder(
              builder: (ctx, box) {
                final cellW = box.maxWidth / 7;
                final cellH = box.maxHeight / 6;
                final aspect = cellH > 0 ? cellW / cellH : 0.88;
                return grid(aspect: aspect, shrink: false);
              },
            )
          : grid(aspect: 0.88, shrink: true),
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
    required this.expanded,
    required this.chips,
  });
  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool isToday;
  final AppStore store;
  final bool interactive;
  final bool expanded;
  final List<Observance> chips;

  @override
  Widget build(BuildContext context) {
    final iso = isoOf(day);
    final tone = dayTone(iso, inMonth);
    final mark = hasDayMark(iso, store.events);
    final lunar = lunarOf(day);
    final cs = Theme.of(context).colorScheme;
    final color = dayToneColor(context, tone);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: !interactive
          ? null
          : () {
              store.goToDate(iso);
              store.setLastTab(TabId.today);
              context.go('/day');
            },
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isToday ? cs.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected && !isToday ? Border.all(color: cs.primary, width: 1.5) : null,
          ),
          child: Stack(
            children: [
              if (lunar.isSilDay && inMonth)
                const Positioned(
                  top: 3,
                  right: 3,
                  child: SilMark(size: 13),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(1, 10, 1, 4),
                child: Column(
                  children: [
                    Text(
                      lunar.moonDayKhmer,
                      style: TextStyle(
                        color: isToday ? cs.onPrimaryContainer.withValues(alpha: 0.78) : cs.onSurfaceVariant,
                        fontSize: 10,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isToday ? cs.onPrimaryContainer : color,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.25,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (!expanded)
                      Text(
                        lunar.khmerMonth,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isToday ? cs.onPrimaryContainer.withValues(alpha: 0.78) : cs.onSurfaceVariant,
                          fontSize: 8,
                          height: 1.2,
                        ),
                      )
                    else
                      for (final c in chips)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          color: dayToneColor(context, colorKind(c)).withValues(alpha: 0.18),
                          child: Text(
                            obsTitle(c, store.lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 8, color: dayToneColor(context, colorKind(c))),
                          ),
                        ),
                  ],
                ),
              ),
              if (!expanded && mark)
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
