import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/reservation/booking_form_screen.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../map/location_service.dart';
import '../map/map_explore_screen.dart';
import '../reviews/reviews_section.dart';

/// Écran Détail Immersif d'un Site Touristique
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue)
class SiteDetailScreen extends StatefulWidget {
  final Patrimoine site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await _favoritesService.isFavorite(widget.site.id);
    if (!mounted) return;
    setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final isNowFavorite = await _favoritesService.toggleFavorite(widget.site);
    if (!mounted) return;
    setState(() => _isFavorite = isNowFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite
              ? '${widget.site.nom} ajouté aux favoris (accessible hors-ligne) !'
              : '${widget.site.nom} retiré des favoris.',
        ),
        duration: const Duration(seconds: 2),
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
    final distZiguinchor = LocationService.calculerDistanceKm(
      lat1: 12.5833,
      lon1: -16.2719,
      lat2: site.latitude,
      lon2: site.longitude,
    );
    final gallery = SiteMediaHelper.galleryAssetsForSite(site);

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: CustomScrollView(
        slivers: [
          // 1. Grande photo de couverture immersive
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.deepForest,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: IconButton(
                    tooltip: 'Localiser sur la carte',
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapExploreScreen(initialSite: site),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.92),
                  child: IconButton(
                    tooltip: _isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite
                          ? AppTheme.lateriteRed
                          : AppTheme.deepForest,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SitePhotoView(site: site),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.28),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -2,
                    child: Container(
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppTheme.ivorySand,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Corps éditorial
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie & Note
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.deepForest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          SiteMediaHelper.labelCategorie(site.categorie),
                          style: AppTheme.bodyStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ivorySand,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded,
                          color: AppTheme.solarGold, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        '${site.noteMoyenne} / 5',
                        style: AppTheme.bodyStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nom du site
                  Text(
                    site.nom,
                    style: AppTheme.editorialTitle(
                      fontSize: 27,
                      color: AppTheme.deepForest,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Localisation + distance Ziguinchor
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppTheme.bolongTurquoise, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${site.localisation} • À $distZiguinchor km du centre',
                          style: AppTheme.bodyStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3 Tuiles d'informations pratiques
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          icon: Icons.schedule_rounded,
                          title: SiteMediaHelper.dureeEstimee(site),
                          subtitle: site.horairesOuverture,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.directions_boat_outlined,
                          title: SiteMediaHelper.accesVisite(site),
                          subtitle: 'Visite guidée dispo',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.verified_outlined,
                          title: 'Disponible',
                          subtitle: 'Tous les jours',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Description
                  Text(
                    'À propos de la destination',
                    style: AppTheme.editorialTitle(
                      fontSize: 20,
                      color: AppTheme.deepForest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    site.description,
                    style: AppTheme.bodyStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Histoire & Valeur Patrimoniale
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.solarGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories_outlined,
                                color: AppTheme.solarGold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Histoire & Patrimoine',
                              style: AppTheme.editorialTitle(
                                fontSize: 17,
                                color: AppTheme.deepForest,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          site.historique,
                          style: AppTheme.bodyStyle(
                            fontSize: 13.5,
                            height: 1.55,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Galerie de photos
                  Text(
                    'Galerie photos',
                    style: AppTheme.editorialTitle(
                      fontSize: 20,
                      color: AppTheme.deepForest,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 105,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final path = gallery[idx];
                        return GestureDetector(
                          onTap: () => _openFullScreenPhoto(path),
                          child: Container(
                            width: 155,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: CasamanceAssetPhoto(
                              assetPath: path,
                              width: 155,
                              height: 105,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Raccourci Carte GPS
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.bolongTurquoise.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.bolongTurquoise.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppTheme.bolongTurquoise,
                          child: Icon(Icons.gps_fixed, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Localisation & Itinéraire',
                                style: AppTheme.bodyStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.deepForest,
                                ),
                              ),
                              Text(
                                'Lat ${site.latitude.toStringAsFixed(4)}, Lon ${site.longitude.toStringAsFixed(4)}',
                                style: AppTheme.bodyStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MapExploreScreen(initialSite: site),
                              ),
                            );
                          },
                          child: Text(
                            'Voir carte →',
                            style: AppTheme.bodyStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.bolongTurquoise,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 36),

                  // Avis des visiteurs (Module 4)
                  ReviewsSection(
                    patrimoineId: site.id,
                    initialAverage: site.noteMoyenne,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barre fixe inférieure de réservation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
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
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    '${site.tarifEntree.toInt()} FCFA / pers.',
                    style: AppTheme.bodyStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepForest,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
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
                    backgroundColor: AppTheme.lateriteRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 19),
                  label: const Text('Réserver maintenant →'),
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
        color: AppTheme.sageSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.deepForest, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyStyle(
              fontSize: 11.5,
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
            style: AppTheme.bodyStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
