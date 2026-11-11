import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';

/// Affiche une photographie locale authentique pour un site touristique donné.
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

/// Affiche une photographie locale depuis un chemin d'asset spécifique.
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
          color: AppTheme.ivorySand.withValues(alpha: 0.85),
          size: 36,
        ),
      ),
    );
  }
}

/// Enveloppe animée discrète : micro-zoom photographique et élévation au survol / toucher
class CasamanceInteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const CasamanceInteractiveCard({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  State<CasamanceInteractiveCard> createState() =>
      _CasamanceInteractiveCardState();
}

class _CasamanceInteractiveCardState extends State<CasamanceInteractiveCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.985 : (_hovered ? 1.018 : 1.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Apparition progressive et fluide d'une section à l'affichage
class CasamanceReveal extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const CasamanceReveal({
    super.key,
    required this.child,
    this.delayMs = 60,
  });

  @override
  State<CasamanceReveal> createState() => _CasamanceRevealState();
}

class _CasamanceRevealState extends State<CasamanceReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.045),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delayMs <= 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Découpe organique évoquant les méandres des bolongs de Casamance
class CasamanceBolongWaveClipper extends CustomClipper<Path> {
  final double depth;

  const CasamanceBolongWaveClipper({this.depth = 24});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - depth);
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height,
      size.width * 0.62,
      size.height - depth * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.86,
      size.height - depth * 1.15,
      size.width,
      size.height - depth * 0.35,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CasamanceBolongWaveClipper oldClipper) =>
      oldClipper.depth != depth;
}

/// Fleur d'hibiscus stylisée vectorielle (accent floral subtil sans surcharge)
class CasamanceHibiscusBlossom extends StatelessWidget {
  final double size;
  final double opacity;
  final Color petalColor;
  final Color coreColor;

  const CasamanceHibiscusBlossom({
    super.key,
    this.size = 26,
    this.opacity = 1.0,
    this.petalColor = AppTheme.hibiscusRed,
    this.coreColor = AppTheme.champagneGold,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(size, size),
        painter: _HibiscusPainter(
          petalColor: petalColor,
          coreColor: coreColor,
        ),
      ),
    );
  }
}

class _HibiscusPainter extends CustomPainter {
  final Color petalColor;
  final Color coreColor;

  _HibiscusPainter({required this.petalColor, required this.coreColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.28;
    final paint = Paint()..color = petalColor;

    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((i * 72) * 3.14159265 / 180);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -radius * 0.95),
          width: radius * 1.35,
          height: radius * 1.65,
        ),
        paint,
      );
      canvas.restore();
    }

    canvas.drawCircle(center, size.width * 0.11, Paint()..color = coreColor);
  }

  @override
  bool shouldRepaint(covariant _HibiscusPainter oldDelegate) =>
      oldDelegate.petalColor != petalColor ||
      oldDelegate.coreColor != coreColor;
}

/// Bandeau géométrique inspiré des pagnes tissés diola
class CasamanceWovenMotifStrip extends StatelessWidget {
  final double height;
  final Color color;

  const CasamanceWovenMotifStrip({
    super.key,
    this.height = 8,
    this.color = AppTheme.champagneGold,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _WovenMotifPainter(color: color),
    );
  }
}

class _WovenMotifPainter extends CustomPainter {
  final Color color;

