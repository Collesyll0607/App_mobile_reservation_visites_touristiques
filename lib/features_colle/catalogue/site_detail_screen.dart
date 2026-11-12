import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Fiche Détaillée d'un Site Touristique — Design System v2
/// Galerie photos immersive, typographie Fraunces + Plus Jakarta Sans,
/// Dark-aware, encart de réservation sticky/desktop avec ombres douces.
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
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        backgroundColor: AppTheme.forestGreen,
        content: Row(
          children: [
            Icon(
              isNowFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isNowFavorite
                    ? '${widget.site.nom} ajouté aux favoris'
                    : '${widget.site.nom} retiré des favoris',
                style: AppTheme.bodyStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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

    final surface = AppTheme.surfaceOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius16),
        ),
        title: Row(
          children: [
            const Icon(Icons.share_rounded, color: AppTheme.forestGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Lien copié dans le presse-papiers',
                style: AppTheme.headingStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          shareText,
          style: AppTheme.bodyStyle(
            fontSize: 13,
            color: mutedCol,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius16),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radius16),
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

  Future<void> _goToBooking() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingFormScreen(site: widget.site)),
    );
    _checkFavorite();
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
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final surface = AppTheme.surfaceOf(context);
    final background = AppTheme.backgroundOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          site.nom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.headingStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Partager ce site',
            onPressed: _shareSite,
            icon: Icon(Icons.share_outlined, color: textCol),
          ),
          IconButton(
            tooltip: _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppTheme.errorRed : textCol,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        child: CasamanceResponsiveContainer(
          maxWidth: AppTheme.maxDetailWidth,
          padding: EdgeInsets.fromLTRB(
            isWide ? 24 : 16,
            20,
            isWide ? 24 : 16,
            36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── GALERIE PHOTO IMMERSIVE ──
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radius16),
                child: Container(
                  height: isWide ? 380 : 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surface,
                    boxShadow: AppTheme.shadowFor(context),
                  ),
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
                      // Badge compteur photos
                      Positioned(
                        bottom: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(AppTheme.radius24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                '${_galleryIndex + 1} / ${gallery.length}',
                                style: AppTheme.bodyStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── MINIATURES DE LA GALERIE ──
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
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radius12),
                          border: Border.all(
                            color: selected ? AppTheme.forestGreen : border,
                            width: selected ? 2.5 : 1,
                          ),
                          boxShadow: selected ? AppTheme.softShadow : [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radius12 - 2),
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
              const SizedBox(height: 26),

              // ── CORPS PRINCIPAL (2 COLONNES BUREAU / 1 COLONNE MOBILE) ──
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildMainInfoColumn(distZiguinchor, surface, border, textCol, mutedCol),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      flex: 4,
                      child: _buildDesktopBookingCard(distZiguinchor, surface, border, textCol, mutedCol),
                    ),
                  ],
                )
              else
                _buildMainInfoColumn(distZiguinchor, surface, border, textCol, mutedCol),
            ],
          ),
        ),
      ),
      // ── BARRE DE RÉSERVATION COLLANTE MOBILE ──
      bottomNavigationBar: isWide
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border(top: BorderSide(color: border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
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
                          style: AppTheme.bodyStyle(
                            fontSize: 11.5,
                            color: mutedCol,
                          ),
                        ),
                        Text(
                          site.tarifEntree <= 0
                              ? 'Gratuit'
                              : '${site.tarifEntree.toInt()} FCFA',
                          style: AppTheme.headingStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _goToBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forestGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radius12),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: Text(
                            'Réserver une visite',
                            style: AppTheme.bodyStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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

  Widget _buildMainInfoColumn(
    double distZiguinchor,
    Color surface,
    Color border,
    Color textCol,
    Color mutedCol,
  ) {
    final site = widget.site;
    final isFree = site.tarifEntree <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge Catégorie & Note moyenne
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.paleGreen,
                borderRadius: BorderRadius.circular(AppTheme.radius24),
              ),
              child: Text(
                SiteMediaHelper.labelCategorie(site.categorie),
                style: AppTheme.bodyStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.star_rounded,
              color: AppTheme.ocreGold,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '${_liveAverage.toStringAsFixed(1)}/5',
              style: AppTheme.bodyStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textCol,
              ),
            ),
            Text(
              ' • $_reviewsCount avis',
              style: AppTheme.bodyStyle(
                fontSize: 13,
                color: mutedCol,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Titre du site en Fraunces
        Text(
          site.nom,
          style: AppTheme.headingStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textCol,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Localisation
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 17,
              color: AppTheme.naturalGreen,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${site.localisation} • à ${distZiguinchor.toStringAsFixed(1)} km du centre-ville',
                style: AppTheme.bodyStyle(
                  fontSize: 13.5,
                  color: mutedCol,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // ── 3 CARTES D'INFOS PRATIQUES ──
        Row(
          children: [
            Expanded(
              child: _infoBox(
                Icons.payments_outlined,
                isFree ? 'Gratuit' : '${site.tarifEntree.toInt()} FCFA',
                'Tarif visite',
                surface,
                border,
                textCol,
                mutedCol,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoBox(
                Icons.schedule_rounded,
                site.horairesOuverture,
                'Horaires',
                surface,
                border,
                textCol,
                mutedCol,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoBox(
                Icons.directions_walk_rounded,
                SiteMediaHelper.dureeEstimee(site),
                SiteMediaHelper.accesVisite(site),
                surface,
                border,
                textCol,
                mutedCol,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),

        // ── SECTION DESCRIPTION ──
        Text(
          'À propos de ce site',
          style: AppTheme.headingStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppTheme.radius16),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            site.description,
            style: AppTheme.bodyStyle(
              fontSize: 14,
              color: textCol,
              height: 1.6,
            ),
          ),
        ),

        // ── HISTOIRE & PATRIMOINE ──
        if (site.historique.trim().isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'Histoire & Racines culturelles',
            style: AppTheme.headingStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppTheme.radius16),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              site.historique,
              style: AppTheme.bodyStyle(
                fontSize: 14,
                color: textCol,
                height: 1.6,
              ),
            ),
          ),
        ],

        // ── LOCALISATION GPS SUR MOBILE ──
        if (!AppTheme.isDesktop(context)) ...[
          const SizedBox(height: 22),
          _buildGpsCard(surface, border, textCol, mutedCol),
        ],

        const SizedBox(height: 30),
        // ── SECTION AVIS DES VISITEURS ──
        ReviewsSection(
          patrimoineId: site.id,
          initialAverage: site.noteMoyenne,
          onReviewsChanged: _loadReviewStats,
        ),
      ],
    );
  }

  Widget _buildDesktopBookingCard(
    double distZiguinchor,
    Color surface,
    Color border,
    Color textCol,
    Color mutedCol,
  ) {
    final site = widget.site;
    final isFree = site.tarifEntree <= 0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppTheme.radius16),
            border: Border.all(color: border),
            boxShadow: AppTheme.shadowFor(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    isFree ? 'Entrée libre' : '${site.tarifEntree.toInt()} FCFA',
                    style: AppTheme.headingStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  Text(
                    'par visiteur',
                    style: AppTheme.bodyStyle(
                      fontSize: 13,
                      color: mutedCol,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: border, height: 1),
              const SizedBox(height: 16),
              _summaryLine('Horaires', site.horairesOuverture, textCol, mutedCol),
              _summaryLine('Durée estimée', SiteMediaHelper.dureeEstimee(site), textCol, mutedCol),
              _summaryLine('Distance centre', '${distZiguinchor.toStringAsFixed(1)} km', textCol, mutedCol),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _goToBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: Text(
                    'Réserver une visite',
                    style: AppTheme.bodyStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildGpsCard(surface, border, textCol, mutedCol),
      ],
    );
  }

  Widget _summaryLine(String k, String v, Color textCol, Color mutedCol) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: AppTheme.bodyStyle(fontSize: 13, color: mutedCol),
          ),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: AppTheme.bodyStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textCol,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsCard(Color surface, Color border, Color textCol, Color mutedCol) {
    final site = widget.site;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.paleGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: AppTheme.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Localisation GPS',
                      style: AppTheme.headingStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textCol,
                      ),
                    ),
                    Text(
                      '${site.latitude.toStringAsFixed(4)}, ${site.longitude.toStringAsFixed(4)}',
                      style: AppTheme.bodyStyle(
                        fontSize: 12,
                        color: mutedCol,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapExploreScreen(initialSite: site),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.forestGreen,
                side: const BorderSide(color: AppTheme.forestGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
              ),
              icon: const Icon(Icons.near_me_rounded, size: 17),
              label: Text(
                'Voir l\'itinéraire sur la carte',
                style: AppTheme.bodyStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(
    IconData icon,
    String title,
    String subtitle,
    Color surface,
    Color border,
    Color textCol,
    Color mutedCol,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.forestGreen, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyStyle(
              fontSize: 11,
              color: mutedCol,
            ),
          ),
        ],
      ),
    );
  }
}
