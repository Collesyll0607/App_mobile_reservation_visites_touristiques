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

/// Fiche Détaillée d'un Site Touristique (Responsive 2 colonnes sur ordinateur / 1 sur mobile)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.share_rounded, color: AppTheme.forestGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Informations copiées',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
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

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.borderLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          site.nom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Partager ce site',
            onPressed: _shareSite,
            icon: const Icon(Icons.share_outlined, color: AppTheme.textDark),
          ),
          IconButton(
            tooltip:
                _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? AppTheme.errorRed : AppTheme.textDark,
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
            18,
            isWide ? 24 : 16,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Galerie photo nette rationnée (jamais étirée ni énorme)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: isWide ? 360 : 240,
                  width: double.infinity,
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
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_galleryIndex + 1} / ${gallery.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Miniatures de la galerie
              SizedBox(
                height: 64,
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
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Container(
                        width: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppTheme.forestGreen
                                : AppTheme.borderLight,
                            width: selected ? 2.2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 22),

              // Corps principal : 2 colonnes sur ordinateur, 1 colonne sur mobile
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildMainInfoColumn(distZiguinchor),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: _buildDesktopBookingCard(distZiguinchor),
                    ),
                  ],
                )
              else
                _buildMainInfoColumn(distZiguinchor),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: AppTheme.pureWhite,
                  border: Border(top: BorderSide(color: AppTheme.borderLight)),
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
                            color: AppTheme.textMuted,
                          ),
                        ),
                        Text(
                          site.tarifEntree <= 0
                              ? 'Gratuit'
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
                        onPressed: _goToBooking,
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: const Text('Réserver une visite'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMainInfoColumn(double distZiguinchor) {
    final site = widget.site;
    final isFree = site.tarifEntree <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Catégorie & Note réelle
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.paleGreen,
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
            const Icon(
              Icons.star_rounded,
              color: AppTheme.accentOrange,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              '${_liveAverage.toStringAsFixed(1)}/5',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              ' • $_reviewsCount avis',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          site.nom,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppTheme.naturalGreen,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '${site.localisation} • à ${distZiguinchor.toStringAsFixed(1)} km du centre',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Infos pratiques en grille propre
        Row(
          children: [
            Expanded(
              child: _infoBox(
                Icons.payments_outlined,
                isFree ? 'Gratuit' : '${site.tarifEntree.toInt()} FCFA',
                'Tarif visite',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoBox(
                Icons.schedule_rounded,
                site.horairesOuverture,
                'Horaires',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoBox(
                Icons.directions_walk_rounded,
                SiteMediaHelper.dureeEstimee(site),
                SiteMediaHelper.accesVisite(site),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Text(
            site.description,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: AppTheme.textDark,
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
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Text(
              site.historique,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: AppTheme.textDark,
                height: 1.55,
              ),
            ),
          ),
        ],

        if (!AppTheme.isDesktop(context)) ...[
          const SizedBox(height: 18),
          _buildGpsCard(),
        ],

        const SizedBox(height: 24),
        ReviewsSection(
          patrimoineId: site.id,
          initialAverage: site.noteMoyenne,
          onReviewsChanged: _loadReviewStats,
        ),
      ],
    );
  }

  Widget _buildDesktopBookingCard(double distZiguinchor) {
    final site = widget.site;
    final isFree = site.tarifEntree <= 0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFree
                        ? 'Entrée libre'
                        : '${site.tarifEntree.toInt()} FCFA',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  Text(
                    'par visiteur',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.borderLight),
              const SizedBox(height: 12),
              _summaryLine('Horaires', site.horairesOuverture),
              _summaryLine('Durée estimée', SiteMediaHelper.dureeEstimee(site)),
              _summaryLine('Distance', '${distZiguinchor.toStringAsFixed(1)} km'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _goToBooking,
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('Réserver une visite'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildGpsCard(),
      ],
    );
  }

  Widget _summaryLine(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppTheme.textMuted),
          ),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsCard() {
    final site = widget.site;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppTheme.forestGreen),
              const SizedBox(width: 8),
              Text(
                'Localisation GPS',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${site.latitude.toStringAsFixed(4)}, ${site.longitude.toStringAsFixed(4)}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapExploreScreen(initialSite: site),
                  ),
                );
              },
              icon: const Icon(Icons.near_me_rounded, size: 17),
              label: const Text('Voir l\'itinéraire sur la carte'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.forestGreen, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
