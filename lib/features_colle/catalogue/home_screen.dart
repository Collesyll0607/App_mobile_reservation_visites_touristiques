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

/// Écran d'Accueil Magazine — Casamance Tourisme & Visites
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

  final List<Map<String, dynamic>> _themeArches = const [
    {
      'code': 'NATURE',
      'label': 'Nature',
      'asset': 'assets/images/casamance/bolong_mangrove.jpg',
      'icon': Icons.eco_outlined,
    },
    {
      'code': 'CULTURE',
      'label': 'Culture',
      'asset': SiteMediaHelper.cultureAsset,
      'icon': Icons.theater_comedy_outlined,
    },
    {
      'code': 'PLAGES',
      'label': 'Plages',
      'asset': SiteMediaHelper.beachCapSkirringAsset,
      'icon': Icons.beach_access_outlined,
    },
    {
      'code': 'ARTISANAT',
      'label': 'Artisanat',
      'asset': SiteMediaHelper.artisanatAsset,
      'icon': Icons.handyman_outlined,
    },
    {
      'code': 'PATRIMOINE',
      'label': 'Patrimoine',
      'asset': 'assets/images/casamance/cases_mlomp.jpg',
      'icon': Icons.account_balance_outlined,
    },
    {
      'code': 'GASTRONOMIE',
      'label': 'Gastronomie',
      'asset': SiteMediaHelper.gastronomieAsset,
      'icon': Icons.restaurant_outlined,
    },
  ];

  final List<Map<String, String>> _ziguinchorSlides = const [
    {
      'asset': 'assets/images/casamance/port_ziguinchor.jpg',
      'badge': 'ZIGUINCHOR • PORT DE BOUDODY',
      'title': 'Vivez la magie de Ziguinchor & du fleuve Casamance',
      'subtitle':
          'Des quais colorés aux mangroves émeraude, explorez le sud du Sénégal.',
    },
    {
      'asset': SiteMediaHelper.beachCarabaneAsset,
      'badge': 'ESCALE INSULAIRE • CARABANE',
      'title': 'Cocotiers, comptoirs historiques et plages sauvages',
      'subtitle':
          'Embarquez en pirogue traditionnelle vers les joyaux du fleuve.',
    },
    {
      'asset': SiteMediaHelper.artisanatAsset,
      'badge': 'SANTHIABA • ARTISANAT DIOLA',
      'title': 'Sculptures, vannerie et teintures indigo',
      'subtitle':
          'Rencontrez les maîtres artisans au cœur de Ziguinchor.',
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

  Patrimoine _withRating(Patrimoine site) {
    final r = _ratingFor(site);
    if (r == site.noteMoyenne) return site;
    return Patrimoine(
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
      noteMoyenne: r,
    );
  }

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
    final popularSites = _allSites.take(5).map(_withRating).toList();
    final mustVisitSites = _allSites.where((s) {
      final n = s.nom.toLowerCase();
      return n.contains('carabane') ||
          n.contains('mlomp') ||
          n.contains('artisan') ||
          n.contains('joola');
    }).toList();
    final incontournables = (mustVisitSites.isNotEmpty
            ? mustVisitSites
            : _allSites.take(3).toList())
        .map(_withRating)
        .toList();

    final topRated = ([..._allSites]
          ..sort((a, b) => _ratingFor(b).compareTo(_ratingFor(a))))
        .map(_withRating)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: RefreshIndicator(
        color: AppTheme.deepForest,
        backgroundColor: AppTheme.ivorySand,
        onRefresh: _refreshAll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Zone supérieure légère sur Ivoire sable
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      const CasamanceEmblemMark(size: 44),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userFirstName != null &&
                                      _userFirstName!.isNotEmpty
                                  ? 'Bonjour $_userFirstName,'
                                  : 'Bienvenue en Casamance,',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.editorialTitle(
                                fontSize: 19,
                                color: AppTheme.deepForest,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: AppTheme.hibiscusRed,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    'Ziguinchor, perle du sud sénégalais',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppTheme.earthBrown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppTheme.terracottaSoft,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyBookingsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.sandBorder),
                            ),
                            child: const Icon(
                              Icons.confirmation_number_outlined,
                              color: AppTheme.earthBrown,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppTheme.deepForest,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => MainNavigationShell.switchTab(context, 4),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              _userFirstName != null
                                  ? Icons.person_rounded
                                  : Icons.person_outline_rounded,
                              color: AppTheme.champagneGold,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Bannière photographique Ziguinchor + Barre de recherche chevauchante
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    SizedBox(
                      height: 230,
                      child: PageView.builder(
                        controller: _heroController,
                        itemCount: _ziguinchorSlides.length,
                        onPageChanged: (idx) =>
                            setState(() => _heroIndex = idx),
                        itemBuilder: (context, index) {
                          final slide = _ziguinchorSlides[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: ClipPath(
                              clipper:
                                  const CasamanceBolongWaveClipper(depth: 16),
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
                                          AppTheme.deepForest
                                              .withValues(alpha: 0.88),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      18,
                                      20,
                                      38,
                                    ),
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
                                            color: AppTheme.champagneGold,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            slide['badge']!,
                                            style: GoogleFonts.poppins(
                                              fontSize: 9.8,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.deepForest,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          slide['title']!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.editorialTitle(
                                            fontSize: 21,
                                            color: Colors.white,
                                            height: 1.15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          slide['subtitle']!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.8,
                                            color: AppTheme.ivorySand
                                                .withValues(alpha: 0.92),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Barre de recherche flottante verre dépoli
                    Transform.translate(
                      offset: const Offset(0, -22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.warmCream.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppTheme.sandBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.deepForest.withValues(alpha: 0.13),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) =>
                                _openExplorer(query: value),
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              color: AppTheme.deepForest,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Rechercher une plage, un bolong...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppTheme.earthBrown,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Material(
                                  color: AppTheme.deepForest,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    onTap: () => _openExplorer(
                                      query: _searchController.text,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: AppTheme.champagneGold,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_ziguinchorSlides.length, (i) {
                          final active = i == _heroIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 22 : 7,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.hibiscusRed
                                  : AppTheme.earthBrown.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_apiErrorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: CasamanceApiErrorBanner(
                    message: _apiErrorMessage!,
                    onRetry: _loadSites,
                  ),
                ),
              ),

            // 3. Arches Photographiques « Explorer par catégorie »
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                child: CasamanceSectionHeader(
                  title: 'Explorer par catégorie',
                  subtitle: 'Choisissez votre ambiance casamançaise',
                  onSeeAll: () => _openExplorer(category: 'TOUS'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 112,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _themeArches.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 11),
                  itemBuilder: (context, index) {
                    final t = _themeArches[index];
                    return CasamanceArchCategoryTile(
                      label: t['label'] as String,
                      assetPath: t['asset'] as String,
                      icon: t['icon'] as IconData,
                      selected: index == 0,
                      onTap: () =>
                          _openExplorer(category: t['code'] as String),
                    );
                  },
                ),
              ),
            ),

            // 4. « Sites populaires » — Cartes portrait plein cadre
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                child: CasamanceSectionHeader(
                  title: 'Sites populaires',
                  subtitle: 'Les escapades les plus demandées',
                  onSeeAll: () => _openExplorer(category: 'TOUS'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _isLoading && _allSites.isEmpty
                  ? const SizedBox(
                      height: 260,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.deepForest,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 294,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: popularSites.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final site = popularSites[index];
                          return CasamanceFeaturedSiteCard(
                            site: site,
                            heroTagPrefix: 'site_photo_pop',
                            isFavorite: _favoriteIds.contains(site.id),
                            reviewCount: _reviewCounts[site.id] ?? 0,
                            onTap: () => _openDetail(site),
                            onToggleFavorite: () => _toggleFavorite(site),
                          );
                        },
                      ),
                    ),
            ),

            // 5. « Les incontournables de la Casamance » — Collage Éditorial Asymétrique
            if (incontournables.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
                  child: CasamanceSectionHeader(
                    title: 'Les incontournables',
                    subtitle: 'Trésors architecturaux, îles & artisanat vivant',
                    onSeeAll: () => _openExplorer(category: 'PATRIMOINE'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MustVisitAsymmetricCollage(
                    sites: incontournables,
                    favoriteIds: _favoriteIds,
                    onTapSite: _openDetail,
                    onToggleFavorite: _toggleFavorite,
                  ),
                ),
              ),
            ],

            // 6. « Les mieux notés »
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
                child: CasamanceSectionHeader(
                  title: 'Les mieux notés',
                  subtitle: 'Plébiscités par nos voyageurs',
                  onSeeAll: () => _openExplorer(category: 'TOUS'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 294,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: topRated.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final site = topRated[index];
                    return CasamanceFeaturedSiteCard(
                      site: site,
                      heroTagPrefix: 'site_photo_top',
                      isFavorite: _favoriteIds.contains(site.id),
                      reviewCount: _reviewCounts[site.id] ?? 0,
                      onTap: () => _openDetail(site),
                      onToggleFavorite: () => _toggleFavorite(site),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// Composition asymétrique pour « Les incontournables » sur l'accueil
class _MustVisitAsymmetricCollage extends StatelessWidget {
  final List<Patrimoine> sites;
  final Set<int> favoriteIds;
  final ValueChanged<Patrimoine> onTapSite;
  final ValueChanged<Patrimoine> onToggleFavorite;

  const _MustVisitAsymmetricCollage({
    required this.sites,
    required this.favoriteIds,
    required this.onTapSite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final primary = sites.first;
    final secondary = sites.skip(1).take(2).toList();

    return Column(
      children: [
        // Grande carte panoramique éditoriale avec motif tissé diola
        SizedBox(
          height: 184,
          child: CasamanceInteractiveCard(
            onTap: () => onTapSite(primary),
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SitePhotoView(site: primary, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppTheme.earthBrown.withValues(alpha: 0.90),
                        AppTheme.deepForest.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CasamanceFavoriteButton(
                    isFavorite: favoriteIds.contains(primary.id),
                    onTap: () => onToggleFavorite(primary),
                    size: 34,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 60,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.champagneGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'COUP DE CŒUR CASAMANCE',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepForest,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        primary.nom,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.editorialTitle(
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${primary.localisation} • ${SiteMediaHelper.dureeEstimee(primary)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppTheme.ivorySand.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CasamanceWovenMotifStrip(
                    height: 6,
                    color: AppTheme.champagneGold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: List.generate(secondary.length, (idx) {
              final s = secondary[idx];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: idx == 0 && secondary.length > 1 ? 6 : 0,
                    left: idx == 1 ? 6 : 0,
                  ),
                  child: SizedBox(
                    height: 148,
                    child: CasamanceInteractiveCard(
                      onTap: () => onTapSite(s),
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SitePhotoView(site: s, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppTheme.deepForest.withValues(alpha: 0.88),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CasamanceFavoriteButton(
                              isFavorite: favoriteIds.contains(s.id),
                              onTap: () => onToggleFavorite(s),
                              size: 30,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.nom,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.editorialTitle(
                                    fontSize: 13.5,
                                    color: Colors.white,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 13,
                                      color: AppTheme.champagneGold,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      s.noteMoyenne.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.champagneGold,
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
            }),
          ),
        ],
      ],
    );
  }
}
