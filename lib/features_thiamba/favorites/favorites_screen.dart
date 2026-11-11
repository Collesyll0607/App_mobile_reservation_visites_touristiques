import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_colle/catalogue/site_detail_screen.dart';
import '../../main.dart';
import '../reservation/booking_form_screen.dart';
import '../services/favorites_service.dart';

/// Écran des Sites Favoris (Fonctionnement 100% hors-ligne)
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
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Retirer des favoris ?',
          style: AppTheme.editorialTitle(
              fontSize: 19, color: AppTheme.deepForest),
        ),
        content: Text(
          'Voulez-vous retirer "${site.nom}" de vos sites favoris ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lateriteRed,
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
            textColor: AppTheme.solarGold,
            onPressed: () async {
              await _favoritesService.addFavorite(site);
              await _chargerFavoris();
            },
          ),
        ),
      );
    }
  }

  Widget _carteFavori(Patrimoine site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
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
                height: 145,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Retirer des favoris',
                    icon: const Icon(Icons.favorite_rounded,
                        color: AppTheme.lateriteRed),
                    onPressed: () => _retirerFavori(site),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                          fontSize: 18,
                          color: AppTheme.deepForest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warmOrange.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppTheme.warmOrange,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            site.noteMoyenne.toStringAsFixed(1),
                            style: AppTheme.bodyStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
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
                    const Icon(Icons.location_on,
                        size: 15, color: AppTheme.bolongTurquoise),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        site.localisation,
                        style: AppTheme.bodyStyle(
                            fontSize: 12.5, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  site.tarifEntree <= 0
                      ? 'Entrée gratuite • ${site.horairesOuverture}'
                      : '${site.tarifEntree.toInt()} FCFA / personne • ${site.horairesOuverture}',
                  style: AppTheme.bodyStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepForest,
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
                          backgroundColor: AppTheme.warmOrange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingFormScreen(site: site),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month, size: 17),
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
      title: 'Aucun favori pour le moment',
      subtitle:
          'Ajoutez des sites touristiques à vos favoris depuis l\'accueil, Explorer ou la fiche détaillée pour les retrouver hors-ligne.',
      actionLabel: 'Explorer les sites',
      onAction: () => MainNavigationShell.switchTab(context, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          CasamanceCurvedHeader(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 26),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Sites Favoris',
                        style: AppTheme.editorialTitle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Sauvegardés localement (mode hors-ligne)',
                        style: AppTheme.bodyStyle(
                          fontSize: 12,
                          color: AppTheme.ivorySand.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Actualiser',
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _chargerFavoris,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _favoris.isEmpty
                    ? _vueVide()
                    : RefreshIndicator(
                        color: AppTheme.deepForest,
                        onRefresh: _chargerFavoris,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                          itemCount: _favoris.length,
                          itemBuilder: (context, index) =>
                              _carteFavori(_favoris[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
