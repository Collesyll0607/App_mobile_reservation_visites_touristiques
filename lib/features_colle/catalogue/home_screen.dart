import 'package:flutter/material.dart';
import '../../core/models/avis.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../../main.dart';
import '../reviews/reviews_service.dart';
import 'patrimoine_service.dart';
import 'site_detail_screen.dart';

/// Page d'Accueil — Plateforme haut de gamme Casamance Tourisme & Visites.
/// - Hero immersif avec carrousel plein écran et navigation par miniatures
/// - Barre de recherche flottante élégante (site/mot-clé, catégorie, localisation, date)
/// - Sections : « Incontournables » (avec skeleton loader), « Par catégorie »,
///   « Avis des visiteurs récents », « Pourquoi réserver avec nous » et footer complet.
/// Conforme au Design System (Fraunces + Plus Jakarta Sans, mode clair/sombre).
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
  final List<Avis> _allRecentAvis = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'TOUS';
  String _selectedLocation = 'TOUTES';
  DateTime? _selectedDate;
  int _heroIndex = 0;

  static const List<Map<String, String>> _heroPanoramas = [
    {
      'asset': SiteMediaHelper.heroBannerAsset,
      'label': 'Plage de Carabane',
      'location': 'Île de Carabane · Embouchure du Fleuve',
    },
    {
      'asset': SiteMediaHelper.heroPiroguePanorama,
      'label': 'Bolongs & Pirogues',
      'location': 'Estuaire de Casamance · Mangroves',
    },
    {
      'asset': SiteMediaHelper.heroZiguinchorPanorama,
      'label': 'Rives de Ziguinchor',
      'location': 'Corniche Fluviale · Pont Émile Badiane',
    },
  ];

  static const List<Map<String, String>> _heroCategories = [
    {'code': 'TOUS', 'label': 'Toutes les catégories'},
    {'code': 'NATURE', 'label': 'Nature & Mangroves'},
    {'code': 'PATRIMOINE', 'label': 'Patrimoine historique'},
    {'code': 'ARCHITECTURE', 'label': 'Architecture diola'},
    {'code': 'MUSEES', 'label': 'Musées & Mémoire'},
    {'code': 'PLAGES', 'label': 'Plages & Îles'},
    {'code': 'ARTISANAT', 'label': 'Artisanat & Métiers'},
    {'code': 'CULTURE', 'label': 'Culture & Traditions'},
  ];

  static const List<Map<String, String>> _heroLocations = [
    {'code': 'TOUTES', 'label': 'Toute la Casamance'},
    {'code': 'Ziguinchor', 'label': 'Ziguinchor Ville'},
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
    final List<Avis> collected = [];
    for (final site in _sites) {
      final reviews = await ReviewsService.getReviewsForSite(site.id);
      if (!mounted) return;
      collected.addAll(reviews);
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
    if (mounted) {
      setState(() {
        _allRecentAvis
          ..clear()
          ..addAll(collected.take(6));
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
        duration: const Duration(milliseconds: 550),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Sélectionner la date de visite souhaitée',
      cancelText: 'Annuler',
      confirmText: 'Choisir',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
    final bool isDesktop = width >= 960;
    final horizontalPad = width >= 1040 ? 32.0 : (width >= 640 ? 24.0 : 16.0);
    final bg = AppTheme.backgroundOf(context);

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        color: AppTheme.forestGreen,
        onRefresh: _loadSites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HERO IMMERSIF PLEIN ÉCRAN AVEC CARROUSEL & RECHERCHE FLOTTANTE
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

              // 2. DESTINATIONS POPULAIRES : INCONTOURNABLES
              Container(
                key: _incontournablesKey,
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  isDesktop ? 48 : 32,
                  horizontalPad,
                  isDesktop ? 44 : 28,
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
                        const SizedBox(height: 22),
                        _buildPopularSitesGrid(width),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. EXPLORER PAR CATÉGORIE
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOf(context),
                  border: Border(
                    top: BorderSide(color: AppTheme.borderOf(context)),
                    bottom: BorderSide(color: AppTheme.borderOf(context)),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  isDesktop ? 44 : 32,
                  horizontalPad,
                  isDesktop ? 48 : 36,
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
                        const SizedBox(height: 20),
                        _buildCategoriesShowcase(width),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. AVIS DES VISITEURS RÉCENTS
              _buildReviewsSection(horizontalPad, isDesktop),

              // 5. POURQUOI RÉSERVER AVEC NOUS (ENGAGEMENTS QUALITÉ)
              _buildWhyBookWithUs(horizontalPad, isDesktop),

              // 6. FOOTER COMPLET & ÉLÉGANT
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
        // Photographie panoramique avec transition douce
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
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

        // Dégradé latéral gauche (lisibilité maximale du texte sur l'image)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.48, 0.90],
                colors: [
                  Colors.black.withValues(alpha: isDesktop ? 0.52 : 0.46),
                  Colors.black.withValues(alpha: isDesktop ? 0.24 : 0.32),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Dégradé vertical (fondu subtil vers la navbar et le bas)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.65, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.transparent,
                  AppTheme.forestGreen.withValues(alpha: 0.40),
                ],
              ),
            ),
          ),
        ),

        // Contenu éditorial + Barre de recherche flottante
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: isDesktop ? 540 : 470),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  isDesktop ? 54 : 32,
                  horizontalPad,
                  isDesktop ? 44 : 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge géographique en verre dépoli
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppTheme.ocreGold,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              activeHero['location']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.bodyStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Titre principal en Fraunces
                    Text(
                      'La Casamance vous attend',
                      style: AppTheme.headingStyle(
                        fontSize: isDesktop ? 50 : (width >= 600 ? 36 : 30),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ).copyWith(
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.38),
                            blurRadius: 18,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sous-titre
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Text(
                        'Explorez ses merveilles, vivez sa culture et découvrez des lieux inoubliables.',
                        style: AppTheme.bodyStyle(
                          fontSize: isDesktop ? 17 : 14.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.5,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Barre de recherche flottante élégante (site, catégorie, lieu, date)
                    _HeroSearchCard(
                      isDesktop: isDesktop,
                      searchController: _searchController,
                      selectedCategory: _selectedCategory,
                      selectedLocation: _selectedLocation,
                      selectedDate: _selectedDate,
                      categories: _heroCategories,
                      locations: _heroLocations,
                      onCategoryChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      onLocationChanged: (val) =>
                          setState(() => _selectedLocation = val),
                      onPickDate: _pickDate,
                      onClearDate: () => setState(() => _selectedDate = null),
                      onSubmit: () => _launchExplorerSearch(),
                    ),
                    const SizedBox(height: 22),

                    // Boutons CTA + Miniatures du carrousel panoramique
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
                                  backgroundColor: AppTheme.ocreGold,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radius12,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.explore_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  'Explorer les destinations',
                                  style: AppTheme.bodyStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _scrollToIncontournables,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.18),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    width: 1.3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radius12,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 17,
                                ),
                                label: Text(
                                  'Découvrir les incontournables',
                                  style: AppTheme.bodyStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
    final int cols =
        width >= 1140 ? 4 : (width >= 860 ? 3 : (width >= 580 ? 2 : 1));

    // Skeleton loader animé en cas de chargement
    if (_isLoading) {
      return Column(
        children: List.generate(2, (rowIndex) {
          return Padding(
            padding: EdgeInsets.only(bottom: rowIndex == 0 ? 18 : 0),
            child: Row(
              children: List.generate(cols, (col) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0 * col / cols,
                      right: 16.0 * (cols - 1 - col) / cols,
                    ),
                    child: const CasamanceSkeletonCard(),
                  ),
                );
              }),
            ),
          );
        }),
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

    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categoryCards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _categoryCards[index];
          return SizedBox(
            width: 154,
            child: _CategoryPhotoCard(
              spec: item,
              height: 172,
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

  Widget _buildReviewsSection(double horizontalPad, bool isDesktop) {
    final list = _allRecentAvis.isNotEmpty
        ? _allRecentAvis
        : const [
            Avis(
              id: 1,
              patrimoineId: 1,
              auteur: 'Awa Diop',
              note: 5,
              commentaire:
                  'Magnifique découverte au cœur de Ziguinchor, un lieu vivant et chargé d\'histoire !',
              datePublication: '02/11/2026',
            ),
            Avis(
              id: 2,
              patrimoineId: 4,
              auteur: 'Jean-Marc Faye',
              note: 5,
              commentaire:
                  'La traversée en pirogue vers Carabane et l\'église bretonne sont exceptionnelles.',
              datePublication: '05/11/2026',
            ),
            Avis(
              id: 3,
              patrimoineId: 7,
              auteur: 'Mariama Sané',
              note: 5,
              commentaire:
                  'Les cases à étages de Mlomp témoignent d\'un génie architectural unique en Afrique.',
              datePublication: '09/11/2026',
            ),
          ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        isDesktop ? 48 : 34,
        horizontalPad,
        isDesktop ? 46 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CasamanceSectionHeader(
                title: 'Avis des visiteurs',
                subtitle:
                    'Les retours authentiques de voyageurs ayant exploré nos sites patrimoniaux',
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final int cols = w >= 960 ? 3 : (w >= 620 ? 2 : 1);
                  final displayAvis = list.take(cols * 2).toList();
                  final rowCount = (displayAvis.length / cols).ceil();

                  return Column(
                    children: List.generate(rowCount, (r) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: r < rowCount - 1 ? 16 : 0,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(cols, (c) {
                              final idx = r * cols + c;
                              if (idx >= displayAvis.length) {
                                return const Expanded(
                                  child: SizedBox.shrink(),
                                );
                              }
                              final avis = displayAvis[idx];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.0 * c / cols,
                                    right: 16.0 * (cols - 1 - c) / cols,
                                  ),
                                  child: _VisitorReviewCard(avis: avis),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhyBookWithUs(double horizontalPad, bool isDesktop) {
    const reasons = [
      _ReasonSpec(
        icon: Icons.verified_user_rounded,
        title: 'Sites & Tarifs Officiels',
        description:
            'Partenariat direct avec les gestionnaires locaux et tarifs transparents sans mauvaise surprise.',
      ),
      _ReasonSpec(
        icon: Icons.support_agent_rounded,
        title: 'Guides Locaux Certifiés',
        description:
            'Des passionnés nés en Casamance formés pour partager l\'histoire et les traditions diola.',
      ),
      _ReasonSpec(
        icon: Icons.qr_code_2_rounded,
        title: 'Billetterie QR Instantanée',
        description:
            'Recevez vos accès numériques immédiatement, consultables hors-ligne lors de vos traversées.',
      ),
      _ReasonSpec(
        icon: Icons.volunteer_activism_rounded,
        title: 'Impact Communautaire',
        description:
            'Chaque visite soutient directement l\'artisanat, les piroguiers et la préservation du patrimoine.',
      ),
    ];

    final surface = AppTheme.surfaceOf(context);
    final border = AppTheme.borderOf(context);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: border),
          bottom: BorderSide(color: border),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        isDesktop ? 50 : 34,
        horizontalPad,
        isDesktop ? 54 : 38,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CasamanceSectionHeader(
                title: 'Pourquoi réserver avec nous ?',
                subtitle:
                    'Une expérience touristique engagée, fluide et respectueuse des terroirs',
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final int cols = w >= 980 ? 4 : (w >= 540 ? 2 : 1);
                  final rowCount = (reasons.length / cols).ceil();

                  return Column(
                    children: List.generate(rowCount, (r) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: r < rowCount - 1 ? 16 : 0,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(cols, (c) {
                              final idx = r * cols + c;
                              if (idx >= reasons.length) {
                                return const Expanded(
                                  child: SizedBox.shrink(),
                                );
                              }
                              final spec = reasons[idx];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.0 * c / cols,
                                    right: 16.0 * (cols - 1 - c) / cols,
                                  ),
                                  child: _WhyBookCard(spec: spec),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(double horizontalPad, bool isDesktop) {
    return Container(
      color: AppTheme.forestGreen,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: isDesktop ? 40 : 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            children: [
              Wrap(
                spacing: 28,
                runSpacing: 20,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CasamanceEmblemMark(size: 40),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Casamance Tourisme & Visites',
                              style: AppTheme.headingStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Patrimoine, culture et visites guidées en Casamance',
                              style: AppTheme.bodyStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
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
                        'Accueil',
                        () => MainNavigationShell.switchTab(
                          context,
                          MainNavigationShell.tabAccueil,
                        ),
                      ),
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
              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '© 2026 Casamance Tourisme · UASZ L3-2I',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bodyStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: AppTheme.toggleThemeMode,
                    tooltip: 'Basculer clair / sombre',
                    icon: Icon(
                      AppTheme.isDark(context)
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 20,
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
        style: AppTheme.bodyStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

/// Barre de recherche flottante élégante inspirée des meilleures plateformes
class _HeroSearchCard extends StatelessWidget {
  final bool isDesktop;
  final TextEditingController searchController;
  final String selectedCategory;
  final String selectedLocation;
  final DateTime? selectedDate;
  final List<Map<String, String>> categories;
  final List<Map<String, String>> locations;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;
  final VoidCallback onSubmit;

  const _HeroSearchCard({
    required this.isDesktop,
    required this.searchController,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.selectedDate,
    required this.categories,
    required this.locations,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.onPickDate,
    required this.onClearDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppTheme.radius24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isDesktop ? _buildDesktopRow(context) : _buildMobileStack(context),
    );
  }

  Widget _buildDesktopRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Site / Mot-clé
          Expanded(
            flex: 3,
            child: _searchFieldBlock(context),
          ),
          _divider(),
          // 2. Catégorie
          Expanded(
            flex: 2,
            child: _dropdownBlock(
              icon: Icons.category_outlined,
              label: 'Catégorie',
              value: selectedCategory,
              items: categories,
              onChanged: onCategoryChanged,
            ),
          ),
          _divider(),
          // 3. Localisation
          Expanded(
            flex: 2,
            child: _dropdownBlock(
              icon: Icons.place_outlined,
              label: 'Localisation',
              value: selectedLocation,
              items: locations,
              onChanged: onLocationChanged,
            ),
          ),
          _divider(),
          // 4. Date de visite
          Expanded(
            flex: 2,
            child: _dateBlock(context),
          ),
          const SizedBox(width: 8),
          // 5. Bouton Rechercher
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius16),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: Text(
                'Rechercher',
                style: AppTheme.bodyStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStack(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _searchFieldBlock(context),
        const Divider(height: 14, color: AppTheme.borderSand),
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
            const SizedBox(width: 8),
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
        const SizedBox(height: 10),
        _dateBlock(context),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
            ),
            icon: const Icon(Icons.search_rounded, size: 19),
            label: Text(
              'Rechercher',
              style: AppTheme.bodyStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const VerticalDivider(
      width: 18,
      thickness: 1,
      indent: 8,
      endIndent: 8,
      color: AppTheme.borderSand,
    );
  }

  Widget _searchFieldBlock(BuildContext context) {
    final textDark = AppTheme.textOf(context);
    final textMuted = AppTheme.mutedOf(context);

    return TextField(
      controller: searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      style: AppTheme.bodyStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.forestGreen,
          size: 21,
        ),
        hintText: 'Rechercher un site (Carabane, Boudody...)',
        hintStyle: AppTheme.bodyStyle(
          fontSize: 13,
          color: textMuted,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
            style: AppTheme.bodyStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
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
            style: AppTheme.bodyStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            items: items.map((entry) {
              return DropdownMenuItem<String>(
                value: entry['code']!,
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: AppTheme.naturalGreen),
                    const SizedBox(width: 5),
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

  Widget _dateBlock(BuildContext context) {
    final dateStr = selectedDate != null
        ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
        : 'Indifférente';

    return InkWell(
      onTap: onPickDate,
      borderRadius: BorderRadius.circular(AppTheme.radius12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Date de visite',
              style: AppTheme.bodyStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppTheme.oceanBlue,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selectedDate != null
                          ? AppTheme.textOf(context)
                          : AppTheme.mutedOf(context),
                    ),
                  ),
                ),
                if (selectedDate != null)
                  InkWell(
                    onTap: onClearDate,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sélecteur de panorama panoramique avec miniatures
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
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
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
                width: active ? 48 : 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active
                        ? AppTheme.ocreGold
                        : Colors.white.withValues(alpha: 0.5),
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
        duration: const Duration(milliseconds: 220),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius16),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 18,
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
                        Colors.black.withValues(alpha: 0.75),
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
                      color: Colors.white.withValues(alpha: 0.94),
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
                        style: AppTheme.headingStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        spec.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.9),
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

/// Carte élégante d'avis d'un voyageur
class _VisitorReviewCard extends StatelessWidget {
  final Avis avis;

  const _VisitorReviewCard({required this.avis});

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surfaceOf(context);
    final border = AppTheme.borderOf(context);
    final textDark = AppTheme.textOf(context);
    final textMuted = AppTheme.mutedOf(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: border),
        boxShadow: AppTheme.shadowFor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        starIdx < avis.note
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: AppTheme.ocreGold,
                      );
                    }),
                  ),
                  Text(
                    avis.datePublication,
                    style: AppTheme.bodyStyle(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"${avis.commentaire}"',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyStyle(
                  fontSize: 13,
                  color: textDark,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.paleGreen,
                child: Text(
                  avis.auteur.isNotEmpty ? avis.auteur[0].toUpperCase() : 'V',
                  style: AppTheme.bodyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  avis.auteur,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonSpec {
  final IconData icon;
  final String title;
  final String description;

  const _ReasonSpec({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Carte d'engagement « Pourquoi réserver avec nous »
class _WhyBookCard extends StatelessWidget {
  final _ReasonSpec spec;

  const _WhyBookCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surfaceOf(context);
    final border = AppTheme.borderOf(context);
    final textDark = AppTheme.textOf(context);
    final textMuted = AppTheme.mutedOf(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: border),
        boxShadow: AppTheme.shadowFor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.paleGreen,
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              spec.icon,
              size: 22,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            spec.title,
            style: AppTheme.headingStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            spec.description,
            style: AppTheme.bodyStyle(
              fontSize: 12.5,
              color: textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
