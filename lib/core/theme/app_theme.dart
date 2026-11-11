import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identité Visuelle Officielle "Casamance Tourisme & Visites"
/// Palette :
/// - Vert forêt (#14532D) : couleur dominante
/// - Vert naturel (#2E8B57) : accents naturels & badges
/// - Vert clair (#E8F5E9) : surfaces douces & chips
/// - Orange chaleureux (#F59E0B) : actions importantes & étoiles
/// - Blanc cassé (#F8FAF5) : fond d'écran principal
/// - Blanc (#FFFFFF) : cartes & surfaces élevées
/// - Texte principal (#1F2937)
/// - Texte secondaire (#6B7280)
class AppTheme {
  static const Color forestGreen = Color(0xFF14532D);
  static const Color naturalGreen = Color(0xFF2E8B57);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color warmOrange = Color(0xFFF59E0B);
  static const Color warmOrangeDark = Color(0xFFD97706);
  static const Color offWhite = Color(0xFFF8FAF5);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5ECE6);
  static const Color errorRed = Color(0xFFDC2626);

  // Alias conservés pour compatibilité avec les modules existants
  static const Color deepForest = forestGreen;
  static const Color deepForestSoft = naturalGreen;
  static const Color bolongTurquoise = naturalGreen;
  static const Color solarGold = warmOrange;
  static const Color lateriteRed = errorRed;
  static const Color ivorySand = offWhite;
  static const Color cardSurface = pureWhite;
  static const Color sageSurface = lightGreen;
  static const Color textDark = textPrimary;
  static const Color textMuted = textSecondary;
  static const Color primaryGreen = forestGreen;
  static const Color accentGold = warmOrange;
  static const Color backgroundLight = offWhite;

  /// Style titre principal unifié en Poppins (hiérarchie éditoriale moderne)
  static TextStyle headingStyle({
    double fontSize = 22,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.25,
      letterSpacing: -0.2,
    );
  }

  /// Alias conservé : utilise désormais Poppins pour une typographie cohérente
  static TextStyle editorialTitle({
    double fontSize = 22,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
  }) {
    return headingStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  /// Style corps de texte Poppins
  static TextStyle bodyStyle({
    double fontSize = 14,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Ombres douces et élégantes pour les cartes
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: forestGreen.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forestGreen,
        primary: forestGreen,
        secondary: naturalGreen,
        tertiary: warmOrange,
        error: errorRed,
        surface: pureWhite,
      ),
      scaffoldBackgroundColor: offWhite,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: headingStyle(fontSize: 28),
        headlineMedium: headingStyle(fontSize: 22),
        headlineSmall: headingStyle(fontSize: 18),
        titleLarge: headingStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: forestGreen,
        foregroundColor: pureWhite,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: pureWhite,
        ),
        iconTheme: const IconThemeData(color: pureWhite),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.poppins(
          color: textSecondary.withValues(alpha: 0.75),
          fontSize: 13.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: naturalGreen, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: forestGreen, width: 1.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightGreen,
        selectedColor: forestGreen,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: forestGreen,
        contentTextStyle: GoogleFonts.poppins(color: pureWhite, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
