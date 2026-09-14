import 'package:flutter/material.dart';

/// Shared gesture-start page so drag and fling both clamp to ±1 from where
/// the pointer went down — matching the original CSS
/// `Math.max(-w, Math.min(w, n))` clamp. Must not use the *current* page as
/// the anchor: that walks as you drag and lets one swipe skip many months.
class PageAnchor {
  double? startPage;
}

/// Snaps at most one page per gesture, with a ~320ms spring like the original
/// 3-slide CSS carousel (`cubic-bezier(0.2, 0, 0, 1)` 320ms).
///
/// Must be used with `pageSnapping: false` — PageView wraps a custom physics
/// with [PageScrollPhysics] when snapping is on, which ignores this clamp.
class OnePageScrollPhysics extends ScrollPhysics {
  const OnePageScrollPhysics({super.parent, required this.anchor});
  final PageAnchor anchor;

  @override
  OnePageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OnePageScrollPhysics(parent: buildParent(ancestor), anchor: anchor);
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 0.4,
        stiffness: 180,
        ratio: 1.05,
      );

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final pageSize = position.viewportDimension;
    if (pageSize <= 0) return parent?.applyPhysicsToUserOffset(position, offset) ?? offset;
    anchor.startPage ??= position.pixels / pageSize;
    final start = anchor.startPage!.roundToDouble();
    final minPx = ((start - 1) * pageSize).clamp(position.minScrollExtent, position.maxScrollExtent);
    final maxPx = ((start + 1) * pageSize).clamp(position.minScrollExtent, position.maxScrollExtent);
    final next = (position.pixels + offset).clamp(minPx, maxPx);
    return next - position.pixels;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final pageSize = position.viewportDimension;
    if (pageSize <= 0) return super.createBallisticSimulation(position, velocity);
    final tolerance = toleranceFor(position);
    final current = position.pixels / pageSize;
    final start = (anchor.startPage ?? current).roundToDouble();
    anchor.startPage = null;

    // Original snap: distance > max(48px, 18% of width). Velocity-based fling
    // still only moves ±1 from the gesture start.
    late final double targetPage;
    final threshold = mathMax(48 / pageSize, 0.18);
    if (velocity.abs() < mathMax(tolerance.velocity, 80)) {
      if ((current - start).abs() < threshold) {
        targetPage = start;
      } else {
        targetPage = current > start ? start + 1 : start - 1;
      }
    } else if (velocity > 0) {
      targetPage = start + 1;
    } else {
      targetPage = start - 1;
    }
    final maxPage = pageSize > 0 ? position.maxScrollExtent / pageSize : start;
    final clamped = targetPage.clamp(0, maxPage);
    final target = clamped * pageSize;
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
  }
}

double mathMax(double a, double b) => a > b ? a : b;
