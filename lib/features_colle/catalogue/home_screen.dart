import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/my_bookings/my_bookings_screen.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../../main.dart';
import '../auth/auth_service.dart';
import '../reviews/reviews_service.dart';
import 'patrimoine_service.dart';
import 'site_detail_screen.dart';

/// Écran d'Accueil Principal — Casamance Tourisme & Visites
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue & API)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final TextEditingController _searchController = TextEditingController();

  List<Patrimoine> _allSites = ApiConfig.sitesCasamance;
  Set<int> _favoriteIds = {};
  final Map<int, double> _liveRatings = {};
  final Map<int, int> _reviewCounts = {};

  String? _userFirstName;
  bool _isLoading = true;
  String? _apiErrorMessage;

  static const List<Map<String, dynamic>> _categories = [
    {'code': 'NATURE', 'label': 'Nature', 'icon': Icons.eco_outlined},
    {
      'code': 'MONUMENT',
      'label': 'Monument',
      'icon': Icons.account_balance_outlined
    },
    {'code': 'MUSEE', 'label': 'Musée', 'icon': Icons.museum_outlined},
    {
      'code': 'ARCHITECTURE',
      'label': 'Architecture',
      'icon': Icons.holiday_village_outlined
    },
    {'code': 'ARTISANAT', 'label': 'Artisanat', 'icon': Icons.handyman_outlined},
    {
      'code': 'CULTURE',
      'label': 'Culture',
      'icon': Icons.theater_comedy_outlined
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadUserGreeting(),
      _loadSites(),
      _loadFavorites(),
    ]);
  }

  Future<void> _loadUserGreeting() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _userFirstName = user?.nomComplet.trim().split(' ').first;
    });
  }

  Future<void> _loadSites() async {
    setState(() {
      _isLoading = true;
      _apiErrorMessage = null;
    });

    final result = await PatrimoineService.fetchPatrimoines();
    if (!mounted) return;

    setState(() {
      _allSites = result.sites;
      _apiErrorMessage = result.fromApiRest ? null : result.errorMessage;
      _isLoading = false;
    });
    _loadReviewMetrics(result.sites);
  }

  Future<void> _loadReviewMetrics(List<Patrimoine> sites) async {
    for (final site in sites) {
      final reviews = await ReviewsService.getReviewsForSite(site.id);
      if (!mounted) return;
      double rating = site.noteMoyenne;
      if (reviews.isNotEmpty) {
        final sum = reviews.fold<int>(0, (acc, r) => acc + r.note);
        rating = sum / reviews.length;
      }
      setState(() {
        _liveRatings[site.id] = rating;
        _reviewCounts[site.id] = reviews.length;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final favs = await _favoritesService.loadAll();
    if (!mounted) return;
    setState(() {
      _favoriteIds = favs.map((s) => s.id).toSet();
    });
  }

  Future<void> _toggleFavorite(Patrimoine site) async {
    final isNow = await _favoritesService.toggleFavorite(site);
    if (!mounted) return;
    setState(() {
      if (isNow) {
        _favoriteIds.add(site.id);
      } else {
        _favoriteIds.remove(site.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNow
              ? '${site.nom} ajouté aux favoris'
              : '${site.nom} retiré des favoris',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double _ratingFor(Patrimoine site) =>
      _liveRatings[site.id] ?? site.noteMoyenne;

  Future<void> _openDetail(Patrimoine site) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SiteDetailScreen(site: site)),
    );
    _loadFavorites();
    _loadReviewMetrics(_allSites);
  }

  void _openExplorer({String? category, String? query}) {
    MainNavigationShell.switchTab(
      context,
      1,
      explorerCategory: category ?? 'TOUS',
      explorerQuery: query ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 768;
    final horizontalPad = isWide ? 24.0 : 16.0;

    final popularSites = _allSites.take(3).toList();
    final topRated = [..._allSites]
      ..sort((a, b) => _ratingFor(b).compareTo(_ratingFor(a)));
    final topThree = topRated.take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: RefreshIndicator(
        color: AppTheme.forestGreen,
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: CasamanceResponsiveContainer(
            padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. En-tête mobile (sur desktop, la TopNavBar joue ce rôle + salutation discrète)
                if (!isWide) ...[
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          const CasamanceEmblemMark(size: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userFirstName != null &&
                                          _userFirstName!.isNotEmpty
                                      ? 'Bonjour $_userFirstName'
                                      : 'Casamance Tourisme',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 13,
                                      color: AppTheme.naturalGreen,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        'Ziguinchor, Sénégal',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Mes réservations',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyBookingsScreen(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.confirmation_number_outlined,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Mon compte',
                            onPressed: () =>
                                MainNavigationShell.switchTab(context, 4),
                            icon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userFirstName != null &&
                                      _userFirstName!.isNotEmpty
                                  ? 'Bonjour $_userFirstName, prêt pour la Casamance ?'
                                  : 'Découvrez la Casamance authentique',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Patrimoine culturel, îles, bolongs et artisanat autour de Ziguinchor',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyBookingsScreen(),
                          ),
                        ),
                        icon: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 18,
                        ),
                        label: const Text('Mes billets'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // 2. Bannière Ziguinchor propre & proportionnée (aucun texte chevauchant)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: isWide ? 260 : 228,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const CasamanceAssetPhoto(
                          assetPath: 'assets/images/casamance/carabane_bolong.jpg',
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0.68),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(isWide ? 24 : 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.pureWhite
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Ziguinchor • Destination Phare',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Entre fleuve, mangroves et patrimoine vivant',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: isWide ? 22 : 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => _openExplorer(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.forestGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('Explorer tous les sites →'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Barre de recherche moderne blanche
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => _openExplorer(query: value),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un site, un quartier, un musée...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.textMuted,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: ElevatedButton(
                          onPressed: () => _openExplorer(
                            query: _searchController.text,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forestGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Rechercher'),
                        ),
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),

                if (_apiErrorMessage != null) ...[
                  const SizedBox(height: 14),
                  CasamanceApiErrorBanner(
                    message: _apiErrorMessage!,
                    onRetry: _loadSites,
                  ),
                ],

                // 4. Catégories nettes et contrastées
                const SizedBox(height: 22),
                CasamanceSectionHeader(
                  title: 'Explorer par catégorie',
                  subtitle: 'Filtrez directement par thématique',
                  onSeeAll: () => _openExplorer(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return InkWell(
                        onTap: () =>
                            _openExplorer(category: cat['code'] as String),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 16,
                                color: AppTheme.forestGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 5. Sites populaires (Grille 3 colonnes desktop / carrousel mobile)
                const SizedBox(height: 26),
                CasamanceSectionHeader(
                  title: 'Sites populaires',
                  subtitle: 'Les découvertes les plus demandées',
                  onSeeAll: () => _openExplorer(),
                ),
                const SizedBox(height: 14),
                if (_isLoading && _allSites.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  )
                else
                  _buildAdaptiveSiteGrid(
                    popularSites,
                    heroPrefix: 'home_pop',
                  ),

                // 6. Les mieux notés
                const SizedBox(height: 28),
                CasamanceSectionHeader(
                  title: 'Les mieux notés',
                  subtitle: 'Plébiscités par les visiteurs',
                  onSeeAll: () => _openExplorer(),
                ),
                const SizedBox(height: 14),
                _buildAdaptiveSiteGrid(
                  topThree,
                  heroPrefix: 'home_top',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveSiteGrid(
    List<Patrimoine> sites, {
    required String heroPrefix,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w < 640) {
          return Column(
            children: sites
                .map(
                  (site) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CasamanceSiteCard(
                      site: site,
                      heroTagPrefix: heroPrefix,
                      isFavorite: _favoriteIds.contains(site.id),
                      rating: _ratingFor(site),
                      reviewCount: _reviewCounts[site.id] ?? 0,
                      onTap: () => _openDetail(site),
                      onToggleFavorite: () => _toggleFavorite(site),
                    ),
                  ),
                )
                .toList(),
          );
        }

        final cols = w >= 980 ? 3 : 2;
        final visible = sites.take(cols == 3 ? 3 : 2).toList();
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(visible.length, (i) {
              final site = visible[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i > 0 ? 9 : 0,
                    right: i < visible.length - 1 ? 9 : 0,
                  ),
                  child: CasamanceSiteCard(
                    site: site,
                    heroTagPrefix: heroPrefix,
                    isFavorite: _favoriteIds.contains(site.id),
                    rating: _ratingFor(site),
                    reviewCount: _reviewCounts[site.id] ?? 0,
                    onTap: () => _openDetail(site),
                    onToggleFavorite: () => _toggleFavorite(site),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
