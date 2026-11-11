import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';

/// Affiche une photographie locale authentique pour un site touristique donné,
/// avec gestion de fallback élégant.
class SitePhotoView extends StatelessWidget {
  final Patrimoine site;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const SitePhotoView({
    super.key,
    required this.site,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = SiteMediaHelper.primaryAssetForSite(site);
    final image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _PlaceholderCasamance(
        width: width,
        height: height,
        titre: site.nom,
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

/// Affiche une image depuis un chemin d'asset spécifique avec fallback élégant.
class CasamanceAssetPhoto extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const CasamanceAssetPhoto({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _PlaceholderCasamance(
        width: width,
        height: height,
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

class _PlaceholderCasamance extends StatelessWidget {
  final double? width;
  final double? height;
  final String? titre;

  const _PlaceholderCasamance({this.width, this.height, this.titre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.deepForest, AppTheme.bolongTurquoise],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          color: AppTheme.ivorySand.withValues(alpha: 0.8),
          size: 36,
        ),
      ),
    );
  }
}

/// En-tête organique courbé vert forêt inspiré des courbes des bolongs de Casamance
class CasamanceCurvedHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CasamanceCurvedHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 14, 20, 34),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: _BottomWaveClipper(),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.deepForest,
                  AppTheme.deepForestSoft,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Touches végétales subtiles en arrière-plan
                Positioned(
                  right: -24,
                  top: -12,
                  child: Icon(
                    Icons.eco,
                    size: 130,
                    color: AppTheme.bolongTurquoise.withValues(alpha: 0.14),
                  ),
                ),
                Positioned(
                  left: -20,
                  bottom: 10,
                  child: Icon(
                    Icons.park_outlined,
                    size: 100,
                    color: AppTheme.solarGold.withValues(alpha: 0.08),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height,
      size.width * 0.60,
      size.height - 16,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height - 28,
      size.width,
      size.height - 8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Emblème vectoriel inspiré du Fromager sacré & du soleil couchant de Casamance
class CasamanceEmblemMark extends StatelessWidget {
  final double size;
  final bool darkBackground;

  const CasamanceEmblemMark({
    super.key,
    this.size = 96,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: darkBackground
            ? AppTheme.ivorySand.withValues(alpha: 0.12)
            : AppTheme.ivorySand,
        border: Border.all(
          color: AppTheme.solarGold,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.16,
            right: size * 0.22,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: const BoxDecoration(
                color: AppTheme.solarGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(
            Icons.park,
            size: size * 0.56,
            color: darkBackground ? Colors.white : AppTheme.deepForest,
          ),
          Positioned(
            bottom: size * 0.14,
            child: Container(
              width: size * 0.54,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.bolongTurquoise,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo vectoriel net pour Wave Mobile Money
class WaveBrandBadge extends StatelessWidget {
  final double size;

  const WaveBrandBadge({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1DC4FF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DC4FF).withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _WavePenguinPainter(),
      ),
    );
  }
}

class _WavePenguinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Corps du pingouin Wave
    final bodyPaint = Paint()..color = const Color(0xFF0A1D37);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.50, height: h * 0.58),
      bodyPaint,
    );

    // Ventre blanc
    final bellyPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.30, height: h * 0.36),
      bellyPaint,
    );

    // Yeux blancs
    canvas.drawCircle(Offset(w * 0.43, h * 0.40), w * 0.05, bellyPaint);
    canvas.drawCircle(Offset(w * 0.57, h * 0.40), w * 0.05, bellyPaint);

    // Bec orange solaire
    final beakPaint = Paint()..color = const Color(0xFFFFA726);
    final beak = Path()
      ..moveTo(w * 0.45, h * 0.46)
      ..lineTo(w * 0.55, h * 0.46)
      ..lineTo(w * 0.50, h * 0.54)
      ..close();
    canvas.drawPath(beak, beakPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logo vectoriel net pour Orange Money
class OrangeMoneyBrandBadge extends StatelessWidget {
  final double size;

  const OrangeMoneyBrandBadge({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFF7900),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7900).withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(-size * 0.11, -size * 0.06),
              child: Icon(Icons.north_east,
                  color: Colors.black87, size: size * 0.44),
            ),
            Transform.translate(
              offset: Offset(size * 0.11, size * 0.08),
              child: Icon(Icons.south_west,
                  color: Colors.white, size: size * 0.44),
            ),
          ],
        ),
      ),
    );
  }
}
