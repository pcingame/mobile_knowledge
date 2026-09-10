import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// The app's single source of ThemeData, built once for each brightness.
/// Typography uses Be Vietnam Pro throughout (display, body, and labels) —
/// unlike geometric faces such as Sora/Manrope, it renders Vietnamese
/// diacritics (e.g. the hook above in "phỏng") cleanly at every weight —
/// plus JetBrains Mono for the code blocks inside notes.
abstract final class AppTheme {
  static const displayFontFamily = 'Be Vietnam Pro';
  static const monoFontFamily = 'JetBrains Mono';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    );
    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: displayFontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(base.textTheme, colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 22,
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
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: const TextStyle(
            fontFamily: displayFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: displayFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme colorScheme) {
    // No negative letterSpacing: Be Vietnam Pro's diacritics (hook above,
    // horn, breve, ...) need their natural spacing to stay legible and
    // avoid colliding with neighboring glyphs at large display sizes.
    TextStyle style(
      double size,
      FontWeight weight, {
      Color? color,
      double? height,
    }) => TextStyle(
      fontFamily: displayFontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? colorScheme.onSurface,
    );

    return base.copyWith(
      displayLarge: style(48, FontWeight.w800),
      displayMedium: style(38, FontWeight.w800),
      displaySmall: style(30, FontWeight.w700),
      headlineLarge: style(28, FontWeight.w700),
      headlineMedium: style(24, FontWeight.w700),
      headlineSmall: style(20, FontWeight.w700),
      titleLarge: style(19, FontWeight.w700),
      titleMedium: style(16, FontWeight.w600, height: 1.3),
      titleSmall: style(14, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14.5, FontWeight.w400, height: 1.5),
      bodySmall: style(
        12.5,
        FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: style(14, FontWeight.w700),
      labelMedium: style(
        12,
        FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: style(
        11,
        FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
