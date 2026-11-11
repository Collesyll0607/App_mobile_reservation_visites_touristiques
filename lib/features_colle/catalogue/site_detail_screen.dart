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

/// Écran Détail Immersif d'un Site Touristique — Casamance Tourisme & Visites
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
        backgroundColor: AppTheme.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.share_rounded, color: AppTheme.forestGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Fiche copiée pour partage',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          shareText,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
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
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          // 1. Galerie photographique immersive en-tête
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.forestGreen,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: IconButton(
                    tooltip: 'Partager ce site',
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: _shareSite,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.92),
                  child: IconButton(
                    tooltip: _isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          _isFavorite ? AppTheme.errorRed : AppTheme.forestGreen,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
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
                            Colors.black.withValues(alpha: 0.30),
                            Colors.transparent,
                            AppTheme.forestGreen.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(gallery.length, (i) {
                        final active = i == _galleryIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.warmOrange
                                : Colors.white.withValues(alpha: 0.7),
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

          // 2. Fiche détaillée
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie & note avec nombre réel d'avis
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          SiteMediaHelper.labelCategorie(site.categorie),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warmOrange.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppTheme.warmOrange,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_liveAverage.toStringAsFixed(1)}/5',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              ' • $_reviewsCount avis',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nom complet du site
                  Text(
                    site.nom,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Adresse & localisation
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 17,
                        color: AppTheme.naturalGreen,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${site.localisation} • à ${distZiguinchor.toStringAsFixed(1)} km du centre',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Miniatures de la galerie
                  SizedBox(
                    height: 68,
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
                          child: Container(
                            width: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.warmOrange
                                    : AppTheme.borderLight,
                                width: selected ? 2.2 : 1,
                              ),
                            ),
                            child: CasamanceAssetPhoto(
                              assetPath: gallery[index],
                              width: 96,
                              height: 68,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Informations pratiques (Tarifs, Horaires, Durée)
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          icon: Icons.payments_outlined,
                          title: isFree
                              ? 'Gratuit'
                              : '${site.tarifEntree.toInt()} FCFA',
                          subtitle: 'Tarif visite',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.schedule_rounded,
                          title: site.horairesOuverture,
                          subtitle: 'Horaires',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.directions_walk_rounded,
                          title: SiteMediaHelper.dureeEstimee(site),
                          subtitle: SiteMediaHelper.accesVisite(site),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Description détaillée
                  Text(
                    'Présentation du site',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Text(
                      site.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: AppTheme.textPrimary,
                        height: 1.55,
                      ),
                    ),
                  ),

                  if (site.historique.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Histoire & Patrimoine',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.naturalGreen.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        site.historique,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: AppTheme.textPrimary,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Carte & accès GPS intégré
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderLight),
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
                                color: AppTheme.lightGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: AppTheme.forestGreen,
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
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'GPS : ${site.latitude.toStringAsFixed(4)}, ${site.longitude.toStringAsFixed(4)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
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
                            label: const Text('Voir sur la carte GPS'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Avis & notes
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

      // Barre inférieure fixe avec tarif & bouton "Réserver une visite"
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            border: const Border(top: BorderSide(color: AppTheme.borderLight)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
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
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    isFree
                        ? 'Entrée libre'
                        : '${site.tarifEntree.toInt()} FCFA / pers.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
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
                    backgroundColor: AppTheme.warmOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.forestGreen, size: 19),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
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
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
