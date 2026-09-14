import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n.dart';
import '../store.dart';

/// Rebuilds whenever [store] notifies — overlay routes are kept in the
/// navigator stack and otherwise miss language / theme updates.
class WatchStore extends StatelessWidget {
  const WatchStore({super.key, required this.store, required this.builder});
  final AppStore store;
  final Widget Function(BuildContext context, AppStore store) builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => builder(context, store),
    );
  }
}

/// Full-screen overlay with the original SubHead back arrow and swipe-right to close.
class OverlayScaffold extends StatelessWidget {
  const OverlayScaffold({super.key, required this.title, required this.body, this.actions});
  final String title;
  final Widget body;
  final List<Widget>? actions;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/more');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 420) _back(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => _back(context),
          ),
          title: Text(title),
          actions: actions,
        ),
        body: body,
      ),
    );
  }
}

class LangRadios extends StatelessWidget {
  const LangRadios({super.key, required this.store, required this.uiLang, this.onPicked});
  final AppStore store;
  final Lang uiLang;
  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context) {
    final opts = [
      ('auto', t(uiLang, 'langAuto'), t(uiLang, 'langAutoSub')),
      ('km', 'ខ្មែរ', 'Khmer'),
      ('en', 'English', 'English'),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final o in opts)
          ListTile(
            leading: Icon(store.langPref == o.$1 ? Icons.radio_button_checked : Icons.radio_button_off),
            title: Text(o.$2),
            subtitle: Text(o.$3),
            onTap: () {
              store.setLang(o.$1);
              onPicked?.call();
            },
          ),
      ],
    );
  }
}
