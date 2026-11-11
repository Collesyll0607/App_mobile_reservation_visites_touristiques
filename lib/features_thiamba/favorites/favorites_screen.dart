import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_colle/catalogue/site_detail_screen.dart';
import '../../main.dart';
import '../services/favorites_service.dart';

/// Écran Favoris (Hors-ligne) — Grille responsive moderne
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
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Retirer des favoris ?',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        content: Text(
          'Voulez-vous retirer "${site.nom}" de vos sites favoris ?',
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
              backgroundColor: AppTheme.errorRed,
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
          content: Text('${site.nom} retiré des favoris.'),
          action: SnackBarAction(
            label: 'Annuler',
            textColor: AppTheme.accentOrange,
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

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.pureWhite,
              border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
            ),
            child: SafeArea(
              bottom: false,
              child: CasamanceResponsiveContainer(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  14,
                  isWide ? 24 : 16,
                  14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes Favoris',
                            style: GoogleFonts.poppins(
                              fontSize: isWide ? 24 : 21,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            '${_favoris.length} site${_favoris.length > 1 ? 's' : ''} enregistré${_favoris.length > 1 ? 's' : ''} hors-ligne',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.textMuted,
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
                        onRefresh: _chargerFavoris,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final cols = w >= 1024 ? 3 : (w >= 640 ? 2 : 1);
                            final rowCount = (_favoris.length / cols).ceil();
                            final hPad = w >= 640 ? 24.0 : 16.0;

                            return ListView.separated(
                              padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 28),
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
                                                left: col > 0 ? 9 : 0,
                                                right: col < cols - 1 ? 9 : 0,
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
