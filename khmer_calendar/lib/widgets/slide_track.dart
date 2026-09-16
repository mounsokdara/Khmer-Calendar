import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// 3-page horizontal slide from Khmer Calendar v2026.09.13-51cdf3d
/// (`src/routes/months.tsx` swipeTo / month-track).
///
/// Track is 300% wide, parked at -100% (center page). Drag is clamped to ±width.
/// Snap uses the original 320ms `cubic-bezier(0.2, 0, 0, 1)` and
/// `dx > max(48, 18% width)` threshold. No PageView, no spring, no fling.
class SlideTrack extends StatefulWidget {
  const SlideTrack({
    super.key,
    required this.pageId,
    required this.previous,
    required this.current,
    required this.next,
    required this.onShift,
  });

  /// Identity of the center page. When it changes the track jumps back to
  /// center with no animation (original `transition: none` after cursor update).
  final String pageId;
  final Widget previous;
  final Widget current;
  final Widget next;
  final ValueChanged<int> onShift;

  @override
  State<SlideTrack> createState() => _SlideTrackState();
}

class _SlideTrackState extends State<SlideTrack> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final CurvedAnimation _curve;

  double _width = 1;
  double _live = 0;
  double _from = 0;
  double _to = 0;
  bool _dragging = false;
  int _pending = 0;

  /// Original `dragging.current` stays true until the next pointer down so the
  /// click that ends a swipe does not open the day.
  bool suppressTap = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _curve = CurvedAnimation(parent: _ctrl, curve: const Cubic(0.2, 0.0, 0.0, 1.0));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) _onSettled();
    });
  }

  @override
  void didUpdateWidget(covariant SlideTrack old) {
    super.didUpdateWidget(old);
    if (old.pageId != widget.pageId && !_dragging) {
      _ctrl.stop();
      _live = 0;
      _from = 0;
      _to = 0;
      _pending = 0;
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  double get _offset {
    if (_dragging) return _live.clamp(-_width, _width);
    return lerpDouble(_from, _to, _curve.value) ?? 0;
  }

  void _commitPending() {
    if (_pending == 0) return;
    final dir = _pending;
    _pending = 0;
    _live = 0;
    _from = 0;
    _to = 0;
    _ctrl.reset();
    widget.onShift(dir);
  }

  void _onSettled() {
    if (!mounted) return;
    if (_pending != 0) {
      _commitPending();
      return;
    }
    setState(() {
      _live = 0;
      _from = 0;
      _to = 0;
    });
  }

  void _animateTo(double target, int pending) {
    _pending = pending;
    _from = _offset;
    _to = target;
    _live = target;
    _dragging = false;
    _ctrl.forward(from: 0);
  }

  void _onDragStart(DragStartDetails d) {
    // Original: if a swipe animation is in flight, apply it before a new drag.
    if (_pending != 0) _commitPending();
    _ctrl.stop();
    _from = _offset;
    _to = _offset;
    _live = _offset;
    _dragging = true;
    suppressTap = false;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final n = _live + d.primaryDelta!;
    setState(() {
      _live = n.clamp(-_width, _width);
      if (_live.abs() > 8) suppressTap = true;
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final w = _width;
    final dx = _live;
    final threshold = w * 0.18 > 48 ? w * 0.18 : 48.0;
    _dragging = false;
    if (dx > threshold) {
      _animateTo(w, -1);
    } else if (dx < -threshold) {
      _animateTo(-w, 1);
    } else {
      _animateTo(0, 0);
    }
  }

  void _onDragCancel() {
    _dragging = false;
    _animateTo(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        _width = box.maxWidth <= 0 ? 1 : box.maxWidth;
        final w = _width;
        final h = box.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onHorizontalDragCancel: _onDragCancel,
          child: SizedBox(
            width: w,
            height: h.isFinite ? h : null,
            child: ClipRect(
              clipBehavior: Clip.hardEdge,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: -w + _offset,
                    top: 0,
                    bottom: 0,
                    width: w * 3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: w, child: IgnorePointer(child: widget.previous)),
                        SizedBox(
                          width: w,
                          child: IgnorePointer(
                            ignoring: suppressTap || _dragging || _pending != 0,
                            child: widget.current,
                          ),
                        ),
                        SizedBox(width: w, child: IgnorePointer(child: widget.next)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
