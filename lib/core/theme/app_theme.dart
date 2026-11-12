import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Officiel — « Casamance Tourisme & Visites »
/// - Palette claire (Sable & Mangrove) : vert profond (#14532D), bleu océan (#0E7490),
///   sable chaud (#FBF8F3), ocre doré (#F59E0B / #B45309), contraste AA minimum.
/// - Mode sombre cohérent (Mangrove nocturne #0B1410 / #13221B).
/// - Typographie : Fraunces (titres d'affichage) + Plus Jakarta Sans (corps & interface).
/// - Grille harmonieuse sur 8px et rayons cohérents (12 / 16 / 24 px).
class AppTheme {
  // === Couleurs Mode Clair (Sable & Mangrove) ===
  static const Color forestGreen = Color(0xFF14532D);
  static const Color naturalGreen = Color(0xFF2E8B57);
  static const Color oceanBlue = Color(0xFF0E7490);
  static const Color paleGreen = Color(0xFFE8F5E9);
  static const Color warmSand = Color(0xFFFBF8F3);
  static const Color offWhite = warmSand;
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color ocreGold = Color(0xFFF59E0B);
  static const Color ocreDark = Color(0xFFB45309);
  static const Color accentOrange = ocreGold;
  static const Color accentOrangeDark = ocreDark;
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF4B5563);
  static const Color borderSand = Color(0xFFE7E2D8);
  static const Color borderLight = borderSand;
  static const Color errorRed = Color(0xFFDC2626);

  // === Couleurs Mode Sombre (Mangrove nocturne) ===
  static const Color darkBackground = Color(0xFF0B1410);
  static const Color darkSurface = Color(0xFF13221B);
  static const Color darkSurfaceElevated = Color(0xFF192D24);
  static const Color darkBorder = Color(0xFF234033);
  static const Color darkText = Color(0xFFF3F4F6);
  static const Color darkTextMuted = Color(0xFF9CA3AF);
  static const Color darkPrimary = Color(0xFF34D399);
  static const Color darkOcean = Color(0xFF38BDF8);
  static const Color darkGold = Color(0xFFFBBF24);

  // === Contrôleur global Clair / Sombre ===
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static void toggleThemeMode() {
    themeModeNotifier.value = themeModeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  // === Grille 8px & Rayons ===
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;

  // === Dimensions responsive standards ===
  static const double maxContentWidth = 1180.0;
  static const double maxDetailWidth = 1040.0;
  static const double maxFormWidth = 560.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 960;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 640 && w < 960;
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : pureWhite;

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? darkBackground : warmSand;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : borderSand;

  static Color textOf(BuildContext context) =>
      isDark(context) ? darkText : textDark;

  static Color mutedOf(BuildContext context) =>
      isDark(context) ? darkTextMuted : textMuted;

  // === Alias rétrocompatibles pour préserver tous les écrans existants ===
  static const Color deepForest = forestGreen;
  static const Color deepForestSoft = naturalGreen;
  static const Color emeraldGreen = naturalGreen;
  static const Color bolongTurquoise = oceanBlue;
  static const Color champagneGold = ocreGold;
  static const Color solarGold = ocreGold;
  static const Color warmOrange = ocreGold;
  static const Color warmOrangeDark = ocreDark;
  static const Color hibiscusRed = errorRed;
  static const Color lateriteRed = errorRed;
  static const Color ivorySand = warmSand;
  static const Color warmCream = pureWhite;
  static const Color cardSurface = pureWhite;
  static const Color sandBorder = borderSand;
  static const Color sageSurface = paleGreen;
  static const Color lightGreen = paleGreen;
  static const Color terracottaSoft = paleGreen;
  static const Color earthBrown = forestGreen;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
  static const Color primaryGreen = forestGreen;
  static const Color accentGold = ocreGold;
  static const Color backgroundLight = warmSand;

  /// Style titre d'affichage unifié en Fraunces (éditorial & chaleureux)
  static TextStyle headingStyle({
    double fontSize = 22,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      height: height ?? 1.2,
      fontStyle: fontStyle,
      letterSpacing: -0.35,
    );
  }

  /// Alias éditorial conservé (Fraunces)
  static TextStyle editorialTitle({
    double fontSize = 22,
    Color? color,
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

  /// Style corps & interface en Plus Jakarta Sans (haute lisibilité AA)
  static TextStyle bodyStyle({
    double fontSize = 14,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      height: height ?? 1.45,
      fontStyle: fontStyle,
    );
  }

  /// Ombres discrètes et aérées
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> shadowFor(BuildContext context) => isDark(context)
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ]
      : softShadow;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final bg = isDark ? darkBackground : warmSand;
    final surface = isDark ? darkSurface : pureWhite;
    final border = isDark ? darkBorder : borderSand;
    final fg = isDark ? darkText : textDark;
    final muted = isDark ? darkTextMuted : textMuted;
    final primary = isDark ? darkPrimary : forestGreen;
    final onPrimary = isDark ? darkBackground : pureWhite;
    final secondary = isDark ? darkOcean : oceanBlue;
    final tertiary = isDark ? darkGold : ocreGold;

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: fg,
      displayColor: fg,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: isDark ? darkBackground : pureWhite,
        tertiary: tertiary,
        onTertiary: textDark,
        error: errorRed,
        onError: pureWhite,
        surface: surface,
        onSurface: fg,
      ),
      scaffoldBackgroundColor: bg,
      focusColor: secondary.withValues(alpha: 0.25),
      dividerColor: border,
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingStyle(fontSize: 44, color: fg),
        headlineLarge: headingStyle(fontSize: 28, color: fg),
        headlineMedium: headingStyle(fontSize: 22, color: fg),
        headlineSmall: headingStyle(fontSize: 18, color: fg),
        titleLarge: bodyStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: fg,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
        iconTheme: IconThemeData(color: fg),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius16),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: muted, fontSize: 13),
        hintStyle: GoogleFonts.plusJakartaSans(color: muted, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.16),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? darkSurfaceElevated : forestGreen,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: pureWhite,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
      ),
    );
  }
}
