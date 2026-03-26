import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "The Quiet Ceremony" — Japandi Design System for SlideCraft
/// Fusion of wabi-sabi organics and Scandinavian functionalism.
class AppTheme {
  AppTheme._();

  // ─── Light Mode Palette ───
  static const Color _surfaceLight = Color(0xFFFFFBFF);          // #fffbff — washi paper canvas
  static const Color _surfaceContainerLight = Color(0xFFF8F4E5); // #f8f4e5 — warm parchment
  static const Color _surfaceContainerLowLight = Color(0xFFFAF7EF);
  static const Color _surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color _surfaceContainerHighLight = Color(0xFFF0ECDD);
  static const Color _onSurfaceLight = Color(0xFF39382A);        // #39382a — warm charcoal
  static const Color _primaryLight = Color(0xFF5F5E5E);          // #5f5e5e — stone grey
  static const Color _onPrimaryFixedLight = Color(0xFF3F3F3F);   // #3f3f3f — deep authority
  static const Color _secondaryLight = Color(0xFF57695B);        // #57695b — sage green
  static const Color _secondaryContainerLight = Color(0xFFDAE8DC);
  static const Color _outlineVariantLight = Color(0xFFBDBaa7);   // #bdbaa7 — ghost border
  static const Color _errorLight = Color(0xFFA64542);            // #a64542 — muted terracotta

  // ─── Dark Mode Palette ───
  static const Color _surfaceDark = Color(0xFF1A1915);           // deep charcoal
  static const Color _surfaceContainerDark = Color(0xFF25241A);
  static const Color _surfaceContainerLowDark = Color(0xFF201F17);
  static const Color _surfaceContainerLowestDark = Color(0xFF151410);
  static const Color _surfaceContainerHighDark = Color(0xFF2F2E24);
  static const Color _onSurfaceDark = Color(0xFFEDE8DC);         // warm off-white
  static const Color _primaryDark = Color(0xFFD4D3D0);           // light taupe
  static const Color _onPrimaryFixedDark = Color(0xFFFFFFFF);
  static const Color _secondaryDark = Color(0xFF7EB89E);         // lighter sage
  static const Color _secondaryContainerDark = Color(0xFF3A5040);
  static const Color _outlineVariantDark = Color(0xFF4A4839);
  static const Color _errorDark = Color(0xFFD4817E);

  // ─── Ambient Shadow (tinted, never pure black) ───
  static List<BoxShadow> ambientShadow({double opacity = 0.06}) => [
    BoxShadow(
      color: const Color(0xFF39382A).withOpacity(opacity),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  // ─── Ghost Border (outline_variant at 20%) ───
  static BorderSide ghostBorder(BuildContext context) {
    final theme = Theme.of(context);
    return BorderSide(
      color: theme.colorScheme.outlineVariant.withOpacity(0.20),
      width: 1,
    );
  }

  // ─── Light Theme ───
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: _surfaceLight,
        surfaceContainerLowest: _surfaceContainerLowestLight,
        surfaceContainerLow: _surfaceContainerLowLight,
        surfaceContainer: _surfaceContainerLight,
        surfaceContainerHigh: _surfaceContainerHighLight,
        onSurface: _onSurfaceLight,
        primary: _primaryLight,
        onPrimary: _surfaceLight,
        primaryContainer: _surfaceContainerLight,
        secondary: _secondaryLight,
        onSecondary: _surfaceLight,
        secondaryContainer: _secondaryContainerLight,
        outlineVariant: _outlineVariantLight,
        error: _errorLight,
      ),
      scaffoldBackgroundColor: _surfaceLight,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _surfaceLight,
        foregroundColor: _onSurfaceLight,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceContainerLowestLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _onPrimaryFixedLight,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: _surfaceLight,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ─── Dark Theme ───
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: _surfaceDark,
        surfaceContainerLowest: _surfaceContainerLowestDark,
        surfaceContainerLow: _surfaceContainerLowDark,
        surfaceContainer: _surfaceContainerDark,
        surfaceContainerHigh: _surfaceContainerHighDark,
        onSurface: _onSurfaceDark,
        primary: _primaryDark,
        onPrimary: _surfaceDark,
        primaryContainer: _surfaceContainerDark,
        secondary: _secondaryDark,
        onSecondary: _surfaceDark,
        secondaryContainer: _secondaryContainerDark,
        outlineVariant: _outlineVariantDark,
        error: _errorDark,
      ),
      scaffoldBackgroundColor: _surfaceDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _surfaceDark,
        foregroundColor: _onSurfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceContainerDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _onPrimaryFixedDark,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: _surfaceDark,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ─── Typography: Noto Serif (Display/Headline) + Plus Jakarta Sans (Body/Label) ───
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? _onSurfaceLight
        : _onSurfaceDark;

    return TextTheme(
      // Display — Editorial voice (Noto Serif)
      displayLarge: GoogleFonts.notoSerif(
        fontSize: 48, fontWeight: FontWeight.w600, height: 1.2, color: textColor,
      ),
      displayMedium: GoogleFonts.notoSerif(
        fontSize: 36, fontWeight: FontWeight.w600, height: 1.3, color: textColor,
      ),
      displaySmall: GoogleFonts.notoSerif(
        fontSize: 28, fontWeight: FontWeight.w600, height: 1.4, color: textColor,
      ),

      // Headline — Sectioning (Noto Serif)
      headlineLarge: GoogleFonts.notoSerif(
        fontSize: 24, fontWeight: FontWeight.w600, height: 1.4, color: textColor,
      ),
      headlineMedium: GoogleFonts.notoSerif(
        fontSize: 20, fontWeight: FontWeight.w600, height: 1.5, color: textColor,
      ),
      headlineSmall: GoogleFonts.notoSerif(
        fontSize: 18, fontWeight: FontWeight.w600, height: 1.5, color: textColor,
      ),

      // Title — Functional (Plus Jakarta Sans)
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 20, fontWeight: FontWeight.w600, height: 1.4, color: textColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: textColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: textColor,
      ),

      // Body — Readable (Plus Jakarta Sans)
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w400, height: 1.8, color: textColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: textColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: textColor,
      ),

      // Label — All-caps functional (Plus Jakarta Sans)
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.5,
        letterSpacing: 0.28, color: textColor, // 2% of 14
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.5,
        letterSpacing: 0.24, color: textColor, // 2% of 12
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w500, height: 1.4,
        letterSpacing: 0.33, color: textColor, // 3% of 11
      ),
    );
  }
}
