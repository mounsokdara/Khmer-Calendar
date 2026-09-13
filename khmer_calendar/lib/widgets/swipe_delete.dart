import 'package:flutter/material.dart';

import '../i18n.dart';

Widget swipeToDelete({
  required BuildContext context,
  required String key,
  required Widget child,
  required VoidCallback onDelete,
  bool confirm = false,
  Lang lang = Lang.km,
}) {
  return Dismissible(
    key: ValueKey(key),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: Theme.of(context).colorScheme.error,
      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
    ),
    confirmDismiss: confirm
        ? (_) async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(t(lang, 'confirmDelete')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t(lang, 'dontDelete'))),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t(lang, 'delete'))),
                ],
              ),
            );
            return ok ?? false;
          }
        : null,
    onDismissed: (_) => onDelete(),
    child: child,
  );
}
