import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identité Visuelle Officielle — "Casamance Tourisme & Visites"
/// Palette claire, moderne et professionnelle :
/// - Vert forêt (#14532D) : couleur principale & actions clés
/// - Vert naturel (#2E8B57) : accents nature & localisation
/// - Vert pâle (#E8F5E9) : badges & états doux
/// - Blanc cassé (#F8FAF5) : fond d'écran principal
/// - Orange accent (#F59E0B) : étoiles & mises en avant ponctuelles
/// - Texte (#1F2937) & Gris secondaire (#6B7280)
class AppTheme {
  static const Color forestGreen = Color(0xFF14532D);
  static const Color naturalGreen = Color(0xFF2E8B57);
  static const Color paleGreen = Color(0xFFE8F5E9);
  static const Color offWhite = Color(0xFFF8FAF5);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentOrangeDark = Color(0xFFD97706);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color errorRed = Color(0xFFDC2626);

  // Dimensions responsive standards
  static const double maxContentWidth = 1180.0;
  static const double maxDetailWidth = 1040.0;
  static const double maxFormWidth = 560.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 960;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 640 && w < 960;
  }

  // Alias rétrocompatibles pour préserver l'ensemble des écrans existants
  static const Color deepForest = forestGreen;
  static const Color deepForestSoft = naturalGreen;
  static const Color emeraldGreen = naturalGreen;
  static const Color bolongTurquoise = naturalGreen;
  static const Color champagneGold = accentOrange;
  static const Color solarGold = accentOrange;
  static const Color warmOrange = accentOrange;
  static const Color warmOrangeDark = accentOrangeDark;
  static const Color hibiscusRed = errorRed;
  static const Color lateriteRed = errorRed;
  static const Color ivorySand = offWhite;
  static const Color warmCream = pureWhite;
  static const Color cardSurface = pureWhite;
  static const Color sandBorder = borderLight;
  static const Color sageSurface = paleGreen;
  static const Color lightGreen = paleGreen;
  static const Color terracottaSoft = paleGreen;
  static const Color earthBrown = forestGreen;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
  static const Color primaryGreen = forestGreen;
  static const Color accentGold = accentOrange;
  static const Color backgroundLight = offWhite;

  /// Style titre unifié en Poppins (hiérarchie lisible et contemporaine)
  static TextStyle headingStyle({
    double fontSize = 22,
    Color color = textDark,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.25,
      fontStyle: fontStyle,
      letterSpacing: -0.3,
    );
  }

  /// Alias éditorial conservé, désormais unifié sur Poppins
  static TextStyle editorialTitle({
    double fontSize = 22,
    Color color = textDark,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return headingStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
    );
  }

  /// Style corps de texte Poppins
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

  /// Ombres discrètes type carte de voyage moderne
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
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
        seedColor: forestGreen,
        primary: forestGreen,
        secondary: naturalGreen,
        tertiary: accentOrange,
        error: errorRed,
        surface: pureWhite,
      ),
      scaffoldBackgroundColor: offWhite,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: headingStyle(fontSize: 28),
        headlineMedium: headingStyle(fontSize: 22),
        headlineSmall: headingStyle(fontSize: 18),
        titleLarge: headingStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: textDark,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: textMuted, fontSize: 13),
        hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 13.5),
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
          borderSide: const BorderSide(color: forestGreen, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: forestGreen, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
