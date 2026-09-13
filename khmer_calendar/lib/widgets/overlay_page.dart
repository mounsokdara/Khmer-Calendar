import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Full-screen page without a back arrow — swipe right to close.
class OverlayScaffold extends StatelessWidget {
  const OverlayScaffold({super.key, required this.title, required this.body, this.actions});
  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 420 && context.canPop()) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(title),
          actions: actions,
        ),
        body: body,
      ),
    );
  }
}
