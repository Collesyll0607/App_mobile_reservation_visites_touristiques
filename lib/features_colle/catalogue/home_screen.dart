import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../../main.dart';
import '../reviews/reviews_service.dart';
import 'patrimoine_service.dart';
import 'site_detail_screen.dart';

/// Page d'Accueil — Plateforme Casamance Tourisme & Visites.
/// Hero panoramique immersif, barre de recherche multicritères (site, catégorie, lieu),
/// destinations populaires en grille responsive 1-4 colonnes, 7 catégories photographiques
/// et expériences authentiques ancrées dans les sites réels de la région.
class HomeScreen extends StatefulWidget {
  final List<Patrimoine>? initialSites;

  const HomeScreen({super.key, this.initialSites});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _incontournablesKey = GlobalKey();

  List<Patrimoine> _sites = [];
  Set<int> _favoriteIds = {};
  final Map<int, int> _reviewCounts = {};
  final Map<int, double> _reviewRatings = {};
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'TOUS';
  String _selectedLocation = 'TOUTES';
  int _heroIndex = 0;

  static const List<Map<String, String>> _heroPanoramas = [
    {
      'asset': SiteMediaHelper.heroBannerAsset,
      'label': 'Plage de Carabane',
    },
    {
      'asset': SiteMediaHelper.heroPiroguePanorama,
      'label': 'Pirogues sur le fleuve',
    },
    {
      'asset': SiteMediaHelper.heroZiguinchorPanorama,
      'label': 'Rives de Ziguinchor',
    },
  ];

  static const List<Map<String, String>> _heroCategories = [
    {'code': 'TOUS', 'label': 'Toutes les catégories'},
    {'code': 'NATURE', 'label': 'Nature'},
    {'code': 'PATRIMOINE', 'label': 'Patrimoine'},
    {'code': 'ARCHITECTURE', 'label': 'Architecture'},
    {'code': 'MUSEES', 'label': 'Musées'},
    {'code': 'PLAGES', 'label': 'Plages'},
    {'code': 'ARTISANAT', 'label': 'Artisanat'},
    {'code': 'CULTURE', 'label': 'Culture'},
  ];

  static const List<Map<String, String>> _heroLocations = [
    {'code': 'TOUTES', 'label': 'Toute la Casamance'},
    {'code': 'Ziguinchor', 'label': 'Ziguinchor'},
    {'code': 'Escale', 'label': 'Quartier Escale'},
    {'code': 'Boudody', 'label': 'Port de Boudody'},
    {'code': 'Santhiaba', 'label': 'Santhiaba'},
    {'code': 'Mlomp', 'label': 'Mlomp / Oussouye'},
    {'code': 'Carabane', 'label': 'Île de Carabane'},
  ];

