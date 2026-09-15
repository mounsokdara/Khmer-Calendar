import 'package:flutter/material.dart';

import '../i18n.dart';
import '../store.dart';
import '../theme.dart';

const colorPresets = [
  '#F5C400',
  '#FF3B30',
  '#FF9500',
  '#34C759',
  '#007AFF',
  '#5856D6',
  '#AF52DE',
  '#FF2D55',
  '#5AC8FA',
  '#8E8E93',
  '#1C1C1E',
  '#9A3B38',
];

class SchemeChipScroller extends StatelessWidget {
  const SchemeChipScroller({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final enabled = !store.materialYou;
    return Semantics(
      label: t(store.lang, 'schemeAria'),
      child: SizedBox(
        height: 88,
        child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        scrollDirection: Axis.horizontal,
        itemCount: schemes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final s = schemes[i];
          final selected = store.colorScheme == s.id;
          return Tooltip(
            message: s.label,
            child: _SchemeChipButton(
              chip: s,
              selected: selected,
              onTap: enabled ? () => store.setColorScheme(s.id) : null,
            ),
          );
        },
      ),
      ),
    );
  }
}

class _SchemeChipButton extends StatelessWidget {
  const _SchemeChipButton({required this.chip, required this.selected, required this.onTap});
  final SchemeChip chip;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.4)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: chip.top,
            borderRadius: BorderRadius.circular(18.4),
            border: Border.all(color: selected ? chip.circle : Colors.transparent, width: 3),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15.4)),
                  child: Container(height: 36, color: chip.bot),
                ),
              ),
              Center(
                child: Container(
                  width: 72 * 0.42,
                  height: 72 * 0.42,
                  decoration: BoxDecoration(color: chip.circle, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorRow extends StatelessWidget {
  const ColorRow({
    super.key,
    required this.title,
    required this.value,
    required this.onPick,
    this.subtitle,
    this.disabled = false,
  });
  final String title;
  final String? subtitle;
  final String value;
  final VoidCallback onPick;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null ? null : Text(subtitle!, maxLines: 3, overflow: TextOverflow.ellipsis),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: hexColor(value),
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      onTap: disabled ? null : onPick,
    );
  }
}

Future<void> showColorPicker(
  BuildContext context, {
  required Lang lang,
  required String title,
  required String value,
  required ValueChanged<String> onSave,
}) async {
  var v = value.toUpperCase();
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSt) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: double.infinity,
                    decoration: BoxDecoration(color: hexColor(v), borderRadius: BorderRadius.circular(16)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in colorPresets)
                        GestureDetector(
                          onTap: () => setSt(() => v = p),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: hexColor(p),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: v.toUpperCase() == p ? Theme.of(ctx).colorScheme.onSurface : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Slider(
                    min: 0,
                    max: 360,
                    value: hueFromHex(v).clamp(0, 360),
                    onChanged: (n) => setSt(() => v = hueHex(n)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t(lang, 'cancel'))),
              FilledButton(
                onPressed: () {
                  onSave(v);
                  Navigator.pop(ctx);
                },
                child: Text(t(lang, 'save')),
              ),
            ],
          );
        },
      );
    },
  );
}