  _WovenMotifPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double step = 14;
    for (double x = 0; x < size.width; x += step) {
      final path = Path()
        ..moveTo(x, size.height / 2)
        ..lineTo(x + step / 2, 1)
        ..lineTo(x + step, size.height / 2)
        ..lineTo(x + step / 2, size.height - 1)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WovenMotifPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// En-tête secondaire équilibré (évite les énormes bandeaux verts uniformes)
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
      clipper: const CasamanceBolongWaveClipper(depth: 20),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.deepForest,
              AppTheme.emeraldGreen,
              AppTheme.bolongTurquoise,
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -10,
              top: 4,
              child: CasamanceHibiscusBlossom(
                size: 86,
                opacity: 0.14,
                petalColor: AppTheme.champagneGold,
                coreColor: AppTheme.ivorySand,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

/// Emblème du Fromager sacré & du soleil couchant de Casamance
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
            ? AppTheme.ivorySand.withValues(alpha: 0.14)
            : AppTheme.warmCream,
        border: Border.all(
          color: AppTheme.champagneGold,
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.earthBrown.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              width: size * 0.22,
              height: size * 0.22,
              decoration: const BoxDecoration(
                color: AppTheme.champagneGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(
            Icons.park_rounded,
            size: size * 0.54,
            color: darkBackground ? AppTheme.ivorySand : AppTheme.deepForest,
          ),
          Positioned(
            bottom: size * 0.15,
            child: Container(
              width: size * 0.48,
              height: 3.5,
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

/// Tuile de catégorie en forme d'arche architecturale avec photographie réelle
class CasamanceArchCategoryTile extends StatelessWidget {
  final String label;
  final String assetPath;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CasamanceArchCategoryTile({
    super.key,
    required this.label,
    required this.assetPath,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 84,
        transform: Matrix4.translationValues(0, selected ? -3 : 0, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(42),
                  bottom: Radius.circular(18),
                ),
                border: Border.all(
                  color: selected
                      ? AppTheme.champagneGold
                      : AppTheme.sandBorder,
                  width: selected ? 2.4 : 1.0,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.champagneGold.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppTheme.earthBrown.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                  bottom: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CasamanceAssetPhoto(
                      assetPath: assetPath,
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: selected
                              ? [
                                  AppTheme.deepForest.withValues(alpha: 0.12),
                                  AppTheme.deepForest.withValues(alpha: 0.88),
                                ]
                              : [
                                  Colors.black.withValues(alpha: 0.10),
                                  AppTheme.earthBrown.withValues(alpha: 0.84),
                                ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 9,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 14,
                            color: selected
                                ? AppTheme.champagneGold
                                : AppTheme.ivorySand,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 12.2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (selected) ...[
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.hibiscusRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.ivorySand, width: 2),
                  ),
                ),
              ),
              const Positioned(
                bottom: -6,
                left: -6,
                child: CasamanceHibiscusBlossom(size: 24),
              ),
            ],
          ],
        ),
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
                style: AppTheme.editorialTitle(
                  fontSize: 21,
                  color: AppTheme.deepForest,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
              foregroundColor: AppTheme.earthBrown,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Text(
              actionLabel,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.earthBrown,
              ),
            ),
            label: const Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppTheme.hibiscusRed,
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
        color: const Color(0xFFFAF0E4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.hibiscusRed.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppTheme.hibiscusRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textDark,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.hibiscusRed,
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

/// État vide raffiné
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.terracottaSoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.champagneGold.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(icon, size: 36, color: AppTheme.earthBrown),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.editorialTitle(
                fontSize: 20,
                color: AppTheme.deepForest,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepForest,
                  foregroundColor: AppTheme.ivorySand,
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

/// Bouton cœur Favoris raffiné avec animation fluide
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
            color: AppTheme.ivorySand.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              size: size * 0.54,
              color: isFavorite ? AppTheme.hibiscusRed : AppTheme.deepForest,
            ),
          ),
        ),
      ),
    );
  }
}

/// Grande carte photographique verticale éditoriale (Hero portrait / carrousel)
class CasamanceFeaturedSiteCard extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final double width;
  final double height;
  final int reviewCount;
  final String heroTagPrefix;

  const CasamanceFeaturedSiteCard({
    super.key,
    required this.site,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.width = 236,
    this.height = 292,
    this.reviewCount = 0,
    this.heroTagPrefix = 'site_photo_home',
  });

  @override
  Widget build(BuildContext context) {
    final isFree = site.tarifEntree <= 0;
    final priceLabel =
        isFree ? 'Accès libre' : '${site.tarifEntree.toStringAsFixed(0)} FCFA';

    return SizedBox(
      width: width,
      height: height,
      child: CasamanceInteractiveCard(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: '${heroTagPrefix}_${site.id}',
              child: SitePhotoView(site: site, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.42, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.transparent,
                    AppTheme.deepForest.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            // Ruban note Or champagne en haut à gauche
            Positioned(
              top: 0,
              left: 14,
              child: Container(
                padding: const EdgeInsets.fromLTRB(9, 10, 9, 11),
                decoration: const BoxDecoration(
                  color: AppTheme.champagneGold,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppTheme.deepForest,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      site.noteMoyenne.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepForest,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CasamanceFavoriteButton(
                isFavorite: isFavorite,
                onTap: onToggleFavorite,
                size: 36,
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bolongTurquoise.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      SiteMediaHelper.labelCategorie(site.categorie),
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    site.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.editorialTitle(
                      fontSize: 17,
                      color: Colors.white,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppTheme.champagneGold,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          site.localisation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.ivorySand.withValues(alpha: 0.90),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.ivorySand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          priceLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepForest,
                          ),
                        ),
                      ),
                      if (reviewCount > 0)
                        Text(
                          '$reviewCount avis',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.ivorySand.withValues(alpha: 0.85),
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