  static const List<_CategoryCardSpec> _categoryCards = [
    _CategoryCardSpec(
      code: 'NATURE',
      label: 'Nature',
      subtitle: 'Bolongs & mangroves',
      asset: 'assets/images/casamance/bolong_mangrove.jpg',
      icon: Icons.forest_rounded,
    ),
    _CategoryCardSpec(
      code: 'PATRIMOINE',
      label: 'Patrimoine',
      subtitle: 'Histoire & mémoire',
      asset: 'assets/images/casamance/cathedrale_ziguinchor.jpg',
      icon: Icons.account_balance_rounded,
    ),
    _CategoryCardSpec(
      code: 'ARCHITECTURE',
      label: 'Architecture',
      subtitle: 'Cases à impluvium',
      asset: 'assets/images/casamance/cases_mlomp.jpg',
      icon: Icons.villa_rounded,
    ),
    _CategoryCardSpec(
      code: 'MUSEES',
      label: 'Musées',
      subtitle: 'Récits & souvenirs',
      asset: 'assets/images/casamance/memorial_joola.jpg',
      icon: Icons.museum_rounded,
    ),
    _CategoryCardSpec(
      code: 'PLAGES',
      label: 'Plages',
      subtitle: 'Côtes & îles',
      asset: SiteMediaHelper.beachCapSkirringAsset,
      icon: Icons.beach_access_rounded,
    ),
    _CategoryCardSpec(
      code: 'ARTISANAT',
      label: 'Artisanat',
      subtitle: 'Savoir-faire locaux',
      asset: SiteMediaHelper.artisanatAsset,
      icon: Icons.palette_rounded,
    ),
    _CategoryCardSpec(
      code: 'CULTURE',
      label: 'Culture',
      subtitle: 'Arts & traditions',
      asset: SiteMediaHelper.cultureAsset,
      icon: Icons.theater_comedy_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await _loadFavorites();
    if (widget.initialSites != null && widget.initialSites!.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _sites = widget.initialSites!;
        _isLoading = false;
      });
      _loadReviewStats();
    } else {
      await _loadSites();
    }
  }

  Future<void> _loadSites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await PatrimoineService.fetchPatrimoines();
    if (!mounted) return;

    setState(() {
      _sites = result.sites;
      _errorMessage = result.fromApiRest
          ? null
          : (result.errorMessage ??
              'Serveur backend injoignable. Aperçu local affiché.');
      _isLoading = false;
    });
    _loadReviewStats();
  }

  Future<void> _loadReviewStats() async {
    for (final site in _sites) {
      final reviews = await ReviewsService.getReviewsForSite(site.id);
      if (!mounted) return;
      double avg = site.noteMoyenne;
      if (reviews.isNotEmpty) {
        final sum = reviews.fold<int>(0, (acc, r) => acc + r.note);
        avg = sum / reviews.length;
      }
      setState(() {
        _reviewCounts[site.id] = reviews.length;
        _reviewRatings[site.id] = avg;
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

  void _launchExplorerSearch({bool resetFilters = false}) {
    MainNavigationShell.switchTab(
      context,
      MainNavigationShell.tabExplorer,
      explorerQuery: resetFilters ? '' : _searchController.text.trim(),
      explorerCategory: resetFilters ? 'TOUS' : _selectedCategory,
      explorerLocation: resetFilters ? 'TOUTES' : _selectedLocation,
    );
  }

  void _scrollToIncontournables() {
    final targetContext = _incontournablesKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _openSiteDetail(Patrimoine site) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SiteDetailScreen(site: site)),
    );
    _loadFavorites();
    _loadReviewStats();
  }

  void _openSiteByKeywordOrFilter(
    String keyword, {
    required String fallbackCategory,
    required String fallbackLocation,
  }) {
    final q = keyword.toLowerCase();
    for (final site in _sites) {
      if (site.nom.toLowerCase().contains(q) ||
          site.localisation.toLowerCase().contains(q)) {
        _openSiteDetail(site);
        return;
      }
    }
    MainNavigationShell.switchTab(
      context,
      MainNavigationShell.tabExplorer,
      explorerCategory: fallbackCategory,
      explorerLocation: fallbackLocation,
    );
  }

  double _ratingFor(Patrimoine site) =>
      _reviewRatings[site.id] ?? site.noteMoyenne;

  List<Patrimoine> get _popularSites {
    final sorted = List<Patrimoine>.from(_sites)
      ..sort((a, b) => _ratingFor(b).compareTo(_ratingFor(a)));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 920;
    final horizontalPad = width >= 1024 ? 28.0 : (width >= 640 ? 22.0 : 16.0);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: RefreshIndicator(
        color: AppTheme.forestGreen,
        onRefresh: _loadSites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HERO SECTION PANORAMIQUE PLEINE LARGEUR
              _buildHeroSection(width, isDesktop, horizontalPad),

              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    18,
                    horizontalPad,
                    0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
                      child: CasamanceApiErrorBanner(
                        message: _errorMessage!,
                        onRetry: _loadSites,
                      ),
                    ),
                  ),
                ),

              // 2. DESTINATIONS POPULAIRES : EXPLOREZ LES INCONTOURNABLES DE LA CASAMANCE
              Container(
                key: _incontournablesKey,
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  isDesktop ? 42 : 28,
                  horizontalPad,
                  isDesktop ? 42 : 30,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppTheme.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CasamanceSectionHeader(
                          title: 'Explorez les incontournables de la Casamance',
                          subtitle:
                              'Les sites naturels, historiques et culturels les plus appréciés de Ziguinchor et de sa région',
                          actionLabel: _sites.isEmpty
                              ? 'Tout voir'
                              : 'Tout voir (${_sites.length})',
                          onSeeAll: () =>
                              _launchExplorerSearch(resetFilters: true),
                        ),
                        const SizedBox(height: 20),
                        _buildPopularSitesGrid(width),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. EXPLORER PAR CATÉGORIE (7 CARTES PHOTOGRAPHIQUES SUR FOND BLANC PUR)
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.pureWhite,
                  border: Border(
                    top: BorderSide(color: AppTheme.borderLight),
                    bottom: BorderSide(color: AppTheme.borderLight),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  isDesktop ? 40 : 28,
                  horizontalPad,
                  isDesktop ? 44 : 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppTheme.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CasamanceSectionHeader(
                          title: 'Explorer par catégorie',
                          subtitle:
                              'Choisissez une thématique pour filtrer les merveilles de la Casamance',
                          actionLabel: 'Toutes les visites',
                          onSeeAll: () =>
                              _launchExplorerSearch(resetFilters: true),
                        ),
                        const SizedBox(height: 18),
                        _buildCategoriesShowcase(width),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. EXPÉRIENCES : VIVEZ LA CASAMANCE AUTREMENT
              Container(
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  isDesktop ? 42 : 28,
                  horizontalPad,
                  isDesktop ? 48 : 34,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppTheme.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CasamanceSectionHeader(
                          title: 'Vivez la Casamance autrement',
                          subtitle:
                              'Des parcours authentiques accessibles dès maintenant via l\'application et nos guides locaux',
                        ),
                        const SizedBox(height: 20),
                        _buildExperiencesSection(width),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. FOOTER PROPRE ET STRUCTURÉ
              _buildFooter(horizontalPad, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    double width,
    bool isDesktop,
    double horizontalPad,
  ) {
    final activeHero = _heroPanoramas[_heroIndex];

    return Stack(
      children: [
        // Fond panoramique haute qualité + dégradé lisible lumineux
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              activeHero['asset']!,
              key: ValueKey<String>(activeHero['asset']!),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.45, 0.85],
                colors: [
                  Colors.black.withValues(alpha: isDesktop ? 0.50 : 0.42),
                  Colors.black.withValues(alpha: isDesktop ? 0.22 : 0.30),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.6, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.transparent,
                  AppTheme.forestGreen.withValues(alpha: 0.38),
                ],
              ),
            ),
          ),
        ),

        // Contenu éditorial + Recherche intégrée
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: isDesktop ? 510 : 440),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  isDesktop ? 48 : 26,
                  horizontalPad,
                  isDesktop ? 40 : 28,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pastille géographique discrète
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppTheme.accentOrange,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Ziguinchor · Bolongs · Île de Carabane',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Titre principal
                    Text(
                      'La Casamance vous attend',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 46 : (width >= 600 ? 34 : 28),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.12,
                        letterSpacing: -0.6,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.32),
                            blurRadius: 16,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sous-titre
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Text(
                        'Explorez ses merveilles, vivez sa culture et découvrez des lieux inoubliables.',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 17 : 14.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.45,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.28),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Barre de recherche intégrée Airbnb / Booking
                    _HeroSearchCard(
                      isDesktop: isDesktop,
                      searchController: _searchController,
                      selectedCategory: _selectedCategory,
                      selectedLocation: _selectedLocation,
                      categories: _heroCategories,
                      locations: _heroLocations,
                      onCategoryChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      onLocationChanged: (val) =>
                          setState(() => _selectedLocation = val),
                      onSubmit: () => _launchExplorerSearch(),
                    ),
                    const SizedBox(height: 20),

                    // Boutons CTA + Sélecteur discret de panorama sur desktop
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _launchExplorerSearch(resetFilters: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.explore_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  'Explorer les destinations',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _scrollToIncontournables,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.16),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 17,
                                ),
                                label: Text(
                                  'Découvrir les incontournables',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (width >= 960) ...[
                          const SizedBox(width: 16),
                          _HeroPanoramaSwitcher(
                            panoramas: _heroPanoramas,
                            selectedIndex: _heroIndex,
                            onSelected: (index) =>
                                setState(() => _heroIndex = index),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSitesGrid(double width) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.forestGreen),
        ),
      );
    }

    final sites = _popularSites;
    if (sites.isEmpty) {
      return CasamanceEmptyState(
        icon: Icons.travel_explore_rounded,
        title: 'Aucune destination chargée',
        subtitle: 'Vérifiez la connexion avec le serveur patrimonial.',
        actionLabel: 'Actualiser',
        onAction: _loadSites,
      );
    }

    // 4 colonnes grand écran, 3 colonnes écran moyen, 2 tablette, 1 mobile
    final int cols =
        width >= 1140 ? 4 : (width >= 860 ? 3 : (width >= 580 ? 2 : 1));
    final rowCount = (sites.length / cols).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rowCount - 1 ? 18 : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(cols, (col) {
                final itemIndex = rowIndex * cols + col;
                if (itemIndex >= sites.length) {
                  return const Expanded(child: SizedBox.shrink());
                }
                final site = sites[itemIndex];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0 * col / cols,
                      right: 16.0 * (cols - 1 - col) / cols,
                    ),
                    child: CasamanceSiteCard(
                      site: site,
                      heroTagPrefix: 'home_incontournable',
                      isFavorite: _favoriteIds.contains(site.id),
                      rating: _ratingFor(site),
                      reviewCount: _reviewCounts[site.id] ?? 0,
                      onToggleFavorite: () => _toggleFavorite(site),
                      onTap: () => _openSiteDetail(site),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoriesShowcase(double width) {
    if (width >= 1040) {
      // 7 cartes photographiques équilibrées en ligne sur grand ordinateur
      return Row(
        children: List.generate(_categoryCards.length, (index) {
          final item = _categoryCards[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 12.0 * index / _categoryCards.length,
                right: 12.0 *
                    (_categoryCards.length - 1 - index) /
                    _categoryCards.length,
              ),
              child: _CategoryPhotoCard(
                spec: item,
                height: 184,
                onTap: () => MainNavigationShell.switchTab(
                  context,
                  MainNavigationShell.tabExplorer,
                  explorerCategory: item.code,
                ),
              ),
            ),
          );
        }),
      );
    }

    if (width >= 660) {
      // Grille 4 + 3 sur tablette
      const cols = 4;
      final rowCount = (_categoryCards.length / cols).ceil();
      return Column(
        children: List.generate(rowCount, (row) {
          return Padding(
            padding: EdgeInsets.only(bottom: row < rowCount - 1 ? 12 : 0),
            child: Row(
              children: List.generate(cols, (col) {
                final idx = row * cols + col;
                if (idx >= _categoryCards.length) {
                  return const Expanded(child: SizedBox.shrink());
                }
                final item = _categoryCards[idx];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12.0 * col / cols,
                      right: 12.0 * (cols - 1 - col) / cols,
                    ),
                    child: _CategoryPhotoCard(
                      spec: item,
                      height: 164,
                      onTap: () => MainNavigationShell.switchTab(
                        context,
                        MainNavigationShell.tabExplorer,
                        explorerCategory: item.code,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      );
    }

    // Mobile : carrousel horizontal fluide
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categoryCards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _categoryCards[index];
          return SizedBox(
            width: 152,
            child: _CategoryPhotoCard(
              spec: item,
              height: 170,
              onTap: () => MainNavigationShell.switchTab(
                context,
                MainNavigationShell.tabExplorer,
                explorerCategory: item.code,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExperiencesSection(double width) {
    final experiences = [
      _ExperienceSpec(
        tag: 'Bolongs & Îles',
        title: 'Traversée vers l\'Île de Carabane et les mangroves',
        description:
            'Explorez l\'embouchure du fleuve Casamance, les chenaux des bolongs et l\'ancien comptoir historique de Carabane accessible en pirogue.',
        ctaLabel: 'Découvrir Carabane',
        asset: SiteMediaHelper.heroPiroguePanorama,
        icon: Icons.directions_boat_rounded,
        onTap: () => _openSiteByKeywordOrFilter(
          'carabane',
          fallbackCategory: 'NATURE',
          fallbackLocation: 'Carabane',
        ),
      ),
      _ExperienceSpec(
        tag: 'Visites guidées',
        title: 'Cases à étages de Mlomp avec guide local certifié',
        description:
            'Découvrez l\'architecture traditionnelle diola en terre crue et réservez directement votre visite avec option guide certifié.',
        ctaLabel: 'Voir les cases de Mlomp',
        asset: 'assets/images/casamance/cases_mlomp.jpg',
        icon: Icons.support_agent_rounded,
        onTap: () => _openSiteByKeywordOrFilter(
          'mlomp',
          fallbackCategory: 'ARCHITECTURE',
          fallbackLocation: 'Mlomp',
        ),
      ),
      _ExperienceSpec(
        tag: 'Artisanat & Culture',
        title: 'Village artisanal de Santhiaba & Quai de Boudody',
        description:
            'Rencontrez les sculpteurs sur bois, tisserands et artistes de Ziguinchor avant de flâner sur la corniche et le port.',
        ctaLabel: 'Explorer l\'artisanat',
        asset: SiteMediaHelper.artisanatAsset,
        icon: Icons.palette_rounded,
        onTap: () => MainNavigationShell.switchTab(
          context,
          MainNavigationShell.tabExplorer,
          explorerCategory: 'ARTISANAT',
        ),
      ),
      _ExperienceSpec(
        tag: 'Navigation & Billets QR',
        title: 'Carte GPS interactive et billets de visite sécurisés',
        description:
            'Localisez chaque site touristique sur la carte interactive en temps réel et retrouvez vos réservations confirmées dans votre espace.',
        ctaLabel: 'Ouvrir la carte GPS',
        asset: SiteMediaHelper.heroZiguinchorPanorama,
        icon: Icons.map_rounded,
        onTap: () => MainNavigationShell.switchTab(
          context,
          MainNavigationShell.tabCarte,
        ),
      ),
    ];

    if (width >= 860) {
      // Grille éditoriale 2 x 2 sur ordinateur
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _ExperienceEditorialCard(spec: experiences[0])),
              const SizedBox(width: 18),
              Expanded(child: _ExperienceEditorialCard(spec: experiences[1])),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _ExperienceEditorialCard(spec: experiences[2])),
              const SizedBox(width: 18),
              Expanded(child: _ExperienceEditorialCard(spec: experiences[3])),
            ],
          ),
        ],
      );
    }

    return Column(
      children: List.generate(experiences.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < experiences.length - 1 ? 14 : 0),
          child: _ExperienceEditorialCard(spec: experiences[i]),
        );
      }),
    );
  }

  Widget _buildFooter(double horizontalPad, bool isDesktop) {
    return Container(
      color: AppTheme.forestGreen,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: isDesktop ? 32 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CasamanceEmblemMark(size: 36),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Casamance Tourisme & Visites',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Patrimoine, culture et visites guidées à Ziguinchor',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _footerLink(
                    'Explorer',
                    () => MainNavigationShell.switchTab(
                      context,
                      MainNavigationShell.tabExplorer,
                    ),
                  ),
                  _footerLink(
                    'Carte GPS',
                    () => MainNavigationShell.switchTab(
                      context,
                      MainNavigationShell.tabCarte,
                    ),
                  ),
                  _footerLink(
                    'Réservations',
                    () => MainNavigationShell.switchTab(
                      context,
                      MainNavigationShell.tabReservations,
                    ),
                  ),
                  _footerLink(
                    'Favoris',
                    () => MainNavigationShell.switchTab(
                      context,
                      MainNavigationShell.tabFavoris,
                    ),
                  ),
                  _footerLink(
                    'Profil',
                    () => MainNavigationShell.switchTab(
                      context,
                      MainNavigationShell.tabCompte,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Barre de recherche multicritères blanche inspirée des plateformes de voyage
class _HeroSearchCard extends StatelessWidget {
  final bool isDesktop;
  final TextEditingController searchController;
  final String selectedCategory;
  final String selectedLocation;
  final List<Map<String, String>> categories;
  final List<Map<String, String>> locations;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onSubmit;

  const _HeroSearchCard({
    required this.isDesktop,
    required this.searchController,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.categories,
    required this.locations,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isDesktop ? _buildDesktopRow() : _buildCompactColumn(),
    );
  }

  Widget _buildDesktopRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Site touristique / mot-clé
          Expanded(
            flex: 4,
            child: _searchFieldBlock(),
          ),
          const VerticalDivider(
            width: 20,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: AppTheme.borderLight,
          ),
          // 2. Catégorie
          Expanded(
            flex: 3,
            child: _dropdownBlock(
              icon: Icons.category_outlined,
              label: 'Catégorie',
              value: selectedCategory,
              items: categories,
              onChanged: onCategoryChanged,
            ),
          ),
          const VerticalDivider(
            width: 20,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: AppTheme.borderLight,
          ),
          // 3. Localisation
          Expanded(
            flex: 3,
            child: _dropdownBlock(
              icon: Icons.place_outlined,
              label: 'Localisation',
              value: selectedLocation,
              items: locations,
              onChanged: onLocationChanged,
            ),
          ),
          const SizedBox(width: 10),
          // 4. Bouton Rechercher
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 19),
              label: Text(
                'Rechercher',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _searchFieldBlock(),
        const Divider(height: 16, color: AppTheme.borderLight),
        Row(
          children: [
            Expanded(
              child: _dropdownBlock(
                icon: Icons.category_outlined,
                label: 'Catégorie',
                value: selectedCategory,
                items: categories,
                onChanged: onCategoryChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dropdownBlock(
                icon: Icons.place_outlined,
                label: 'Localisation',
                value: selectedLocation,
                items: locations,
                onChanged: onLocationChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.search_rounded, size: 18),
            label: Text(
              'Rechercher',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchFieldBlock() {
    return TextField(
      controller: searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      style: GoogleFonts.poppins(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: AppTheme.textDark,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.forestGreen,
          size: 20,
        ),
        hintText: 'Rechercher un site (Carabane, Boudody...)',
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppTheme.textMuted,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _dropdownBlock({
    required IconData icon,
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppTheme.forestGreen,
            ),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
            items: items.map((entry) {
              return DropdownMenuItem<String>(
                value: entry['code']!,
                child: Row(
                  children: [
                    Icon(icon, size: 15, color: AppTheme.naturalGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry['label']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}

/// Sélecteur discret permettant de basculer entre les panoramas de Casamance du Hero
class _HeroPanoramaSwitcher extends StatelessWidget {
  final List<Map<String, String>> panoramas;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _HeroPanoramaSwitcher({
    required this.panoramas,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(panoramas.length, (index) {
          final item = panoramas[index];
          final active = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Tooltip(
              message: item['label']!,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(left: index > 0 ? 6 : 0),
                width: active ? 46 : 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active
                        ? AppTheme.accentOrange
                        : Colors.white.withValues(alpha: 0.45),
                    width: active ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(item['asset']!, fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CategoryCardSpec {
  final String code;
  final String label;
  final String subtitle;
  final String asset;
  final IconData icon;

  const _CategoryCardSpec({
    required this.code,
    required this.label,
    required this.subtitle,
    required this.asset,
    required this.icon,
  });
}

class _CategoryPhotoCard extends StatefulWidget {
  final _CategoryCardSpec spec;
  final double height;
  final VoidCallback onTap;

  const _CategoryPhotoCard({
    required this.spec,
    required this.height,
    required this.onTap,
  });

  @override
  State<_CategoryPhotoCard> createState() => _CategoryPhotoCardState();
}

class _CategoryPhotoCardState extends State<_CategoryPhotoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _hovered ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: Image.asset(
                    spec.asset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      spec.icon,
                      size: 16,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 10,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        spec.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        spec.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
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
  }
}

class _ExperienceSpec {
  final String tag;
  final String title;
  final String description;
  final String ctaLabel;
  final String asset;
  final IconData icon;
  final VoidCallback onTap;

  const _ExperienceSpec({
    required this.tag,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.asset,
    required this.icon,
    required this.onTap,
  });
}

class _ExperienceEditorialCard extends StatelessWidget {
  final _ExperienceSpec spec;

  const _ExperienceEditorialCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 520;

    return Container(
      height: compact ? null : 228,
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: spec.onTap,
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(spec.asset, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildTextColumn(),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 195,
                    child: Image.asset(
                      spec.asset,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: _buildTextColumn(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.paleGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(spec.icon, size: 13, color: AppTheme.forestGreen),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      spec.tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              spec.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              spec.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppTheme.textMuted,
                height: 1.45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                spec.ctaLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppTheme.forestGreen,
            ),
          ],
        ),
      ],
    );
  }
}
