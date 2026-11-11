import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          colors: [AppTheme.forestGreen, AppTheme.naturalGreen],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          color: AppTheme.offWhite.withValues(alpha: 0.85),
          size: 36,
        ),
      ),
    );
  }
}

/// En-tête organique vert forêt (#14532D -> #2E8B57) pour les écrans principaux
class CasamanceCurvedHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CasamanceCurvedHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 14, 20, 28),
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomWaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.forestGreen,
              AppTheme.naturalGreen,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -12,
              child: Icon(
                Icons.eco,
                size: 120,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              left: -18,
              bottom: 8,
              child: Icon(
                Icons.park_outlined,
                size: 92,
                color: AppTheme.warmOrange.withValues(alpha: 0.12),
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
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width * 0.30,
      size.height,
      size.width * 0.62,
      size.height - 14,
    );
    path.quadraticBezierTo(
      size.width * 0.86,
      size.height - 24,
      size.width,
      size.height - 6,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Emblème vectoriel inspiré du Fromager sacré & du soleil de Casamance
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
            ? AppTheme.pureWhite.withValues(alpha: 0.14)
            : AppTheme.lightGreen,
        border: Border.all(
          color: AppTheme.warmOrange,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.16,
            right: size * 0.21,
            child: Container(
              width: size * 0.23,
              height: size * 0.23,
              decoration: const BoxDecoration(
                color: AppTheme.warmOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(
            Icons.park_rounded,
            size: size * 0.54,
            color: darkBackground ? Colors.white : AppTheme.forestGreen,
          ),
          Positioned(
            bottom: size * 0.15,
            child: Container(
              width: size * 0.50,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.naturalGreen,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// En-tête de section éditorial cohérent
class CasamanceSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String actionLabel;

  const CasamanceSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.actionLabel = 'Voir tout',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 12.2,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton.icon(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.forestGreen,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Text(
              actionLabel,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.naturalGreen,
              ),
            ),
            label: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppTheme.naturalGreen,
            ),
          ),
      ],
    );
  }
}

/// Bannière explicite lorsqu'un service backend échoue avec bouton Réessayer
class CasamanceApiErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CasamanceApiErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.warmOrange.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppTheme.warmOrangeDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.warmOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Réessayer',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// État vide réutilisable et élégant
class CasamanceEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CasamanceEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: AppTheme.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppTheme.forestGreen),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestGreen,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bouton cœur Favoris uniforme avec animation discrète
class CasamanceFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const CasamanceFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.pureWhite.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              size: size * 0.54,
              color: isFavorite ? AppTheme.errorRed : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte horizontale compacte pour les sections de l'écran d'accueil
class CasamanceFeaturedSiteCard extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final double width;

  const CasamanceFeaturedSiteCard({
    super.key,
    required this.site,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.width = 236,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = site.tarifEntree <= 0;
    final priceLabel =
        isFree ? 'Gratuit' : '${site.tarifEntree.toStringAsFixed(0)} FCFA';

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'site_photo_home_${site.id}',
                    child: SitePhotoView(
                      site: site,
                      width: width,
                      height: 142,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.14),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.36),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        SiteMediaHelper.labelCategorie(site.categorie),
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CasamanceFavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onToggleFavorite,
                      size: 34,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.warmOrange,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            site.noteMoyenne.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.nom,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13.5,
                            color: AppTheme.naturalGreen,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              site.localisation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            priceLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isFree
                                  ? AppTheme.naturalGreen
                                  : AppTheme.forestGreen,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Découvrir',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

    final bodyPaint = Paint()..color = const Color(0xFF0A1D37);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.56),
        width: w * 0.50,
        height: h * 0.58,
      ),
      bodyPaint,
    );

    final bellyPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.62),
        width: w * 0.30,
        height: h * 0.36,
      ),
      bellyPaint,
    );

    canvas.drawCircle(Offset(w * 0.43, h * 0.40), w * 0.05, bellyPaint);
    canvas.drawCircle(Offset(w * 0.57, h * 0.40), w * 0.05, bellyPaint);

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
