import 'package:flutter/material.dart';

/// Material 3 segmented group: each row is its own surface, first/last
/// corners are large, inner corners small, with a short gap — same pattern
/// as Booming's `SegmentedListItem` / the original `.set-group`.
class SegmentedGroup extends StatelessWidget {
  const SegmentedGroup({super.key, required this.children, this.padding = const EdgeInsets.symmetric(horizontal: 16)});
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  static const _gap = 7.0;
  static const _big = 26.0;
  static const _small = 6.0;

  static BorderRadius radiusFor(int index, int count) {
    if (count <= 1) return BorderRadius.circular(_big);
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(_big),
        topRight: Radius.circular(_big),
        bottomLeft: Radius.circular(_small),
        bottomRight: Radius.circular(_small),
      );
    }
    if (index == count - 1) {
      return const BorderRadius.only(
        topLeft: Radius.circular(_small),
        topRight: Radius.circular(_small),
        bottomLeft: Radius.circular(_big),
        bottomRight: Radius.circular(_big),
      );
    }
    return BorderRadius.circular(_small);
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: _gap),
            Material(
              color: cs.surfaceContainer,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: radiusFor(i, children.length)),
              child: children[i],
            ),
          ],
        ],
      ),
    );
  }
}

class SegmentedTile extends StatelessWidget {
  const SegmentedTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
    this.selected = false,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleColor = danger ? cs.error : cs.onSurface;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      minVerticalPadding: 12,
      leading: leading,
      selected: selected,
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: danger ? cs.error.withValues(alpha: 0.8) : cs.onSurfaceVariant),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color ?? cs.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
