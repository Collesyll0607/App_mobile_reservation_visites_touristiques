import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';

/// Conteneur centré responsive (évite l'étirement excessif sur ordinateur)
class CasamanceResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const CasamanceResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppTheme.maxContentWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Photographie locale nette avec cadrage adaptatif (BoxFit.cover) et placeholder doux
class SitePhotoView extends StatelessWidget {
  final Patrimoine site;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const SitePhotoView({
    super.key,
    required this.site,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = SiteMediaHelper.primaryAssetForSite(site);
    final image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
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

/// Image d'asset local avec placeholder propre si indisponible
class CasamanceAssetPhoto extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const CasamanceAssetPhoto({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
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

  const _PlaceholderCasamance({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.paleGreen,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.landscape_outlined,
              color: AppTheme.naturalGreen.withValues(alpha: 0.7),
              size: 34,
            ),
            const SizedBox(height: 4),
            Text(
              'Casamance',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.forestGreen.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête fin et moderne (vert forêt modéré, propre et sans surcharge)
class CasamanceCurvedHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CasamanceCurvedHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.forestGreen,
        border: Border(
          bottom: BorderSide(color: Color(0xFF0F3F22)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Logo discret Casamance Tourisme & Visites
class CasamanceEmblemMark extends StatelessWidget {
  final double size;
  final bool darkBackground;

  const CasamanceEmblemMark({
    super.key,
    this.size = 44,
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
            ? Colors.white.withValues(alpha: 0.14)
            : AppTheme.paleGreen,
        border: Border.all(
          color: darkBackground
              ? AppTheme.accentOrange
              : AppTheme.forestGreen.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.park_rounded,
          size: size * 0.54,
          color: darkBackground ? Colors.white : AppTheme.forestGreen,
        ),
      ),
    );
  }
}

/// En-tête de section propre et hiérarchisé
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
    this.actionLabel = 'Tout voir',
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: AppTheme.textMuted,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Text(
              actionLabel,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.forestGreen,
              ),
            ),
            label: const Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: AppTheme.forestGreen,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentOrange.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppTheme.accentOrangeDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              'Réessayer',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// État vide propre
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.paleGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AppTheme.forestGreen),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bouton favori net et contrasté
class CasamanceFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const CasamanceFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.pureWhite.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: size * 0.54,
            color: isFavorite ? AppTheme.errorRed : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}

/// Carte touristique moderne, compacte et cohérente (style Airbnb / Booking)
/// Respecte strictement : photo 16:10 bien cadrée, badge catégorie, icône favori,
/// badge prix discret, nom, note étoile + nb avis, localisation courte,
/// description sur 2 lignes max et bouton « Découvrir ».
class CasamanceSiteCard extends StatefulWidget {
  final Patrimoine site;
  final bool isFavorite;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final String heroTagPrefix;

  const CasamanceSiteCard({
    super.key,
    required this.site,
    required this.isFavorite,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
    required this.onToggleFavorite,
    this.heroTagPrefix = 'site_card',
  });

  @override
  State<CasamanceSiteCard> createState() => _CasamanceSiteCardState();
}

class _CasamanceSiteCardState extends State<CasamanceSiteCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    final isFree = site.tarifEntree <= 0;
    final priceText =
        isFree ? 'Gratuit' : '${site.tarifEntree.toInt()} FCFA';
    final catLabel = SiteMediaHelper.labelCategorie(site.categorie);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? AppTheme.forestGreen.withValues(alpha: 0.35)
                : AppTheme.borderLight,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppTheme.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photo ratio 16:10 cadrée proprement (jamais étirée ni sombre)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedScale(
                          scale: _hovered ? 1.03 : 1.0,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          child: Hero(
                            tag: '${widget.heroTagPrefix}_${site.id}',
                            child: SitePhotoView(site: site, fit: BoxFit.cover),
                          ),
                        ),
                        // Dégradé très léger uniquement en bord haut/bas pour la lisibilité des badges
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.14),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.18),
                              ],
                            ),
                          ),
                        ),
                        // Badge catégorie haut gauche
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.pureWhite.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              catLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                        ),
                        // Favori haut droite
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CasamanceFavoriteButton(
                            isFavorite: widget.isFavorite,
                            onTap: widget.onToggleFavorite,
                            size: 32,
                          ),
                        ),
                        // Badge prix discret bas droite
                        Positioned(
                          bottom: 8,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.pureWhite.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              priceText,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Corps de carte équilibré et lisible
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom + Note avec étoile & nombre d'avis
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              site.nom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppTheme.accentOrange,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                ' (${widget.reviewCount})',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Localisation courte
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppTheme.naturalGreen,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              site.localisation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Description limitée à 2 lignes
                      Text(
                        site.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Pied de carte : bouton Découvrir vert forêt net
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: OutlinedButton(
                                onPressed: widget.onTap,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.forestGreen,
                                  backgroundColor: AppTheme.paleGreen
                                      .withValues(alpha: 0.45),
                                  side: BorderSide(
                                    color: AppTheme.forestGreen
                                        .withValues(alpha: 0.25),
                                  ),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Découvrir',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte horizontale compacte utilisée dans les carrousels de l'Accueil
class CasamanceFeaturedSiteCard extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final double width;
  final int reviewCount;
  final String heroTagPrefix;

  const CasamanceFeaturedSiteCard({
    super.key,
    required this.site,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.width = 272,
    this.reviewCount = 0,
    this.heroTagPrefix = 'site_featured',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CasamanceSiteCard(
        site: site,
        isFavorite: isFavorite,
        rating: site.noteMoyenne,
        reviewCount: reviewCount,
        onTap: onTap,
        onToggleFavorite: onToggleFavorite,
        heroTagPrefix: heroTagPrefix,
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
            color: const Color(0xFF1DC4FF).withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(painter: _WavePenguinPainter()),
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
            color: const Color(0xFFFF7900).withValues(alpha: 0.24),
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
              child: Icon(
                Icons.north_east,
                color: Colors.black87,
                size: size * 0.44,
              ),
            ),
            Transform.translate(
              offset: Offset(size * 0.11, size * 0.08),
              child: Icon(
                Icons.south_west,
                color: Colors.white,
                size: size * 0.44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
