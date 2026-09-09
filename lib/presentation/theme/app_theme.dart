import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// The app's single source of ThemeData, built once for each brightness.
/// Typography pairs Sora (display/titles) with Manrope (body/labels) —
/// the same pairing used in the app's logo — plus JetBrains Mono for the
/// code blocks inside notes.
abstract final class AppTheme {
  static const monoFontFamily = 'JetBrains Mono';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true, fontFamily: 'Manrope');

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(base.textTheme, colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Sora',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.2,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme colorScheme) {
    TextStyle sora(double size, FontWeight weight, {double? letterSpacing, double? height}) => TextStyle(
          fontFamily: 'Sora',
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: height,
          color: colorScheme.onSurface,
        );
    TextStyle manrope(double size, FontWeight weight, {Color? color, double? height}) => TextStyle(
          fontFamily: 'Manrope',
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: color ?? colorScheme.onSurface,
        );

    return base.copyWith(
      displayLarge: sora(48, FontWeight.w800, letterSpacing: -0.5),
      displayMedium: sora(38, FontWeight.w800, letterSpacing: -0.4),
      displaySmall: sora(30, FontWeight.w700, letterSpacing: -0.3),
      headlineLarge: sora(28, FontWeight.w700, letterSpacing: -0.2),
      headlineMedium: sora(24, FontWeight.w700, letterSpacing: -0.2),
      headlineSmall: sora(20, FontWeight.w700),
      titleLarge: sora(19, FontWeight.w700),
      titleMedium: sora(16, FontWeight.w600, height: 1.3),
      titleSmall: sora(14, FontWeight.w600),
      bodyLarge: manrope(16, FontWeight.w400, height: 1.5),
      bodyMedium: manrope(14.5, FontWeight.w400, height: 1.5),
      bodySmall: manrope(12.5, FontWeight.w500, color: colorScheme.onSurfaceVariant),
      labelLarge: manrope(14, FontWeight.w700),
      labelMedium: manrope(12, FontWeight.w600, color: colorScheme.onSurfaceVariant),
      labelSmall: manrope(11, FontWeight.w600, color: colorScheme.onSurfaceVariant),
    );
  }
}
