import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/i18n.dart';

void main() {
  test('month query matches numbers, Khmer, and English names', () {
    expect(monthIndexFromQuery('1'), 0);
    expect(monthIndexFromQuery('១'), 0);
    expect(monthIndexFromQuery('12'), 11);
    expect(monthIndexFromQuery('jan'), 0);
    expect(monthIndexFromQuery('January'), 0);
    expect(monthIndexFromQuery('JAN'), 0);
    expect(monthIndexFromQuery('មក'), 0);
    expect(monthIndexFromQuery('មករា'), 0);
    expect(monthIndexFromQuery('jul'), 6);
    expect(monthIndexFromQuery('July'), 6);
    expect(monthIndexFromQuery('sept'), 8);
    expect(monthIndexFromQuery('កញ្ញា'), 8);
    expect(monthIndexFromQuery('not-a-month'), isNull);
  });
}
