import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VIOLET — Premium glassmorphism dark theme for Open Player.
///
/// Based on the Stitch "Violet Music Streaming Experience" design system.
/// Deep space palette with glass surfaces, gradient glows, and Geist typography.
class AppTheme {
  AppTheme._();

  // ── VIOLET Color Palette ────────────────────────────────────
  static const Color primary = Color(0xFFD0BCFF);
  static const Color primaryContainer = Color(0xFFA078FF);
  static const Color inversePrimary = Color(0xFF6D3BD7);
  static const Color onPrimary = Color(0xFF3C0091);
  static const Color onPrimaryContainer = Color(0xFF340080);

  static const Color secondary = Color(0xFFC4C1FB);
  static const Color secondaryContainer = Color(0xFF444173);
  static const Color onSecondary = Color(0xFF2D2A5B);
  static const Color onSecondaryContainer = Color(0xFFB3AFE9);

  static const Color tertiary = Color(0xFFDDB8FF);
  static const Color tertiaryContainer = Color(0xFFB175EC);
  static const Color onTertiary = Color(0xFF490081);
  static const Color onTertiaryContainer = Color(0xFF400071);

  static const Color surface = Color(0xFF12121D);
  static const Color surfaceDim = Color(0xFF12121D);
  static const Color surfaceBright = Color(0xFF383845);
  static const Color surfaceContainer = Color(0xFF1F1E2A);
  static const Color surfaceContainerLow = Color(0xFF1B1A26);
  static const Color surfaceContainerHigh = Color(0xFF292935);
  static const Color surfaceContainerHighest = Color(0xFF343440);
  static const Color surfaceContainerLowest = Color(0xFF0D0D18);
  static const Color surfaceVariant = Color(0xFF343440);

  static const Color onSurface = Color(0xFFE3E0F1);
  static const Color onSurfaceVariant = Color(0xFFCBC3D7);
  static const Color onBackground = Color(0xFFE3E0F1);

  static const Color outline = Color(0xFF958EA0);
  static const Color outlineVariant = Color(0xFF494454);

  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color inverseSurface = Color(0xFFE3E0F1);
  static const Color inverseOnSurface = Color(0xFF302F3B);

  static const Color surfaceTint = Color(0xFFD0BCFF);
  static const Color accentWarm = Color(0xFFF472B6);

  // ── Gradients ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryContainer, inversePrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [surfaceContainerLowest, surface, surfaceContainerHigh],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient nowPlayingGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient textGradient = const LinearGradient(
    colors: [primary, tertiaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Border Radius ─────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Spacing ───────────────────────────────────────────────
  static const double spacingUnit = 4.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double marginMobile = 16.0;

  // ── Glassmorphism Decorations ──────────────────────────────
  static BoxDecoration glassPanel({
    double borderRadius = radiusLg,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? surfaceContainer.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.05),
          blurRadius: 0,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration glassCard({double borderRadius = radiusMd}) {
    return BoxDecoration(
      color: surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    );
  }

  static BoxDecoration glassButton({double borderRadius = radiusFull}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.05),
          blurRadius: 0,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // ── Shadows ───────────────────────────────────────────────
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryContainer.withValues(alpha: 0.4),
      blurRadius: 30,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get playButtonShadow => [
    BoxShadow(
      color: inversePrimary.withValues(alpha: 0.4),
      blurRadius: 30,
      spreadRadius: 0,
    ),
  ];

  // ── ImageFilter for glassmorphism ──────────────────────────
  static ImageFilter get glassBlur => ImageFilter.blur(sigmaX: 24, sigmaY: 24);
  static ImageFilter get glassBlurLight =>
      ImageFilter.blur(sigmaX: 10, sigmaY: 10);

  // ── Theme Data ────────────────────────────────────────────
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    // We use Inter as fallback since Geist isn't in google_fonts.
    // The design uses tight letter spacing and specific weights.
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: onSurface,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 48,
        height: 56 / 48,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 32,
        height: 40 / 32,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 28 / 20,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 24 / 18,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: outline,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05 * 12,
        height: 16 / 12,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: outline,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 12 / 10,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        onPrimaryContainer: onPrimaryContainer,
        inversePrimary: inversePrimary,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        onSecondary: onSecondary,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiary: onTertiary,
        onTertiaryContainer: onTertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        error: error,
        errorContainer: errorContainer,
        onError: onError,
        onErrorContainer: onErrorContainer,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        surfaceTint: surfaceTint,
        surfaceBright: surfaceBright,
        surfaceDim: surfaceDim,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerLowest: surfaceContainerLowest,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: primary),
        iconTheme: const IconThemeData(color: onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: outline,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      iconTheme: const IconThemeData(color: onSurfaceVariant, size: 24),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.05),
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: surfaceBright.withValues(alpha: 0.5),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryContainer.withValues(alpha: 0.5);
          }
          return surfaceContainerHigh;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceContainer,
        modalBackgroundColor: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),
    );
  }
}
