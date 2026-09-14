import 'package:flutter/material.dart';

enum ColorSchemeId {
  rose,
  purple,
  slate,
  teal,
  green,
  violet,
  magenta,
  burgundy,
  brown,
  amber,
  forest,
  olive,
  navy,
  coral,
}

class SchemeChip {
  const SchemeChip(this.id, this.label, this.circle);
  final ColorSchemeId id;
  final String label;
  final Color circle;
}

const schemes = [
  SchemeChip(ColorSchemeId.rose, 'ក្រហម', Color(0xFF9A3B38)),
  SchemeChip(ColorSchemeId.purple, 'ស្វាយ', Color(0xFF68509F)),
  SchemeChip(ColorSchemeId.slate, 'ខៀវ', Color(0xFF38618D)),
  SchemeChip(ColorSchemeId.teal, 'បៃតងខៀវ', Color(0xFF146781)),
  SchemeChip(ColorSchemeId.green, 'បៃតង', Color(0xFF036A62)),
  SchemeChip(ColorSchemeId.violet, 'វីយ៉ូឡែត', Color(0xFF68548E)),
  SchemeChip(ColorSchemeId.magenta, 'ផ្កាឈូក', Color(0xFF7C4E7E)),
  SchemeChip(ColorSchemeId.burgundy, 'ក្រហមចាស់', Color(0xFF8C4A61)),
  SchemeChip(ColorSchemeId.brown, 'ត្នោត', Color(0xFF8E4D33)),
  SchemeChip(ColorSchemeId.amber, 'ទឹកក្រូច', Color(0xFF84541A)),
  SchemeChip(ColorSchemeId.forest, 'ព្រៃ', Color(0xFF40693F)),
  SchemeChip(ColorSchemeId.olive, 'អូលីវ', Color(0xFF586424)),
  SchemeChip(ColorSchemeId.navy, 'ទឹកប៊ិច', Color(0xFF3D4C7A)),
  SchemeChip(ColorSchemeId.coral, 'ថ្មប៉ប្រះទឹក', Color(0xFFC45C4A)),
];

Color schemeColor(ColorSchemeId id) => schemes.firstWhere((s) => s.id == id, orElse: () => schemes.first).circle;

ThemeData buildTheme({
  required Brightness brightness,
  required ColorSchemeId scheme,
  required bool extraDark,
}) {
  final seed = schemeColor(scheme);
  var color = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  if (brightness == Brightness.dark && extraDark) {
    color = color.copyWith(
      surface: const Color(0xFF000000),
      surfaceContainerLowest: const Color(0xFF000000),
    );
  }
  return ThemeData(
    useMaterial3: true,
    colorScheme: color,
    brightness: brightness,
    fontFamily: 'KantumruyPro',
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: color.surface,
      foregroundColor: color.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: color.surfaceContainer,
      indicatorColor: color.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'KantumruyPro',
          fontSize: 12,
          fontWeight: on ? FontWeight.w600 : FontWeight.w500,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: color.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

const silColor = Color(0xFFD4920F);

const wideBreak = 840.0;
const mediumBreak = 720.0;
const xlBreak = 1180.0;

bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= wideBreak;
bool isMedium(BuildContext context) => MediaQuery.sizeOf(context).width >= mediumBreak;
bool isXl(BuildContext context) => MediaQuery.sizeOf(context).width >= xlBreak;

Color dayToneColor(BuildContext context, String tone) {
  final cs = Theme.of(context).colorScheme;
  switch (tone) {
    case 'sunday':
      return const Color(0xFFC62828);
    case 'holiday':
      return cs.primary;
    case 'sil':
      return silColor;
    case 'event':
      return cs.primary;
    case 'muted':
      return cs.onSurface.withValues(alpha: 0.38);
    default:
      return cs.onSurface;
  }
}
