import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Horizontal pager for day / month. Adjacent pages are rebuilt by the parent
/// after a shift; the controller jumps back to the center page.
class SlideTrack extends StatefulWidget {
  const SlideTrack({
    super.key,
    required this.pageId,
    required this.previous,
    required this.current,
    required this.next,
    required this.onShift,
  });

  final String pageId;
  final Widget previous;
  final Widget current;
  final Widget next;
  final ValueChanged<int> onShift;

  @override
  State<SlideTrack> createState() => _SlideTrackState();
}

class _SlideTrackState extends State<SlideTrack> {
  static const _center = 1;
  late final PageController _ctrl;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: _center);
  }

  @override
  void didUpdateWidget(covariant SlideTrack old) {
    super.didUpdateWidget(old);
    if (old.pageId != widget.pageId) _goCenter();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goCenter() {
    void jump() {
      if (!mounted || !_ctrl.hasClients) return;
      if (_ctrl.page?.round() != _center) _ctrl.jumpToPage(_center);
      _busy = false;
    }

    if (_ctrl.hasClients) {
      jump();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => jump());
    }
  }

  void _onPage(int i) {
    if (_busy || i == _center) return;
    _busy = true;
    widget.onShift(i - _center);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      child: PageView(
        controller: _ctrl,
        onPageChanged: _onPage,
        children: [
          IgnorePointer(child: widget.previous),
          widget.current,
          IgnorePointer(child: widget.next),
        ],
      ),
    );
  }
}
