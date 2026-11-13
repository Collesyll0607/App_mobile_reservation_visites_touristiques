import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Officiel — « Casamance Tourisme & Visites »
/// Direction Artistique : AFRICAN TROPICAL LUXURY TRAVEL
/// - Palette :
///   * Vert émeraude (#145C42)
///   * Vert profond (#123B2E)
///   * Ivoire (#FAF8F1)
///   * Sable doré (#E9DDC7)
///   * Terracotta chaleureux (#C8754D)
///   * Texte sombre noble (#202820)
/// - Typographie :
///   * Playfair Display (Titres de prestige, élégance magazine)
///   * Inter (Interface & lisibilité moderne AA)
class AppTheme {
  // === Couleurs Primaires Luxury ===
  static const Color emeraldGreen = Color(0xFF145C42);
  static const Color deepForest = Color(0xFF123B2E);
  static const Color warmIvory = Color(0xFFFAF8F1);
  static const Color goldenSand = Color(0xFFE9DDC7);
  static const Color terracotta = Color(0xFFC8754D);
  static const Color textDark = Color(0xFF202820);
  static const Color textMuted = Color(0xFF5A665D);
  static const Color borderSand = Color(0xFFE2D7C3);
  static const Color borderLight = borderSand;

  // Alias rétrocompatibles
  static const Color forestGreen = emeraldGreen;
  static const Color naturalGreen = Color(0xFF28785A);
  static const Color oceanBlue = Color(0xFF1C6B72);
  static const Color paleGreen = Color(0xFFE8F1EC);
  static const Color warmSand = warmIvory;
  static const Color offWhite = warmIvory;
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color ocreGold = Color(0xFFD4924B);
  static const Color ocreDark = terracotta;
  static const Color accentOrange = terracotta;
  static const Color accentOrangeDark = terracotta;
  static const Color errorRed = Color(0xFFC24134);

  // === Couleurs Mode Sombre (Tropical Night) ===
  static const Color darkBackground = Color(0xFF0D1714);
  static const Color darkSurface = Color(0xFF13221E);
  static const Color darkSurfaceElevated = Color(0xFF1A2F29);
  static const Color darkBorder = Color(0xFF264038);
  static const Color darkText = Color(0xFFF5F3EC);
  static const Color darkTextMuted = Color(0xFFA6B3AB);
  static const Color darkPrimary = Color(0xFF4ADE80);
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
  static const double maxContentWidth = 1220.0;
  static const double maxDetailWidth = 1040.0;
  static const double maxFormWidth = 560.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 980;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 640 && w < 980;
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : pureWhite;

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? darkBackground : warmIvory;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : borderSand;

  static Color textOf(BuildContext context) =>
      isDark(context) ? darkText : textDark;

  static Color mutedOf(BuildContext context) =>
      isDark(context) ? darkTextMuted : textMuted;

  // === Alias rétrocompatibles conservés ===
  static const Color deepForestSoft = naturalGreen;
  static const Color bolongTurquoise = oceanBlue;
  static const Color champagneGold = goldenSand;
  static const Color solarGold = ocreGold;
  static const Color warmOrange = ocreGold;
  static const Color warmOrangeDark = terracotta;
  static const Color hibiscusRed = errorRed;
  static const Color lateriteRed = terracotta;
  static const Color ivorySand = warmIvory;
  static const Color warmCream = pureWhite;
  static const Color cardSurface = pureWhite;
  static const Color sandBorder = borderSand;
  static const Color sageSurface = paleGreen;
  static const Color lightGreen = paleGreen;
  static const Color terracottaSoft = paleGreen;
  static const Color earthBrown = deepForest;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
  static const Color primaryGreen = emeraldGreen;
  static const Color accentGold = ocreGold;
  static const Color backgroundLight = warmIvory;

  /// Style titre d'affichage prestige — Playfair Display
  static TextStyle headingStyle({
    double fontSize = 24,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
    double? letterSpacing,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      height: height ?? 1.18,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing ?? -0.2,
    );
  }

  /// Alias éditorial de prestige (Playfair Display)
  static TextStyle editorialTitle({
    double fontSize = 24,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
    double? letterSpacing,
  }) {
    return headingStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  /// Style corps & composants moderne — Inter
  static TextStyle bodyStyle({
    double fontSize = 14,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      height: height ?? 1.48,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  /// Ombres douces haut de gamme
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> shadowFor(BuildContext context) => isDark(context)
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ]
      : softShadow;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final bg = isDark ? darkBackground : warmIvory;
    final surface = isDark ? darkSurface : pureWhite;
    final text = isDark ? darkText : textDark;
    final border = isDark ? darkBorder : borderSand;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: emeraldGreen,
        onPrimary: pureWhite,
        secondary: terracotta,
        onSecondary: pureWhite,
        tertiary: ocreGold,
        onTertiary: pureWhite,
        error: errorRed,
        onError: pureWhite,
        surface: surface,
        onSurface: text,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(
        bodyColor: text,
        displayColor: text,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius16),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGreen,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: emeraldGreen,
          side: BorderSide(color: border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: emeraldGreen, width: 1.6),
        ),
      ),
    );
  }
}
