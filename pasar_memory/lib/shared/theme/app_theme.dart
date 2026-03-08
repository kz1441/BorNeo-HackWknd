import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const deepForest = Color(0xFF111827);
  static const forestGradientBottom = Color(0xFF1E3A5F);
  static const warmSurface = Color(0xFFF7F3EC);
  static const amber = Color(0xFFFFB15E);
  static const coral = Color(0xFFFF7A59);
  static const softWhite = Color(0xFFF8FBFF);
  static const charcoal = Color(0xFF172033);
  static const jade = Color(0xFF2FC6A2);
  static const blueGreyBadge = Color(0xFF7A8CA8);
  static const voicePurple = Color(0xFF7B86FF);
  static const glassFill = Color(0x18FFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: amber,
      brightness: Brightness.light,
      primary: amber,
      secondary: jade,
      surface: warmSurface,
    ).copyWith(
      primary: amber,
      onPrimary: charcoal,
      secondary: jade,
      onSecondary: Colors.white,
      tertiary: amber,
      error: coral,
      surface: warmSurface,
      onSurface: charcoal,
      onSurfaceVariant: const Color(0xFF6A6F7A),
      surfaceContainerHighest: const Color(0xFFF0E8DE),
      outline: const Color(0xFFD3CCBF),
      outlineVariant: const Color(0xFFE7E0D7),
    );

    final baseText = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: charcoal,
      displayColor: charcoal,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: deepForest,
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.2),
        displayMedium: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2),
        headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2),
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.5, height: 1.2),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5),
        bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.3, height: 1.5),
        labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
        labelMedium: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, height: 1.2),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: softWhite,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: softWhite,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: warmSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: amber,
          foregroundColor: charcoal,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: warmSurface,
          foregroundColor: charcoal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepForest,
          side: BorderSide(color: deepForest.withValues(alpha: 0.2), width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmSurface,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: charcoal),
        hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF8A7E73)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: amber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: coral, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmSurface,
        selectedColor: amber,
        secondarySelectedColor: amber,
        disabledColor: const Color(0xFFE6D9C8),
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: charcoal),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: charcoal),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: charcoal,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static TextStyle mono({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color color = softWhite,
    double height = 1.2,
  }) {
    return GoogleFonts.dmMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}