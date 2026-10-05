import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Wrap the content of a screen that has a bottom bar (e.g. the shell's
/// NavigationBar). Snackbars shown from inside this subtree sit above that bar
/// instead of covering it. Screens pushed on top of the shell are outside the
/// subtree, so they are unaffected.
class SnackBarAvoid extends InheritedWidget {
  const SnackBarAvoid({super.key, required this.barKey, required super.child});

  /// Key attached to the bottom bar widget.
  final GlobalKey barKey;

  static SnackBarAvoid? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SnackBarAvoid>();

  @override
  bool updateShouldNotify(SnackBarAvoid oldWidget) => barKey != oldWidget.barKey;
}

class SlideSnackBar {
  SlideSnackBar._();

  static OverlayEntry? _entry;

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static void show(
    BuildContext context, {
    required String message,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    bool showCloseIcon = false,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
    double actionOverflowThreshold = 0.25,
  }) {
    hide();

    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    final GlobalKey? barKey = SnackBarAvoid.maybeOf(context)?.barKey;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return _SlideSnackBar(
          message: message,
          behavior: behavior,
          barKey: barKey,
          showCloseIcon: showCloseIcon,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          duration: duration,
          actionOverflowThreshold: actionOverflowThreshold,
          onDismissed: () {
            if (_entry == entry) {
              _entry = null;
            }
            entry.remove();
          },
        );
      },
    );

    _entry = entry;
    overlay.insert(entry);
  }

  /// Distance from the bottom of the screen to the top of the nav bar.
  /// Uses global coordinates so the overlay does not need to be an ancestor of
  /// the bar (it never is). Returns 0 when the bar is missing or not laid out.
  static double barInset(GlobalKey? barKey) {
    if (barKey == null) return 0;
    final RenderObject? barRO = barKey.currentContext?.findRenderObject();
    if (barRO is! RenderBox || !barRO.attached || !barRO.hasSize) return 0;

    final double barTop = barRO.localToGlobal(Offset.zero).dy;
    final double screenBottom =
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    // Prefer the view's logical height; fall back to bar bottom if needed.
    final double inset = screenBottom - barTop;
    if (inset.isFinite && inset > 0) return inset;

    // Fallback: bar's own height when global math is unavailable.
    return barRO.size.height;
  }
}

class _SlideSnackBar extends StatefulWidget {
  const _SlideSnackBar({
    required this.message,
    required this.behavior,
    required this.barKey,
    required this.showCloseIcon,
    required this.actionLabel,
    required this.onActionPressed,
    required this.duration,
    required this.actionOverflowThreshold,
    required this.onDismissed,
  });

  final String message;
  final SnackBarBehavior behavior;
  final GlobalKey? barKey;
  final bool showCloseIcon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Duration duration;
  final double actionOverflowThreshold;
  final VoidCallback onDismissed;

  @override
  State<_SlideSnackBar> createState() => _SlideSnackBarState();
}

