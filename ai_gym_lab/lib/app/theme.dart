import 'package:material_ui/material_ui.dart';

/// 다크모드 기본 · 블랙/차콜 배경 · 선명한 라임 포인트 컬러
class GymColors {
  static const bg = Color(0xFF0B0C0E);
  static const surface = Color(0xFF16181C);
  static const surface2 = Color(0xFF1F2227);
  static const line = Color(0xFF2C3036);
  static const accent = Color(0xFFC6FF3D);
  static const accentDim = Color(0xFF8DB82A);
  static const text = Color(0xFFF2F4F5);
  static const textDim = Color(0xFF9AA1A9);
  static const warn = Color(0xFFFFB547);
  static const danger = Color(0xFFFF5C5C);
  static const info = Color(0xFF5CC8FF);
  static const research = Color(0xFF7FA7FF);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: GymColors.accent, brightness: Brightness.dark).copyWith(
    primary: GymColors.accent,
    onPrimary: Colors.black,
    secondary: GymColors.info,
    surface: GymColors.surface,
    onSurface: GymColors.text,
    error: GymColors.danger,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: GymColors.bg,
    appBarTheme: const AppBarTheme(backgroundColor: GymColors.bg, foregroundColor: GymColors.text, elevation: 0, centerTitle: false),
    cardTheme: CardThemeData(
      color: GymColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: GymColors.line),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: GymColors.surface,
      indicatorColor: GymColors.accent.withValues(alpha: 0.18),
      height: 66,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? GymColors.accent : GymColors.textDim,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: s.contains(WidgetState.selected) ? GymColors.accent : GymColors.textDim)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GymColors.accent,
        foregroundColor: Colors.black,
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GymColors.text,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: GymColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GymColors.surface2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: GymColors.textDim),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: GymColors.surface2,
      selectedColor: GymColors.accent.withValues(alpha: 0.22),
      side: const BorderSide(color: GymColors.line),
      labelStyle: const TextStyle(color: GymColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerTheme: const DividerThemeData(color: GymColors.line, space: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
