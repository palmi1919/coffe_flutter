import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores cálidos de cafetería de especialidad
  static const Color espresso = Color(0xFF2C1810);
  static const Color primaryCoffee = Color(0xFF4A2E1B);
  static const Color caramel = Color(0xFFC67C4E);
  static const Color caramelLight = Color(0xFFE5A67B);
  static const Color amberWarm = Color(0xFFD49B42);
  static const Color cinnamon = Color(0xFF8C644F);

  static const Color backgroundLight = Color(0xFFFAF7F2);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCream = Color(0xFFF4ECE4);
  static const Color borderLight = Color(0xFFEADFD5);

  static const Color textDark = Color(0xFF1E140F);
  static const Color textMedium = Color(0xFF5A493F);
  static const Color textLight = Color(0xFF918075);

  static const Color statusSuccess = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFE65100);
  static const Color statusDanger = Color(0xFFC62828);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: caramel,
        onPrimary: Colors.white,
        secondary: primaryCoffee,
        onSecondary: Colors.white,
        error: statusDanger,
        onError: Colors.white,
        surface: surfaceWhite,
        onSurface: textDark,
      ),
      // TextTheme construido directamente (evita el conflicto de tipos
      // entre material_ui y flutter)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.sora(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleSmall: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textMedium,
        ),
        bodyLarge: GoogleFonts.sora(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textDark,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textMedium,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textLight,
        ),
        labelLarge: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: const IconThemeData(color: textDark),
        centerTitle: true,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      // CardThemeData en lugar de CardTheme
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: caramel,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCoffee,
          side: const BorderSide(color: borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: caramel, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusDanger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusDanger, width: 1.8),
        ),
        labelStyle: GoogleFonts.sora(
          fontSize: 14,
          color: textMedium,
        ),
        hintStyle: GoogleFonts.sora(
          fontSize: 14,
          color: textLight,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: espresso,
        contentTextStyle: GoogleFonts.sora(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Sombras suaves reutilizables
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: primaryCoffee.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryCoffee.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}