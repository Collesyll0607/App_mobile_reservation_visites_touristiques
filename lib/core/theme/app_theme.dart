import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identité Visuelle Officielle "Casamance Tourisme"
/// Palette :
/// - Vert forêt profonde (#063D2E) : couleur dominante
/// - Turquoise bolong (#087E83) : accents interactifs
/// - Or solaire (#D9A441) : actions importantes, éléments premium
/// - Rouge latérite (#8B2635) : touches de caractère
/// - Ivoire sable (#F4EBDD) : surfaces douces et lumineuses
class AppTheme {
  static const Color deepForest = Color(0xFF063D2E);
  static const Color deepForestSoft = Color(0xFF0B523E);
  static const Color bolongTurquoise = Color(0xFF087E83);
  static const Color solarGold = Color(0xFFD9A441);
  static const Color lateriteRed = Color(0xFF8B2635);
  static const Color ivorySand = Color(0xFFF4EBDD);

  static const Color cardSurface = Color(0xFFFCF9F4);
  static const Color sageSurface = Color(0xFFE4ECE5);
  static const Color textDark = Color(0xFF172620);
  static const Color textMuted = Color(0xFF5E6D66);

  // Alias de rétrocompatibilité
  static const Color primaryGreen = deepForest;
  static const Color accentGold = solarGold;
  static const Color backgroundLight = ivorySand;

  /// Style éditorial Playfair Display pour les grands titres
  static TextStyle editorialTitle({
    double fontSize = 24,
    Color color = textDark,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Style Poppins pour le corps de texte et l'interface
  static TextStyle bodyStyle({
    double fontSize = 14,
    Color color = textDark,
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

  /// Ombres douces et réalistes pour cartes
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: deepForest.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textDark,
      displayColor: textDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepForest,
        primary: deepForest,
        secondary: bolongTurquoise,
        tertiary: solarGold,
        error: lateriteRed,
        surface: cardSurface,
      ),
      scaffoldBackgroundColor: ivorySand,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: editorialTitle(fontSize: 30),
        headlineMedium: editorialTitle(fontSize: 24),
        headlineSmall: editorialTitle(fontSize: 20),
        titleLarge: editorialTitle(fontSize: 18),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deepForest,
        foregroundColor: ivorySand,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: deepForest.withValues(alpha: 0.07)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: textMuted, fontSize: 13),
        hintStyle: GoogleFonts.poppins(color: textMuted.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: deepForest.withValues(alpha: 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: deepForest.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bolongTurquoise, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepForest,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepForest,
          side: const BorderSide(color: deepForest, width: 1.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sageSurface,
        selectedColor: solarGold,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepForest,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