class _SlideSnackBarState extends State<_SlideSnackBar>
    with TickerProviderStateMixin {
  static const Duration _enterDuration = Duration(milliseconds: 250);
  static const Duration _exitDuration = Duration(milliseconds: 200);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _enterDuration,
    reverseDuration: _exitDuration,
  );

  late final AnimationController _dragController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  final GlobalKey _snackKey = GlobalKey();

  Timer? _timer;
  bool _dismissing = false;
  bool _dragging = false;
  double _navInset = 0;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _restartTimer();
    // Measure after the first frame so the nav bar has a size, then again
    // whenever the metrics change (rotate / window resize).
    WidgetsBinding.instance.addPostFrameCallback((_) => _remeasure());
    WidgetsBinding.instance.addObserver(_metricsObserver);
  }

  late final _MetricsObserver _metricsObserver = _MetricsObserver(_remeasure);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_metricsObserver);
    _timer?.cancel();
    _controller.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _remeasure() {
    if (!mounted) return;
    final double next = SlideSnackBar.barInset(widget.barKey);
    if (next != _navInset) {
      setState(() => _navInset = next);
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _dragging = false;
    _timer?.cancel();
    _dragController.stop();
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  double get _snackHeight {
    final RenderObject? renderObject =
        _snackKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final double height = renderObject.size.height;
      if (height > 0) return height;
    }
    return 1;
  }

  void _onDragStart(DragStartDetails details) {
    if (_dismissing) return;
    _dragging = true;
    _timer?.cancel();
    _dragController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging || _dismissing) return;
    final double delta = details.delta.dy / _snackHeight;
    final double next =
        (_dragController.value + delta).clamp(0.0, 1.0).toDouble();
    _dragController.value = next;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;

    final double velocity = details.primaryVelocity ?? 0;

    if (_dragController.value >= 0.35 || velocity > 700) {
      _dismiss();
      return;
    }

    _dragController
        .animateTo(
      0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    )
        .whenComplete(() {
      if (mounted && !_dismissing) _restartTimer();
    });
  }

  void _onDragCancel() {
    if (!_dragging) return;
    _dragging = false;
    _dragController.animateTo(
      0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
    if (!_dismissing) _restartTimer();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool floating = widget.behavior == SnackBarBehavior.floating;

    // Always re-read so a layout pass after resize picks up the new nav height.
    final double measured = SlideSnackBar.barInset(widget.barKey);
    final double navInset = measured > 0 ? measured : _navInset;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double bottomPad =
        (floating ? 16.0 : 0.0) + (navInset > safeBottom ? navInset : safeBottom);

    final Color backgroundColor =
        theme.snackBarTheme.backgroundColor ?? scheme.inverseSurface;
    final Color foregroundColor =
        theme.snackBarTheme.actionTextColor ?? scheme.onInverseSurface;
    final TextStyle textStyle =
        theme.snackBarTheme.contentTextStyle ??
        theme.textTheme.bodyMedium!.copyWith(color: scheme.onInverseSurface);

    final Widget? actionButton = widget.actionLabel == null
        ? null
        : TextButton(
            onPressed: () {
              widget.onActionPressed?.call();
              _dismiss();
            },
            style: TextButton.styleFrom(foregroundColor: foregroundColor),
            child: Text(widget.actionLabel!),
          );

    final Widget bar = Material(
      color: backgroundColor,
      elevation: 6,
      borderRadius: floating ? BorderRadius.circular(8) : BorderRadius.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _buildContentArea(
                textStyle: textStyle,
                actionButton: actionButton,
              ),
            ),
            if (widget.showCloseIcon)
              IconButton(
                onPressed: _dismiss,
                color: foregroundColor,
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
          ],
        ),
      ),
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _slide,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_fade, _dragController]),
          builder: (BuildContext context, Widget? child) {
            final double dragProgress = _dragController.value;
            final double opacity =
                (_fade.value * (1.0 - dragProgress)).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: FractionalTranslation(
                translation: Offset(0, dragProgress),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: _onDragStart,
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            onVerticalDragCancel: _onDragCancel,
            child: Padding(
              key: _snackKey,
              padding: EdgeInsets.only(
                left: floating ? 16 : 0,
                right: floating ? 16 : 0,
                bottom: bottomPad,
              ),
              child: floating
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: bar,
                      ),
                    )
                  : bar,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea({
    required TextStyle textStyle,
    required Widget? actionButton,
  }) {
    final Widget textWidget = Text(widget.message, style: textStyle);

    if (actionButton == null) {
      return textWidget;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.message, style: textStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();

        final double available = constraints.maxWidth;
        final bool putActionOnNewLine =
            painter.width > available * (1 - widget.actionOverflowThreshold);

        if (putActionOnNewLine) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              textWidget,
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerRight, child: actionButton),
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: textWidget),
            const SizedBox(width: 8),
            actionButton,
          ],
        );
      },
    );
  }
}

/// Listens for view metric changes (rotate, window resize) and remeasures.
class _MetricsObserver with WidgetsBindingObserver {
  _MetricsObserver(this.onChange);
  final VoidCallback onChange;

  @override
  void didChangeMetrics() {
    // Wait one frame so the nav bar has its new layout before measuring.
    SchedulerBinding.instance.addPostFrameCallback((_) => onChange());
  }
}
