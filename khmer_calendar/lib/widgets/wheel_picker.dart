import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dates.dart';
import '../i18n.dart';
import '../store.dart';

const wheelItemExtent = 52.0;
const wheelVisible = 3;
const wheelYearStart = 1970;
const wheelYearEnd = 2050;

Future<void> showMonthWheel(BuildContext context, {required AppStore store}) {
  final lang = store.lang;
  final cursor = fromIso(store.cursor);
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(t(lang, 'khmerCalendar')),
        contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
        content: SizedBox(
          width: 360,
          child: _MonthWheelSheet(
            store: store,
            lang: lang,
            initialMonth: cursor.month - 1,
            initialYear: cursor.year.clamp(wheelYearStart, wheelYearEnd),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t(lang, 'change')),
          ),
        ],
      );
    },
  );
}

class _MonthWheelSheet extends StatefulWidget {
  const _MonthWheelSheet({
    required this.store,
    required this.lang,
    required this.initialMonth,
    required this.initialYear,
  });
  final AppStore store;
  final Lang lang;
  final int initialMonth;
  final int initialYear;

  @override
  State<_MonthWheelSheet> createState() => _MonthWheelSheetState();
}

class _MonthWheelSheetState extends State<_MonthWheelSheet> {
  late int month;
  late int year;

  @override
  void initState() {
    super.initState();
    month = widget.initialMonth;
    year = widget.initialYear;
  }

  void _apply() {
    widget.store.setCursor(isoOf(DateTime(year, month + 1, 1)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final months = monthsOf(lang);
    final years = [for (var y = wheelYearStart; y <= wheelYearEnd; y++) y];
    return SizedBox(
      height: wheelItemExtent * wheelVisible,
      child: Row(
        children: [
          Expanded(
            child: WheelCol(
              labels: months,
              index: month,
              onIndex: (i) {
                setState(() => month = i);
                _apply();
              },
            ),
          ),
          Expanded(
            child: WheelCol(
              labels: [for (final y in years) '$y'],
              index: (year - wheelYearStart).clamp(0, years.length - 1),
              onIndex: (i) {
                setState(() => year = wheelYearStart + i);
                _apply();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WheelCol extends StatefulWidget {
  const WheelCol({super.key, required this.labels, required this.index, required this.onIndex});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onIndex;

  @override
  State<WheelCol> createState() => _WheelColState();
}

class _WheelColState extends State<WheelCol> {
  late FixedExtentScrollController _ctrl;
  bool _typing = false;
  final _type = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: widget.index);
  }

  @override
  void didUpdateWidget(covariant WheelCol old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && _ctrl.hasClients && _ctrl.selectedItem != widget.index) {
      _ctrl.jumpToItem(widget.index);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _type.dispose();
    super.dispose();
  }

  void _commitType() {
    final val = _type.text.trim();
    var n = widget.labels.indexWhere((l) => l.toLowerCase() == val.toLowerCase());
    if (n < 0) {
      n = widget.labels.indexWhere((l) => l.toLowerCase().startsWith(val.toLowerCase()));
    }
    if (n < 0) {
      final digits = val.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) n = widget.labels.indexWhere((l) => l.replaceAll(RegExp(r'\D'), '') == digits);
    }
    setState(() => _typing = false);
    if (n >= 0) {
      _ctrl.jumpToItem(n);
      widget.onIndex(n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: wheelItemExtent * wheelVisible,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              height: wheelItemExtent - 4,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.outlineVariant, width: 1.4),
                color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
              ),
            ),
          ),
          if (_typing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _type,
                autofocus: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
                inputFormatters: [LengthLimitingTextInputFormatter(16)],
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                onSubmitted: (_) => _commitType(),
                onTapOutside: (_) => _commitType(),
              ),
            )
          else
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.28, 0.72, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: ListWheelScrollView.useDelegate(
                controller: _ctrl,
                itemExtent: wheelItemExtent,
                diameterRatio: 8,
                perspective: 0.0008,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: widget.onIndex,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.labels.length,
                  builder: (_, i) => GestureDetector(
                    onTap: () {
                      if (i == (_ctrl.hasClients ? _ctrl.selectedItem : widget.index)) {
                        _type.text = widget.labels[i];
                        setState(() => _typing = true);
                      } else {
                        _ctrl.animateToItem(i, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                      }
                    },
                    child: Center(
                      child: Text(
                        widget.labels[i],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: i == (_ctrl.hasClients ? _ctrl.selectedItem : widget.index)
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
