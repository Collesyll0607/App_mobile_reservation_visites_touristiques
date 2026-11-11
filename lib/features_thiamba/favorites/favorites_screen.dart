import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_colle/catalogue/site_detail_screen.dart';
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
                Text(
                  site.nom,
                  style: AppTheme.editorialTitle(
                    fontSize: 19,
                    color: AppTheme.deepForest,
                  ),
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
                  '${site.tarifEntree.toInt()} FCFA / personne • ${site.horairesOuverture}',
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppTheme.sageSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: AppTheme.lateriteRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun favori pour le moment',
              textAlign: TextAlign.center,
              style: AppTheme.editorialTitle(
                fontSize: 21,
                color: AppTheme.deepForest,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ajoutez des sites touristiques à vos favoris (icône cœur ❤️) depuis l\'accueil, la fiche détaillée ou la réservation pour les retrouver même sans connexion Internet.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
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
