import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_colle/catalogue/site_detail_screen.dart';
import '../../main.dart';
import '../reservation/booking_form_screen.dart';
import '../services/favorites_service.dart';

/// Album Carnet de Voyage — Sites Favoris (100% hors-ligne)
/// Responsable : Ndeye Thiamba FAYE (Pôle 2) — DA Casamance Tourisme
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  List<Patrimoine> _favoris = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    setState(() => _isLoading = true);
    final sites = await _favoritesService.loadAll();
    if (!mounted) return;
    setState(() {
      _favoris = sites;
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(Patrimoine site) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.ivorySand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Retirer des favoris ?',
          style: AppTheme.editorialTitle(
            fontSize: 19,
            color: AppTheme.deepForest,
          ),
        ),
        content: Text(
          'Voulez-vous retirer "${site.nom}" de votre carnet de coups de cœur ?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.hibiscusRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmation == true && mounted) {
      await _favoritesService.removeFavorite(site.id);
      await _chargerFavoris();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${site.nom} a été retiré des favoris.'),
          action: SnackBarAction(
            label: 'Annuler',
            textColor: AppTheme.champagneGold,
            onPressed: () async {
              await _favoritesService.addFavorite(site);
              await _chargerFavoris();
            },
          ),
        ),
      );
    }
  }

  Widget _carteFavoriEditorial(Patrimoine site, int index) {
    final isPanoramic = index % 3 == 0;
    final warmTint = index.isOdd;
    final isFree = site.tarifEntree <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: warmTint ? AppTheme.terracottaSoft : AppTheme.warmCream,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isPanoramic ? 26 : 36),
          topRight: const Radius.circular(22),
          bottomLeft: const Radius.circular(22),
          bottomRight: Radius.circular(isPanoramic ? 34 : 22),
        ),
        border: Border.all(color: AppTheme.sandBorder),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SitePhotoView(
                site: site,
                width: double.infinity,
                height: isPanoramic ? 175 : 148,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isPanoramic ? 25 : 35),
                  topRight: const Radius.circular(21),
                  bottomRight: const Radius.circular(28),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.deepForest.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    SiteMediaHelper.labelCategorie(site.categorie),
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.champagneGold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CasamanceFavoriteButton(
                  isFavorite: true,
                  onTap: () => _retirerFavori(site),
                  size: 36,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        site.nom,
                        style: AppTheme.editorialTitle(
                          fontSize: 19,
                          color: AppTheme.deepForest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.champagneGold.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppTheme.champagneGold,
                          ),
                          const SizedBox(width: 3),
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
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppTheme.bolongTurquoise,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        site.localisation,
                        style: GoogleFonts.poppins(
                          fontSize: 12.2,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isFree
                      ? 'Accès libre • ${site.horairesOuverture}'
                      : '${site.tarifEntree.toInt()} FCFA / pers. • ${site.horairesOuverture}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.earthBrown,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SiteDetailScreen(site: site),
                            ),
                          );
                          _chargerFavoris();
                        },
                        icon: const Icon(Icons.info_outline, size: 17),
                        label: const Text('Détails'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.champagneGold,
                          foregroundColor: AppTheme.deepForest,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingFormScreen(site: site),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month_rounded, size: 17),
                        label: const Text('Réserver'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vueVide() {
    return CasamanceEmptyState(
      icon: Icons.favorite_border_rounded,
      title: 'Votre carnet est encore vierge',
      subtitle:
          'Ajoutez des sites touristiques à vos favoris depuis l\'accueil, « Explorez la Casamance » ou la fiche détaillée pour les retrouver hors-ligne.',
      actionLabel: 'Explorer la Casamance',
      onAction: () => MainNavigationShell.switchTab(context, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          // En-tête éditorial léger sur Ivoire sable
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
              child: Row(
                children: [
                  const CasamanceHibiscusBlossom(size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes Coups de Cœur',
                          style: AppTheme.editorialTitle(
                            fontSize: 24,
                            color: AppTheme.deepForest,
                          ),
                        ),
                        Text(
                          'Sélection enregistrée hors-ligne (${_favoris.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.earthBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualiser',
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.deepForest,
                    ),
                    onPressed: _chargerFavoris,
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: CasamanceWovenMotifStrip(
              height: 6,
              color: AppTheme.earthBrown,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.deepForest,
                    ),
                  )
                : _favoris.isEmpty
                    ? _vueVide()
                    : RefreshIndicator(
                        color: AppTheme.deepForest,
                        onRefresh: _chargerFavoris,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                          itemCount: _favoris.length,
                          itemBuilder: (context, index) =>
                              _carteFavoriEditorial(_favoris[index], index),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
