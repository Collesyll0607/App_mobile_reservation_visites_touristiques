import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Signature Artistique Officielle — "Casamance Tourisme & Visites"
/// Palette éditoriale chaleureuse inspirée de la Casamance :
/// - Vert forêt profond (#063D2E) : ancrage & profondeur
/// - Vert émeraude (#087A5B) : végétation & fraîcheur
/// - Turquoise bolong (#087E83) : fleuve & bolongs
/// - Or champagne (#D9A441) : lumière & actions phares
/// - Rouge hibiscus (#9B2948) : accent floral & caractère
/// - Ivoire sable (#F4EBDD) : toile de fond respirante
/// - Brun terre (#754A35) : chaleur architecturale & artisanat
class AppTheme {
  static const Color deepForest = Color(0xFF063D2E);
  static const Color emeraldGreen = Color(0xFF087A5B);
  static const Color bolongTurquoise = Color(0xFF087E83);
  static const Color champagneGold = Color(0xFFD9A441);
  static const Color hibiscusRed = Color(0xFF9B2948);
  static const Color ivorySand = Color(0xFFF4EBDD);
  static const Color earthBrown = Color(0xFF754A35);

  // Surfaces éditoriales nuancées
  static const Color warmCream = Color(0xFFFAF5EC);
  static const Color cardSurface = Color(0xFFFCF8F0);
  static const Color sandBorder = Color(0xFFE5D8C5);
  static const Color sageSurface = Color(0xFFE7EFE8);
  static const Color terracottaSoft = Color(0xFFF2E6DC);
  static const Color textDark = Color(0xFF1A211D);
  static const Color textMuted = Color(0xFF665A4E);
  static const Color errorRed = hibiscusRed;
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Alias rétrocompatibles pour garantir l'intégrité des modules existants
  static const Color forestGreen = deepForest;
  static const Color naturalGreen = emeraldGreen;
  static const Color lightGreen = sageSurface;
  static const Color warmOrange = champagneGold;
  static const Color warmOrangeDark = earthBrown;
  static const Color offWhite = ivorySand;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
  static const Color borderLight = sandBorder;
  static const Color deepForestSoft = emeraldGreen;
  static const Color solarGold = champagneGold;
  static const Color lateriteRed = hibiscusRed;
  static const Color primaryGreen = deepForest;
  static const Color accentGold = champagneGold;
  static const Color backgroundLight = ivorySand;

  /// Typographie éditoriale Playfair Display pour les grands titres & destinations
  static TextStyle editorialTitle({
    double fontSize = 24,
    Color color = deepForest,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.18,
      fontStyle: fontStyle,
      letterSpacing: -0.2,
    );
  }

  /// Alias structurant Playfair Display
  static TextStyle headingStyle({
    double fontSize = 22,
    Color color = deepForest,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
  }) {
    return editorialTitle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  /// Typographie Poppins pour les textes, prix, filtres et formulaires
  static TextStyle bodyStyle({
    double fontSize = 14,
    Color color = textDark,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
    );
  }

  /// Ombres profondes et subtiles façon tirage photographique
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: earthBrown.withValues(alpha: 0.10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: deepForest.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textDark,
      displayColor: deepForest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepForest,
        primary: deepForest,
        secondary: emeraldGreen,
        tertiary: champagneGold,
        error: hibiscusRed,
        surface: cardSurface,
      ),
      scaffoldBackgroundColor: ivorySand,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: editorialTitle(fontSize: 32),
        headlineMedium: editorialTitle(fontSize: 25),
        headlineSmall: editorialTitle(fontSize: 21),
        titleLarge: editorialTitle(fontSize: 18),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ivorySand,
        foregroundColor: deepForest,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: deepForest,
        ),
        iconTheme: const IconThemeData(color: deepForest),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: sandBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmCream,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: textMuted, fontSize: 13),
        hintStyle: GoogleFonts.poppins(
          color: textMuted.withValues(alpha: 0.78),
          fontSize: 13.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: sandBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: sandBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: bolongTurquoise, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepForest,
          foregroundColor: ivorySand,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
          foregroundColor: earthBrown,
          side: const BorderSide(color: earthBrown, width: 1.3),
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
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepForest,
        contentTextStyle: GoogleFonts.poppins(color: ivorySand, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
