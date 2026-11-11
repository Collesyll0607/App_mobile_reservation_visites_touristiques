import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
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
  final PageController _heroController = PageController();

  List<Patrimoine> _allSites = ApiConfig.sitesCasamance;
  Set<int> _favoriteIds = {};
  final Map<int, double> _liveRatings = {};
  final Map<int, int> _reviewCounts = {};

  String? _userFirstName;
  bool _isLoading = true;
  String? _apiErrorMessage;
  int _heroIndex = 0;

  final List<Map<String, dynamic>> _categories = const [
    {
      'code': 'NATURE',
      'label': 'Nature',
      'icon': Icons.eco_rounded,
      'color': AppTheme.naturalGreen,
    },
    {
      'code': 'MONUMENT',
      'label': 'Monuments',
      'icon': Icons.account_balance_rounded,
      'color': AppTheme.forestGreen,
    },
    {
      'code': 'MUSEE',
      'label': 'Musées',
      'icon': Icons.museum_rounded,
      'color': AppTheme.warmOrangeDark,
    },
    {
      'code': 'ARCHITECTURE',
      'label': 'Architecture',
      'icon': Icons.holiday_village_rounded,
      'color': AppTheme.forestGreen,
    },
    {
      'code': 'CULTURE',
      'label': 'Culture',
      'icon': Icons.theater_comedy_rounded,
      'color': AppTheme.naturalGreen,
    },
    {
      'code': 'ARTISANAT',
      'label': 'Artisanat',
      'icon': Icons.handyman_rounded,
      'color': AppTheme.warmOrangeDark,
    },
  ];

  final List<Map<String, String>> _ziguinchorSlides = const [
    {
      'asset': 'assets/images/casamance/port_ziguinchor.jpg',
      'badge': 'Ziguinchor • Destination Phare',
      'title': 'Vivez la magie de Ziguinchor & du fleuve Casamance',
      'subtitle':
          'Des quais animés de Boudody aux bolongs sauvages, explorez chaque trésor.',
    },
    {
      'asset': SiteMediaHelper.heroBannerAsset,
      'badge': 'Patrimoine & Îles',
      'title': 'Île de Carabane & mémoire vivante',
      'subtitle':
          'Embarquez en pirogue vers l’un des joyaux historiques du sud.',
    },
    {
      'asset': 'assets/images/casamance/cases_mlomp.jpg',
      'badge': 'Savoir-faire Diola',
      'title': 'Cases traditionnelles & villages d’art',
      'subtitle':
          'Rencontrez les guides et gardiens du patrimoine casamançais.',
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
    _heroController.dispose();
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
    final popularSites = _allSites.take(5).toList();

    final mustVisitSites = _allSites.where((s) {
      final n = s.nom.toLowerCase();
      return n.contains('carabane') ||
          n.contains('joola') ||
          n.contains('mlomp') ||
          n.contains('bolong') ||
          n.contains('alliance');
    }).toList();
    final incontournables =
        mustVisitSites.isNotEmpty ? mustVisitSites : _allSites.take(3).toList();

    final topRated = [..._allSites]
      ..sort((a, b) => _ratingFor(b).compareTo(_ratingFor(a)));

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: RefreshIndicator(
        color: AppTheme.forestGreen,
        onRefresh: _refreshAll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Zone supérieure : Logo, salutation, billets et accès profil
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const CasamanceEmblemMark(size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userFirstName != null &&
                                      _userFirstName!.isNotEmpty
                                  ? 'Bonjour $_userFirstName'
                                  : 'Bienvenue en Casamance',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13.5,
                                  color: AppTheme.warmOrange,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    'Ziguinchor, Sénégal',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Accès rapide Mes Réservations / Billets QR
                      Material(
                        color: AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyBookingsScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.confirmation_number_outlined,
                              color: AppTheme.forestGreen,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Accès rapide Profil / Compte
                      Material(
                        color: AppTheme.forestGreen,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => MainNavigationShell.switchTab(context, 4),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              _userFirstName != null
                                  ? Icons.person_rounded
                                  : Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Grande bannière photographique mettant en valeur Ziguinchor
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 205,
                      child: PageView.builder(
                        controller: _heroController,
                        itemCount: _ziguinchorSlides.length,
                        onPageChanged: (idx) =>
                            setState(() => _heroIndex = idx),
                        itemBuilder: (context, index) {
                          final slide = _ziguinchorSlides[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CasamanceAssetPhoto(
                                  assetPath: slide['asset']!,
                                  fit: BoxFit.cover,
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.14),
                                        AppTheme.forestGreen
                                            .withValues(alpha: 0.88),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.warmOrange,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          slide['badge']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        slide['title']!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.22,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        slide['subtitle']!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white
                                              .withValues(alpha: 0.90),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_ziguinchorSlides.length, (i) {
                        final active = i == _heroIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.forestGreen
                                : AppTheme.naturalGreen.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Barre de recherche moderne
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => _openExplorer(query: value),
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un site, une île, un musée...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.forestGreen,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Material(
                          color: AppTheme.warmOrange,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _openExplorer(
                              query: _searchController.text,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // Bannière d'erreur explicite si le backend est indisponible
            if (_apiErrorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: CasamanceApiErrorBanner(
                    message: _apiErrorMessage!,
                    onRetry: _loadSites,
                  ),
                ),
              ),

            // 4. Section « Explorer par catégorie »
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: CasamanceSectionHeader(
                  title: 'Explorer par catégorie',
                  subtitle: 'Patrimoine classé de Ziguinchor & Casamance',
                  onSeeAll: () => _openExplorer(category: 'TOUS'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 92,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return SizedBox(
                      width: 88,
                      child: Material(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => _openExplorer(
                            category: cat['code'] as String,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    cat['icon'] as IconData,
                                    color: cat['color'] as Color,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat['label'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 5. Section « Sites populaires »
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                child: CasamanceSectionHeader(
                  title: 'Sites populaires',
                  subtitle: 'Les visites les plus appréciées du moment',
                  onSeeAll: () => _openExplorer(category: 'TOUS'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _isLoading && _allSites.isEmpty
                  ? const SizedBox(
                      height: 240,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 278,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: popularSites.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final site = popularSites[index];
                          return CasamanceFeaturedSiteCard(
                            site: site,
                            isFavorite: _favoriteIds.contains(site.id),
                            onTap: () => _openDetail(site),
                            onToggleFavorite: () => _toggleFavorite(site),
                          );
                        },
                      ),
                    ),
            ),

            // 6. Section « Les incontournables de la Casamance »
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: CasamanceSectionHeader(
                  title: 'Les incontournables de la Casamance',
                  subtitle: 'Des étapes emblématiques à ne pas manquer',
                  onSeeAll: () => _openExplorer(category: 'TOUS'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: incontournables.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final site = incontournables[index];
                  final rating = _ratingFor(site);
                  final count = _reviewCounts[site.id] ?? 0;
                  final isFav = _favoriteIds.contains(site.id);

                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () => _openDetail(site),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              SitePhotoView(
                                site: site,
                                width: 96,
                                height: 96,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.lightGreen,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            SiteMediaHelper.labelCategorie(
                                                site.categorie),
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.forestGreen,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 15,
                                          color: AppTheme.warmOrange,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        if (count > 0)
                                          Text(
                                            ' ($count)',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      site.nom,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule_rounded,
                                          size: 13,
                                          color: AppTheme.naturalGreen,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            SiteMediaHelper.dureeEstimee(site),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11.5,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () =>
                                              _toggleFavorite(site),
                                          icon: Icon(
                                            isFav
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            size: 20,
                                            color: isFav
                                                ? AppTheme.errorRed
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 7. Section « Les mieux notés »
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: CasamanceSectionHeader(
                  title: 'Les mieux notés',
                  subtitle: 'Classés selon les avis des voyageurs',
                  onSeeAll: () => _openExplorer(category: 'TOUS'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 278,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: topRated.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final site = topRated[index];
                    return CasamanceFeaturedSiteCard(
                      site: site.noteMoyenne == _ratingFor(site)
                          ? site
                          : Patrimoine(
                              id: site.id,
                              nom: site.nom,
                              description: site.description,
                              historique: site.historique,
                              categorie: site.categorie,
                              localisation: site.localisation,
                              latitude: site.latitude,
                              longitude: site.longitude,
                              tarifEntree: site.tarifEntree,
                              horairesOuverture: site.horairesOuverture,
                              imageUrl: site.imageUrl,
                              noteMoyenne: _ratingFor(site),
                            ),
                      isFavorite: _favoriteIds.contains(site.id),
                      onTap: () => _openDetail(site),
                      onToggleFavorite: () => _toggleFavorite(site),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}
