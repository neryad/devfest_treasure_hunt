import 'package:flutter/material.dart';

/// GDG (Google Developer Groups) official brand palette & Typography.
/// Source: https://gdgportharcourt.com.ng/brand-guidelines
abstract final class AppColors {
  // --- Grayscale / Dark surfaces ---
  static const background = Color(0xFF1E1E1E); // Black 02
  static const backgroundGradientTop = Color(0xFF121212); // Deep dark
  static const surface = Color(0xFF28292A); // Material 3 Dark Surface
  static const surfaceAlt = Color(0xFF35363A); // Elevated Surface
  static const border = Color(0x2EFFFFFF); // Subtle border

  // --- Core Colors ---
  static const primary = Color(0xFF4285F4); // Blue 500
  static const success = Color(0xFF34A853); // Green 500
  static const secondary = Color(0xFF34A853); // Secondary action / success
  static const amber = Color(0xFFF9AB00); // Yellow 600
  static const danger = Color(0xFFEA4335); // Red 500

  // --- Halftones (vibrant highlights) ---
  static const primarySoft = Color(0xFF57CAFF); // Halftone Blue
  static const successSoft = Color(0xFF5CDB6D); // Halftone Green
  static const amberSoft = Color(0xFFFFD427); // Halftone Yellow
  static const dangerSoft = Color(0xFFFF7DAF); // Halftone Red

  // --- Pastels ---
  static const pastelBlue = Color(0xFFC3ECF6);
  static const pastelGreen = Color(0xFFCCF6C5);
  static const pastelYellow = Color(0xFFFFE7A5);
  static const pastelRed = Color(0xFFF8D8D8);

  // --- Typography colors ---
  static const textPrimary = Color(0xFFF0F0F0); // Off White
  static const textSecondary = Color(0xFFBDC1C6); // Google Grey 300
  static const textMuted = Color(0xFF80868B); // Google Grey 500
}

abstract final class AppTheme {
  static const List<String> _fontFamilyFallbacks = [
    'Google Sans',
    'Roboto',
    'SF Pro Display',
    'Inter',
    'Segoe UI',
    'sans-serif',
  ];

  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.amber,
      onTertiary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: Colors.white,
    );

    const baseTextStyle = TextStyle(
      fontFamilyFallback: _fontFamilyFallbacks,
      color: AppColors.textPrimary,
    );

    final textTheme = TextTheme(
      displayLarge: baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
      displayMedium: baseTextStyle.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      displaySmall: baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      bodyMedium: baseTextStyle.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.35,
      ),
      labelLarge: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      fontFamilyFallback: _fontFamilyFallbacks,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamilyFallback: _fontFamilyFallbacks,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamilyFallback: _fontFamilyFallbacks,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamilyFallback: _fontFamilyFallbacks,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(
          fontFamilyFallback: _fontFamilyFallbacks,
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primarySoft,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamilyFallback: _fontFamilyFallbacks,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamilyFallback: _fontFamilyFallbacks,
          fontSize: 11,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceAlt,
        contentTextStyle: const TextStyle(
          fontFamilyFallback: _fontFamilyFallbacks,
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
    );
  }
}
