import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/reservation/booking_form_screen.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../map/location_service.dart';
import '../map/map_explore_screen.dart';
import '../reviews/reviews_section.dart';
import '../reviews/reviews_service.dart';

/// Fiche Éditoriale d'une Destination — Casamance Tourisme & Visites
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue)
class SiteDetailScreen extends StatefulWidget {
  final Patrimoine site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final PageController _galleryController = PageController();

  bool _isFavorite = false;
  int _galleryIndex = 0;
  double _liveAverage = 4.8;
  int _reviewsCount = 0;

  @override
  void initState() {
    super.initState();
    _liveAverage = widget.site.noteMoyenne;
    _checkFavorite();
    _loadReviewStats();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _checkFavorite() async {
    final fav = await _favoritesService.isFavorite(widget.site.id);
    if (!mounted) return;
    setState(() => _isFavorite = fav);
  }

  Future<void> _loadReviewStats() async {
    final reviews = await ReviewsService.getReviewsForSite(widget.site.id);
    final avg = await ReviewsService.getAverageRating(
      widget.site.id,
      widget.site.noteMoyenne,
    );
    if (!mounted) return;
    setState(() {
      _reviewsCount = reviews.length;
      _liveAverage = avg;
    });
  }

  Future<void> _toggleFavorite() async {
    final isNowFavorite = await _favoritesService.toggleFavorite(widget.site);
    if (!mounted) return;
    setState(() => _isFavorite = isNowFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite
              ? '${widget.site.nom} ajouté aux favoris'
              : '${widget.site.nom} retiré des favoris',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareSite() async {
    final site = widget.site;
    final priceText = site.tarifEntree <= 0
        ? 'Entrée gratuite'
        : '${site.tarifEntree.toInt()} FCFA / personne';
    final shareText = 'Découvrez "${site.nom}" en Casamance (${site.localisation}) — '
        '$priceText • Horaires : ${site.horairesOuverture} • '
        'Note : ${_liveAverage.toStringAsFixed(1)}/5\n'
        'Via Casamance Tourisme & Visites';

    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ivorySand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.share_rounded, color: AppTheme.earthBrown),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Fiche copiée pour partage',
                style: AppTheme.editorialTitle(
                  fontSize: 18,
                  color: AppTheme.deepForest,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          shareText,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: AppTheme.textMuted,
            height: 1.48,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepForest,
              foregroundColor: AppTheme.ivorySand,
            ),
            child: const Text('Parfait'),
          ),
        ],
      ),
    );
  }

  void _openFullScreenPhoto(String assetPath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: InteractiveViewer(
                child: CasamanceAssetPhoto(
                  assetPath: assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    final gallery = SiteMediaHelper.galleryAssetsForSite(site);
    final distZiguinchor = LocationService.calculerDistanceKm(
      lat1: 12.5833,
      lon1: -16.2719,
      lat2: site.latitude,
      lon2: site.longitude,
    );
    final isFree = site.tarifEntree <= 0;

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: CustomScrollView(
        slivers: [
          // 1. Grande galerie panoramique en courbe organique
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AppTheme.ivorySand,
            foregroundColor: AppTheme.deepForest,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppTheme.ivorySand.withValues(alpha: 0.90),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.deepForest,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CircleAvatar(
                  backgroundColor: AppTheme.ivorySand.withValues(alpha: 0.90),
                  child: IconButton(
                    tooltip: 'Partager ce site',
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppTheme.earthBrown,
                    ),
                    onPressed: _shareSite,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
                child: CircleAvatar(
                  backgroundColor: AppTheme.ivorySand.withValues(alpha: 0.92),
                  child: IconButton(
                    tooltip: _isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite
                          ? AppTheme.hibiscusRed
                          : AppTheme.deepForest,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: const CasamanceBolongWaveClipper(depth: 20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _galleryController,
                      itemCount: gallery.length,
                      onPageChanged: (idx) =>
                          setState(() => _galleryIndex = idx),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _openFullScreenPhoto(gallery[index]),
                          child: CasamanceAssetPhoto(
                            assetPath: gallery[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.transparent,
                              AppTheme.deepForest.withValues(alpha: 0.62),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(gallery.length, (i) {
                          final active = i == _galleryIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 22 : 7,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.champagneGold
                                  : Colors.white.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Corps éditorial
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.earthBrown,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          SiteMediaHelper.labelCategorie(site.categorie),
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ivorySand,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CasamanceHibiscusBlossom(size: 19, opacity: 0.85),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.champagneGold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                AppTheme.champagneGold.withValues(alpha: 0.65),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppTheme.champagneGold,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_liveAverage.toStringAsFixed(1)}/5',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepForest,
                              ),
                            ),
                            Text(
                              ' • $_reviewsCount avis',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppTheme.earthBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    site.nom,
                    style: AppTheme.editorialTitle(
                      fontSize: 28,
                      color: AppTheme.deepForest,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppTheme.bolongTurquoise,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${site.localisation} • à ${distZiguinchor.toStringAsFixed(1)} km du centre',
                          style: GoogleFonts.poppins(
                            fontSize: 12.8,
                            color: AppTheme.earthBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mosaïque miniatures cliquables asymétriques
                  SizedBox(
                    height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final selected = index == _galleryIndex;
                        return GestureDetector(
                          onTap: () {
                            _galleryController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOut,
                            );
                          },
                          onLongPress: () =>
                              _openFullScreenPhoto(gallery[index]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: index.isEven ? 114 : 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(index.isEven ? 16 : 36),
                                bottom: const Radius.circular(14),
                              ),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.champagneGold
                                    : AppTheme.sandBorder,
                                width: selected ? 2.4 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(index.isEven ? 14 : 34),
                                bottom: const Radius.circular(12),
                              ),
                              child: CasamanceAssetPhoto(
                                assetPath: gallery[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          icon: Icons.payments_outlined,
                          title: isFree
                              ? 'Gratuit'
                              : '${site.tarifEntree.toInt()} FCFA',
                          subtitle: 'Tarif visite',
                          accent: AppTheme.champagneGold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.schedule_rounded,
                          title: site.horairesOuverture,
                          subtitle: 'Horaires',
                          accent: AppTheme.bolongTurquoise,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.directions_walk_rounded,
                          title: SiteMediaHelper.dureeEstimee(site),
                          subtitle: SiteMediaHelper.accesVisite(site),
                          accent: AppTheme.hibiscusRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Text(
                    'L’esprit du lieu',
                    style: AppTheme.editorialTitle(
                      fontSize: 20,
                      color: AppTheme.deepForest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warmCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.sandBorder),
                    ),
                    child: Text(
                      site.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: AppTheme.textDark,
                        height: 1.58,
                      ),
                    ),
                  ),

                  if (site.historique.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Histoire & Récit patrimonial',
                      style: AppTheme.editorialTitle(
                        fontSize: 20,
                        color: AppTheme.earthBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.terracottaSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.earthBrown.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            site.historique,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              color: AppTheme.textDark,
                              height: 1.58,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const CasamanceWovenMotifStrip(
                            height: 6,
                            color: AppTheme.earthBrown,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Localisation GPS intégrée
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.deepForest,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.bolongTurquoise
                                    .withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: AppTheme.champagneGold,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Localisation & Itinéraire GPS',
                                    style: AppTheme.editorialTitle(
                                      fontSize: 16.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Coordonnées : ${site.latitude.toStringAsFixed(4)}, ${site.longitude.toStringAsFixed(4)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppTheme.ivorySand
                                          .withValues(alpha: 0.84),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.champagneGold,
                              side: const BorderSide(
                                color: AppTheme.champagneGold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MapExploreScreen(initialSite: site),
                                ),
                              );
                            },
                            icon: const Icon(Icons.near_me_rounded, size: 18),
                            label: const Text('Tracer l’itinéraire sur la carte'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  ReviewsSection(
                    patrimoineId: site.id,
                    initialAverage: site.noteMoyenne,
                    onReviewsChanged: _loadReviewStats,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: BoxDecoration(
            color: AppTheme.warmCream,
            border: const Border(top: BorderSide(color: AppTheme.sandBorder)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.earthBrown.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarif d\'entrée',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    isFree
                        ? 'Entrée libre'
                        : '${site.tarifEntree.toInt()} FCFA / pers.',
                    style: AppTheme.editorialTitle(
                      fontSize: 18,
                      color: AppTheme.deepForest,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingFormScreen(site: site),
                      ),
                    );
                    _checkFavorite();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.champagneGold,
                    foregroundColor: AppTheme.deepForest,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 19),
                  label: Text(
                    'Réserver une visite',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.warmCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.sandBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepForest,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
