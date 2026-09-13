import 'package:flutter/material.dart';

import '../calendar/observances.dart';
import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/swipe_delete.dart';
import '../widgets/task_sheet.dart';
import 'today.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;
    final year = fromIso(store.cursor).year;
    final nowYear = DateTime.now().year;
    final pane = store.lastEventsPane;
    final hols = yearObservances(year, []).where((e) => e.kind == Kind.holiday).toList();
    final groups = <String, List<Observance>>{};
    for (final h in hols) {
      groups.putIfAbsent(h.date.substring(0, 7), () => []).add(h);
    }
    final today = todayIso();
    final current = store.events.where((e) => e.done != true && (e.date.isEmpty || e.date.compareTo(today) >= 0)).toList();
    final overdue = store.events.where((e) => e.done != true && e.date.isNotEmpty && e.date.compareTo(today) < 0).toList();
    final done = store.events.where((e) => e.done == true).toList();
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(child: Text(t(lang, 'events'), style: Theme.of(context).textTheme.headlineSmall)),
              if (pane == 'holidays')
                TextButton.icon(
                  onPressed: () async {
                    final pick = await showModalBottomSheet<int>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(title: Text(t(lang, 'yearPrev')), onTap: () => Navigator.pop(ctx, nowYear - 1)),
                          ListTile(title: Text(t(lang, 'yearNow')), onTap: () => Navigator.pop(ctx, nowYear)),
                          ListTile(title: Text(t(lang, 'yearNext')), onTap: () => Navigator.pop(ctx, nowYear + 1)),
                        ],
                      ),
                    );
                    if (pick != null) store.setCursor(isoOf(DateTime(pick, 1, 1)));
                  },
                  icon: const Icon(Icons.expand_more),
                  label: Text('$year'),
                )
              else
                IconButton(
                  tooltip: t(lang, 'addTask'),
                  onPressed: () => showTaskSheet(context, store: store),
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
        ),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'holidays', label: Text(t(lang, 'holidaysTab'))),
            ButtonSegment(value: 'tasks', label: Text(t(lang, 'tasksTab'))),
          ],
          selected: {pane},
          onSelectionChanged: (s) => store.setLastEventsPane(s.first),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: pane == 'holidays'
              ? (groups.isEmpty
                  ? Center(child: Text(t(lang, 'noHolidaysYear')))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        for (final e in groups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                            child: Text(
                              formatMonthTitle(fromIso('${e.key}-01'), lang),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          for (final item in e.value)
                            Card(
                              elevation: 0,
                              color: cs.surfaceContainerLow,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: dayToneColor(context, colorKind(item)).withValues(alpha: 0.15),
                                  child: Text('${fromIso(item.date).day}'),
                                ),
                                title: Text(obsTitle(item, lang), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                subtitle: Text(weekdaysFull(lang)[fromIso(item.date).weekday % 7]),
                                onTap: () {
                                  store.goToDate(item.date);
                                  showHolidayInfo(context, store, item);
                                },
                              ),
                            ),
                        ],
                      ],
                    ))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _taskGroup(context, t(lang, 'overdue'), overdue, true),
                    _taskGroup(context, t(lang, 'currentTasks'), current, false),
                    _taskGroup(context, t(lang, 'completed'), done, false),
                    if (store.events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(t(lang, 'noTasks')),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _taskGroup(BuildContext context, String title, List<CalendarEvent> list, bool overdue) {
    if (list.isEmpty) return const SizedBox.shrink();
    final lang = store.lang;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: overdue ? cs.error : cs.primary, fontWeight: FontWeight.bold)),
        ),
        for (final e in list)
          swipeToDelete(
            context: context,
            key: e.id,
            confirm: true,
            lang: lang,
            onDelete: () => store.deleteEvent(e.id),
            child: Card(
              elevation: 0,
              color: cs.surfaceContainerLow,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Checkbox(value: e.done ?? false, onChanged: (_) => store.toggleEventDone(e.id)),
                title: Text(e.title, style: TextStyle(decoration: e.done == true ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold)),
                subtitle: Text(eventWhenLabel(e.date, e.startTime, e.allDay, lang)),
                onTap: () => showTaskSheet(context, store: store, editing: e),
              ),
            ),
          ),
      ],
    );
  }
}
