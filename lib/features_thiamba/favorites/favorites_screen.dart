import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_colle/catalogue/site_detail_screen.dart';
import '../../main.dart';
import '../services/favorites_service.dart';

/// Écran Favoris (Hors-ligne) — Design System v2
/// Typographie Fraunces/Plus Jakarta Sans, grilles responsive,
/// animations fluides et dark-aware.
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)
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
    final surface = AppTheme.surfaceOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius16),
        ),
        title: Text(
          'Retirer des favoris ?',
          style: AppTheme.headingStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
        ),
        content: Text(
          'Voulez-vous retirer "${site.nom}" de vos sites favoris ?',
          style: AppTheme.bodyStyle(fontSize: 13.5, color: mutedCol),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Annuler',
              style: AppTheme.bodyStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: mutedCol,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
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
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12),
          ),
          backgroundColor: AppTheme.forestGreen,
          content: Text('${site.nom} retiré des favoris.'),
          action: SnackBarAction(
            label: 'Annuler',
            textColor: AppTheme.ocreGold,
            onPressed: () async {
              await _favoritesService.addFavorite(site);
              await _chargerFavoris();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 640;
    final surface = AppTheme.surfaceOf(context);
    final background = AppTheme.backgroundOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          // ── EN-TÊTE ÉPURÉ ──
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: CasamanceResponsiveContainer(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  16,
                  isWide ? 24 : 16,
                  16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes Favoris',
                            style: AppTheme.headingStyle(
                              fontSize: isWide ? 26 : 22,
                              fontWeight: FontWeight.w700,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_favoris.length} site${_favoris.length > 1 ? 's' : ''} enregistré${_favoris.length > 1 ? 's' : ''} hors-ligne',
                            style: AppTheme.bodyStyle(
                              fontSize: 13,
                              color: mutedCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualiser',
                      onPressed: _chargerFavoris,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── GRILLE OU ÉTAT VIDE ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.forestGreen,
                    ),
                  )
                : _favoris.isEmpty
                    ? CasamanceEmptyState(
                        icon: Icons.favorite_border_rounded,
                        title: 'Aucun favori pour le moment',
                        subtitle:
                            'Ajoutez des sites depuis l\'accueil ou Explorer pour les retrouver même hors connexion.',
                        actionLabel: 'Explorer la Casamance',
                        onAction: () =>
                            MainNavigationShell.switchTab(context, 1),
                      )
                    : RefreshIndicator(
                        color: AppTheme.forestGreen,
                        backgroundColor: surface,
                        onRefresh: _chargerFavoris,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final cols = w >= 1024 ? 3 : (w >= 640 ? 2 : 1);
                            final rowCount = (_favoris.length / cols).ceil();
                            final hPad = w >= 640 ? 24.0 : 16.0;

                            return ListView.separated(
                              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
                              itemCount: rowCount,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 18),
                              itemBuilder: (context, rowIndex) {
                                return Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: AppTheme.maxContentWidth,
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: List.generate(cols, (col) {
                                          final idx = rowIndex * cols + col;
                                          if (idx >= _favoris.length) {
                                            return const Expanded(
                                              child: SizedBox.shrink(),
                                            );
                                          }
                                          final site = _favoris[idx];
                                          return Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 18.0 * col / cols,
                                                right: 18.0 * (cols - 1 - col) / cols,
                                              ),
                                              child: CasamanceSiteCard(
                                                site: site,
                                                heroTagPrefix: 'fav_card',
                                                isFavorite: true,
                                                rating: site.noteMoyenne,
                                                reviewCount: 0,
                                                onToggleFavorite: () =>
                                                    _retirerFavori(site),
                                                onTap: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          SiteDetailScreen(
                                                        site: site,
                                                      ),
                                                    ),
                                                  );
                                                  _chargerFavoris();
                                                },
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
