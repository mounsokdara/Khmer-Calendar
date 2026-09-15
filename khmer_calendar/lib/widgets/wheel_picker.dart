import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dates.dart';
import '../i18n.dart';
import '../store.dart';
import 'dialog_actions.dart';

const wheelItemExtent = 52.0;
const wheelVisible = 3;
const wheelYearStart = 1970;
const wheelYearEnd = 2050;

enum WheelKind { month, year, label }

Future<void> showMonthWheel(BuildContext context, {required AppStore store}) {
  final lang = store.lang;
  final cursor = fromIso(store.cursor);
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return _MonthWheelDialog(
        store: store,
        lang: lang,
        initialMonth: cursor.month - 1,
        initialYear: cursor.year.clamp(wheelYearStart, wheelYearEnd),
      );
    },
  );
}

Future<int?> showYearWheel(BuildContext context, {required Lang lang, required int year}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) {
      return _YearWheelDialog(
        lang: lang,
        initialYear: year.clamp(wheelYearStart, wheelYearEnd),
      );
    },
  );
}

class _MonthWheelDialog extends StatefulWidget {
  const _MonthWheelDialog({
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
  State<_MonthWheelDialog> createState() => _MonthWheelDialogState();
}

class _MonthWheelDialogState extends State<_MonthWheelDialog> {
  late int month;
  late int year;

  @override
  void initState() {
    super.initState();
    month = widget.initialMonth;
    year = widget.initialYear;
  }

  void _commit() {
    widget.store.setCursor(isoOf(DateTime(year, month + 1, 1)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final months = monthsOf(lang);
    final years = [for (var y = wheelYearStart; y <= wheelYearEnd; y++) y];
    final maxW = MediaQuery.sizeOf(context).width;
    return AlertDialog(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(t(lang, 'khmerCalendar'), maxLines: 1),
      ),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      content: SizedBox(
        width: maxW < 408 ? maxW - 48 : 360,
        child: SizedBox(
          height: wheelItemExtent * wheelVisible,
          child: Row(
            children: [
              Expanded(
                child: WheelCol(
                  kind: WheelKind.month,
                  labels: months,
                  index: month,
                  onIndex: (i) => setState(() => month = i),
                ),
              ),
              Expanded(
                child: WheelCol(
                  kind: WheelKind.year,
                  labels: [for (final y in years) '$y'],
                  index: (year - wheelYearStart).clamp(0, years.length - 1),
                  onIndex: (i) => setState(() => year = wheelYearStart + i),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: equalDialogActions([
        FilledButton(
          onPressed: _commit,
          style: dialogBtnStyle(),
          child: dlgLabel(t(lang, 'change')),
        ),
      ]),
    );
  }
}

class _YearWheelDialog extends StatefulWidget {
  const _YearWheelDialog({required this.lang, required this.initialYear});
  final Lang lang;
  final int initialYear;

  @override
  State<_YearWheelDialog> createState() => _YearWheelDialogState();
}

class _YearWheelDialogState extends State<_YearWheelDialog> {
  late int year;

  @override
  void initState() {
    super.initState();
    year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final years = [for (var y = wheelYearStart; y <= wheelYearEnd; y++) y];
    final maxW = MediaQuery.sizeOf(context).width;
    return AlertDialog(
      title: Text(t(lang, 'yearCustom')),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      content: SizedBox(
        width: maxW < 408 ? maxW - 48 : 280,
        height: wheelItemExtent * wheelVisible,
        child: WheelCol(
          kind: WheelKind.year,
          labels: [for (final y in years) '$y'],
          index: (year - wheelYearStart).clamp(0, years.length - 1),
          onIndex: (i) => setState(() => year = wheelYearStart + i),
        ),
      ),
      actions: equalDialogActions([
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: dialogBtnStyle(),
          child: dlgLabel(t(lang, 'cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, year),
          style: dialogBtnStyle(),
          child: dlgLabel(t(lang, 'change')),
        ),
      ]),
    );
  }
}

class WheelCol extends StatefulWidget {
  const WheelCol({
    super.key,
    required this.labels,
    required this.index,
    required this.onIndex,
    this.kind = WheelKind.label,
  });
  final List<String> labels;
  final int index;
  final ValueChanged<int> onIndex;
  final WheelKind kind;

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

  int? _indexFromType(String val) {
    final raw = val.trim();
    if (raw.isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (widget.kind == WheelKind.month && digits.isNotEmpty) {
      final n = int.tryParse(digits);
      if (n != null && n >= 1 && n <= 12) return n - 1;
    }
    if (widget.kind == WheelKind.year && digits.isNotEmpty) {
      final n = widget.labels.indexWhere((l) => l.replaceAll(RegExp(r'\D'), '') == digits);
      if (n >= 0) return n;
    }
    var i = widget.labels.indexWhere((l) => l.toLowerCase() == raw.toLowerCase());
    if (i >= 0) return i;
    i = widget.labels.indexWhere((l) => l.toLowerCase().startsWith(raw.toLowerCase()));
    if (i >= 0) return i;
    if (digits.isNotEmpty) {
      i = widget.labels.indexWhere((l) => l.replaceAll(RegExp(r'\D'), '') == digits);
      if (i >= 0) return i;
    }
    return null;
  }

  void _commitType() {
    final n = _indexFromType(_type.text);
    setState(() => _typing = false);
    if (n != null && n >= 0 && n < widget.labels.length) {
      _ctrl.jumpToItem(n);
      widget.onIndex(n);
    }
  }

  void _startType() {
    final i = _ctrl.hasClients ? _ctrl.selectedItem : widget.index;
    if (widget.kind == WheelKind.month) {
      _type.text = '${i + 1}';
    } else if (widget.kind == WheelKind.year) {
      _type.text = widget.labels[i];
    } else {
      _type.text = widget.labels[i];
    }
    _type.selection = TextSelection(baseOffset: 0, extentOffset: _type.text.length);
    setState(() => _typing = true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final numeric = widget.kind == WheelKind.month || widget.kind == WheelKind.year;
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
                keyboardType: numeric ? TextInputType.number : TextInputType.text,
                style: Theme.of(context).textTheme.titleMedium,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(widget.kind == WheelKind.month ? 2 : 16),
                  if (numeric) FilteringTextInputFormatter.digitsOnly,
                ],
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
                        _startType();
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
