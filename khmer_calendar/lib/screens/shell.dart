import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n.dart';
import '../store.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.store, required this.child});
  final AppStore store;
  final Widget child;

  static const tabs = [
    (TabId.today, '/day', Icons.today, 'navToday'),
    (TabId.months, '/months', Icons.calendar_month, 'navMonth'),
    (TabId.events, '/events', Icons.event_note, 'navEvents'),
    (TabId.weather, '/weather', Icons.wb_cloudy, 'navWeather'),
    (TabId.more, '/more', Icons.menu, 'navMore'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    var idx = tabs.indexWhere((t) => loc == t.$2 || loc.startsWith('${t.$2}/'));
    if (idx < 0) idx = 1;
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          store.setLastTab(tabs[i].$1);
          context.go(tabs[i].$2);
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.$3),
              selectedIcon: Icon(tab.$3),
              label: t(store.lang, tab.$4),
            ),
        ],
      ),
    );
  }
}
