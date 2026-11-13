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

/// Page d'Accueil — Direction Artistique : AFRICAN TROPICAL LUXURY TRAVEL
/// - Hero Section spectaculaire 75% viewport avec composition asymétrique
/// - Titre Playfair Display : « Là où la nature rencontre l'authenticité. »
/// - Badge éditorial « Sénégal • Casamance »
/// - Panneau de recherche flottant compact & harmonieux
/// - Section « Des lieux qui méritent le détour » en grille asymétrique magazine
/// - Section « L'âme de la Casamance » (Nature, Patrimoine, Culture, Artisanat, Architecture, Fleuves & Plages)
/// - Engagements d'exception & Footer complet
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue)
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
  final String _selectedLocation = 'TOUTES';
  DateTime? _selectedDate;
  int _heroIndex = 0;

  static const List<Map<String, String>> _heroPanoramas = [
    {
      'asset': 'assets/images/casamance/carabane_pirogue_panorama.jpg',
      'label': 'Bolongs & Pirogues d\'or',
      'location': 'Île de Carabane • Embouchure du Fleuve',
      'highlightSite': 'Île de Carabane',
      'highlightDist': 'Traversée en pirogue artisanale',
    },
    {
      'asset': 'assets/images/casamance/bolong_mangrove.jpg',
      'label': 'Labyrinthe végétal des Bolongs',
      'location': 'Estuaire de Casamance • Forêt de Palétuviers',
      'highlightSite': 'Bolongs de Casamance',
      'highlightDist': 'Sanctuaire d\'oiseaux migrateurs',
    },
    {
      'asset': 'assets/images/casamance/ziguinchor_panoramique.jpg',
      'label': 'Rives de Ziguinchor',
      'location': 'Corniche Fluviale • Pont Émile Badiane',
      'highlightSite': 'Port de Boudody',
      'highlightDist': 'Marché vivant des pêcheurs',
    },
  ];

  static const List<Map<String, String>> _heroCategories = [
    {'code': 'TOUS', 'label': 'Toutes les expériences'},
    {'code': 'NATURE', 'label': 'Nature & Mangroves'},
    {'code': 'PATRIMOINE', 'label': 'Patrimoine historique'},
    {'code': 'ARCHITECTURE', 'label': 'Architecture diola'},
    {'code': 'MUSEES', 'label': 'Musées & Mémoire'},
    {'code': 'PLAGES', 'label': 'Plages & Îles'},
    {'code': 'ARTISANAT', 'label': 'Artisanat d\'art'},
    {'code': 'CULTURE', 'label': 'Culture & Traditions'},
  ];

  static const List<_PillarSpec> _casamancePillars = [
    _PillarSpec(
      code: 'NATURE',
      title: 'Nature & Mangroves',
      subtitle: 'Forêts luxuriantes, bolongs silencieux et réserve d\'oiseaux.',
      asset: 'assets/images/casamance/bolong_mangrove.jpg',
      icon: Icons.forest_rounded,
    ),
    _PillarSpec(
      code: 'PATRIMOINE',
      title: 'Patrimoine & Histoire',
      subtitle: 'Comptoirs fluviaux coloniaux et sanctuaires historiques.',
      asset: 'assets/images/casamance/cathedrale_ziguinchor.jpg',
      icon: Icons.account_balance_rounded,
    ),
    _PillarSpec(
      code: 'ARCHITECTURE',
      title: 'Architecture Diola',
      subtitle: 'Cases à impluvium séculaires et cases à étages en banco.',
      asset: 'assets/images/casamance/cases_mlomp.jpg',
      icon: Icons.villa_rounded,
    ),
    _PillarSpec(
      code: 'MUSEES',
      title: 'Mémoire & Musées',
      subtitle: 'Mémorial Le Joola et transmission des récits casamançais.',
      asset: 'assets/images/casamance/memorial_joola.jpg',
      icon: Icons.museum_rounded,
    ),
    _PillarSpec(
      code: 'PLAGES',
      title: 'Fleuves & Plages Sauvages',
      subtitle: 'Sables dorés bordés de cocotiers et baignades atlantiques.',
      asset: SiteMediaHelper.beachCapSkirringAsset,
      icon: Icons.beach_access_rounded,
    ),
    _PillarSpec(
      code: 'ARTISANAT',
      title: 'Artisanat & Savoir-faire',
      subtitle: 'Sculpture sur bois précieux, vannerie et poterie traditionnelle.',
      asset: SiteMediaHelper.artisanatAsset,
      icon: Icons.handyman_rounded,
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
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        backgroundColor: AppTheme.emeraldGreen,
        content: Text(
          isNow
              ? '${site.nom} ajouté à vos favoris'
              : '${site.nom} retiré de vos favoris',
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
        duration: const Duration(milliseconds: 650),
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
      helpText: 'Date de visite souhaitée',
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
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final bool isDesktop = width >= 980;
    final horizontalPad = width >= 1140 ? 40.0 : (width >= 640 ? 24.0 : 16.0);
    final bg = AppTheme.backgroundOf(context);

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        color: AppTheme.emeraldGreen,
        onRefresh: _loadSites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. HERO SECTION : L'ÉLÉMENT CENTRAL (75-80% VIEWPORT) ──
              _buildHeroSection(size, isDesktop, horizontalPad),

              // ── 2. BARRE DE RECHERCHE FLOTTANTE HARMONIEUSE ──
              _buildFloatingSearchBlock(isDesktop, horizontalPad),

              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    16,
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

              // ── 3. DESTINATIONS : « DES LIEUX QUI MÉRITENT LE DÉTOUR » ──
              _buildMagazineDestinationsSection(horizontalPad, isDesktop),

              // ── 4. L'ÂME DE LA CASAMANCE (6 PILIERS D'EXCEPTION) ──
              _buildSoulOfCasamanceSection(horizontalPad, isDesktop),

              // ── 5. AVIS DES VOYAGEURS D'EXCEPTION ──
              _buildReviewsSection(horizontalPad, isDesktop),

              // ── 6. L'ENGAGEMENT CASAMANCE TOURISME ──
              _buildLuxuryPledgesSection(horizontalPad, isDesktop),

              // ── 7. FOOTER COMPLET & ÉPURÉ ──
              _buildFooter(horizontalPad, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 1. HERO SECTION SPECTACULAIRE (75% VIEWPORT DESKTOP)
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection(
    Size screenSize,
    bool isDesktop,
    double horizontalPad,
  ) {
    final heroHeight = isDesktop
        ? (screenSize.height * 0.76).clamp(580.0, 780.0)
        : (screenSize.height * 0.72).clamp(540.0, 680.0);
    final activeHero = _heroPanoramas[_heroIndex];

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Photographie panoramique immersive & lumineuse ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: Image.asset(
              activeHero['asset']!,
              key: ValueKey<String>(activeHero['asset']!),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // ── Filtre de clarté & dégradé éditorial asymétrique ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.52, 0.95],
                  colors: [
                    Colors.black.withValues(alpha: isDesktop ? 0.68 : 0.58),
                    Colors.black.withValues(alpha: isDesktop ? 0.28 : 0.35),
                    Colors.black.withValues(alpha: 0.10),
                  ],
                ),
              ),
            ),
          ),

          // Dégradé bas doux vers le sable chaud
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.70, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    AppTheme.deepForest.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),

          // ── Composition Asymétrique : Contenu à gauche, respiration à droite ──
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: 24,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // BLOC GAUCHE ÉDITORIAL
                    Expanded(
                      flex: isDesktop ? 6 : 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge « Sénégal • Casamance »
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: AppTheme.goldenSand,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SÉNÉGAL • CASAMANCE',
                                  style: AppTheme.bodyStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Grand titre en Playfair Display
                          Text(
                            'Là où la nature rencontre l\'authenticité.',
                            style: AppTheme.headingStyle(
                              fontSize: isDesktop ? 54 : (screenSize.width >= 600 ? 34 : 28),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.12,
                            ).copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isDesktop ? 16 : 10),

                          // Courte description évocatrice
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 580),
                            child: Text(
                              'Découvrez les trésors cachés de la Casamance, entre fleuves majestueux, patrimoine séculaire et traditions vivantes.',
                              style: AppTheme.bodyStyle(
                                fontSize: isDesktop ? 17 : 13.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.45,
                              ).copyWith(
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 28 : 18),

                          // Boutons d'action éditoriaux
                          Wrap(
                            spacing: 14,
                            runSpacing: 12,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _launchExplorerSearch(resetFilters: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.emeraldGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 26,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 6,
                                  shadowColor:
                                      AppTheme.emeraldGreen.withValues(alpha: 0.45),
                                ),
                                icon: const Icon(Icons.explore_rounded, size: 18),
                                label: Text(
                                  'Explorer la Casamance',
                                  style: AppTheme.bodyStyle(
                                    fontSize: 14,
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
                                      Colors.white.withValues(alpha: 0.14),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    width: 1.4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 17,
                                ),
                                label: Text(
                                  'Les incontournables',
                                  style: AppTheme.bodyStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // BLOC DROIT : Carte flottante destination mise en avant (Desktop uniquement)
                    if (isDesktop) ...[
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _HeroDestinationSpotlightCard(
                            title: activeHero['highlightSite']!,
                            subtitle: activeHero['location']!,
                            detail: activeHero['highlightDist']!,
                            panoramas: _heroPanoramas,
                            currentIndex: _heroIndex,
                            onSelectPanorama: (i) =>
                                setState(() => _heroIndex = i),
                            onTap: () =>
                                _launchExplorerSearch(resetFilters: true),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 2. PANNEAU DE RECHERCHE FLOTTANT COMPACT & HARMONIEUX
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildFloatingSearchBlock(bool isDesktop, double horizontalPad) {
    return Transform.translate(
      offset: Offset(0, isDesktop ? -32 : -20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad),
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 12 : 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radius24),
                border: Border.all(color: AppTheme.borderOf(context), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isDesktop
                  ? _buildDesktopSearchRow()
                  : _buildMobileSearchStack(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSearchRow() {
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    return IntrinsicHeight(
      child: Row(
        children: [
          // 1. Destination
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _launchExplorerSearch(),
              style: AppTheme.bodyStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textCol,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.place_outlined,
                  color: AppTheme.emeraldGreen,
                  size: 20,
                ),
                hintText: 'Destination, lieu (ex: Carabane, Boudody...)',
                hintStyle: AppTheme.bodyStyle(fontSize: 13, color: mutedCol),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
            ),
          ),
          _searchDivider(),

          // 2. Catégorie
          Expanded(
            flex: 2,
            child: _dropdownField(
              icon: Icons.category_outlined,
              label: 'Expérience',
              value: _selectedCategory,
              items: _heroCategories,
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
          ),
          _searchDivider(),

          // 3. Date de visite
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppTheme.radius12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: AppTheme.emeraldGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date de visite',
                            style: AppTheme.bodyStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: mutedCol,
                            ),
                          ),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                                : 'Indifférente',
                            style: AppTheme.bodyStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        color: mutedCol,
                        onPressed: () => setState(() => _selectedDate = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 4. Bouton de Recherche Luxury
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _launchExplorerSearch(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.search_rounded, size: 18),
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

  Widget _buildMobileSearchStack() {
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    return Column(
      children: [
        TextField(
          controller: _searchController,
          onSubmitted: (_) => _launchExplorerSearch(),
          style: AppTheme.bodyStyle(fontSize: 14, color: textCol),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.emeraldGreen,
              size: 20,
            ),
            hintText: 'Rechercher un site, village...',
            hintStyle: AppTheme.bodyStyle(fontSize: 13.5, color: mutedCol),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius12),
              borderSide: BorderSide(color: AppTheme.borderOf(context)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dropdownField(
                icon: Icons.category_outlined,
                label: 'Catégorie',
                value: _selectedCategory,
                items: _heroCategories,
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radius12),
                    border: Border.all(color: AppTheme.borderOf(context)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppTheme.emeraldGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}'
                              : 'Date',
                          style: AppTheme.bodyStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () => _launchExplorerSearch(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
            ),
            icon: const Icon(Icons.search_rounded, size: 18),
            label: Text(
              'Trouver une visite',
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

  Widget _searchDivider() {
    return VerticalDivider(
      width: 20,
      thickness: 1,
      indent: 6,
      endIndent: 6,
      color: AppTheme.borderOf(context),
    );
  }

  Widget _dropdownField({
    required IconData icon,
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: mutedCol, size: 18),
        items: items.map((it) {
          return DropdownMenuItem<String>(
            value: it['code']!,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AppTheme.emeraldGreen),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    it['label']!,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textCol,
                    ),
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
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 3. SECTION DESTINATIONS : « DES LIEUX QUI MÉRITENT LE DÉTOUR » (MAGAZINE)
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildMagazineDestinationsSection(
    double horizontalPad,
    bool isDesktop,
  ) {
    return Container(
      key: _incontournablesKey,
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        isDesktop ? 36 : 24,
        horizontalPad,
        isDesktop ? 48 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre et chapô éditorial
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESTINATIONS D\'EXCEPTION',
                          style: AppTheme.bodyStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.terracotta,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Des lieux qui méritent le détour',
                          style: AppTheme.headingStyle(
                            fontSize: isDesktop ? 34 : 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textOf(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Une sélection minutieuse de joyaux naturels, architecturaux et historiques de la région.',
                          style: AppTheme.bodyStyle(
                            fontSize: 14,
                            color: AppTheme.mutedOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop)
                    TextButton.icon(
                      onPressed: () =>
                          _launchExplorerSearch(resetFilters: true),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppTheme.emeraldGreen,
                      ),
                      label: Text(
                        'Voir le catalogue (${_sites.length})',
                        style: AppTheme.bodyStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.emeraldGreen,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),

              // Grille éditoriale asymétrique
              _buildAsymmetricGrid(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAsymmetricGrid(bool isDesktop) {
    if (_isLoading) {
      return const CasamanceSkeletonCard();
    }

    final sites = _popularSites;
    if (sites.isEmpty) {
      return CasamanceEmptyState(
        icon: Icons.travel_explore_rounded,
        title: 'Aucune destination trouvée',
        subtitle: 'Vérifiez la connexion avec le serveur de données.',
        actionLabel: 'Actualiser',
        onAction: _loadSites,
      );
    }

    final leadSite = sites.first;
    final secondarySites = sites.skip(1).take(2).toList();

    if (isDesktop && secondarySites.length >= 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Grande carte majeure à gauche
          Expanded(
            flex: 6,
            child: _MagazineHeroSiteCard(
              site: leadSite,
              rating: _ratingFor(leadSite),
              reviewCount: _reviewCounts[leadSite.id] ?? 0,
              isFavorite: _favoriteIds.contains(leadSite.id),
              onToggleFavorite: () => _toggleFavorite(leadSite),
              onTap: () => _openSiteDetail(leadSite),
            ),
          ),
          const SizedBox(width: 20),

          // 2. Deux cartes secondaires verticales à droite
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _MagazineCompactSiteCard(
                  site: secondarySites[0],
                  rating: _ratingFor(secondarySites[0]),
                  isFavorite: _favoriteIds.contains(secondarySites[0].id),
                  onToggleFavorite: () =>
                      _toggleFavorite(secondarySites[0]),
                  onTap: () => _openSiteDetail(secondarySites[0]),
                ),
                const SizedBox(height: 20),
                _MagazineCompactSiteCard(
                  site: secondarySites[1],
                  rating: _ratingFor(secondarySites[1]),
                  isFavorite: _favoriteIds.contains(secondarySites[1].id),
                  onToggleFavorite: () =>
                      _toggleFavorite(secondarySites[1]),
                  onTap: () => _openSiteDetail(secondarySites[1]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Version Mobile ou liste réduite
    return Column(
      children: sites.take(3).map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CasamanceSiteCard(
            site: s,
            heroTagPrefix: 'magazine_site',
            isFavorite: _favoriteIds.contains(s.id),
            rating: _ratingFor(s),
            reviewCount: _reviewCounts[s.id] ?? 0,
            onToggleFavorite: () => _toggleFavorite(s),
            onTap: () => _openSiteDetail(s),
          ),
        );
      }).toList(),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 4. SECTION « L'ÂME DE LA CASAMANCE » (6 PILIERS D'EXCEPTION)
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildSoulOfCasamanceSection(double horizontalPad, bool isDesktop) {
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
        isDesktop ? 50 : 36,
        horizontalPad,
        isDesktop ? 56 : 38,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IMMERSION TERRITORIALE',
                style: AppTheme.bodyStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.terracotta,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'L\'âme de la Casamance',
                style: AppTheme.headingStyle(
                  fontSize: isDesktop ? 34 : 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOf(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Explorez les six facettes qui font de cette région l\'un des sanctuaires les plus fascinants d\'Afrique de l\'Ouest.',
                style: AppTheme.bodyStyle(
                  fontSize: 14,
                  color: AppTheme.mutedOf(context),
                ),
              ),
              const SizedBox(height: 28),

              // Grille des piliers
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final int cols = w >= 980 ? 3 : (w >= 620 ? 2 : 1);
                  final rowCount = (_casamancePillars.length / cols).ceil();

                  return Column(
                    children: List.generate(rowCount, (r) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: r < rowCount - 1 ? 20 : 0,
                        ),
                        child: Row(
                          children: List.generate(cols, (c) {
                            final idx = r * cols + c;
                            if (idx >= _casamancePillars.length) {
                              return const Expanded(child: SizedBox.shrink());
                            }
                            final pillar = _casamancePillars[idx];
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 16.0 * c / cols,
                                  right: 16.0 * (cols - 1 - c) / cols,
                                ),
                                child: _LuxuryPillarCard(
                                  pillar: pillar,
                                  onTap: () => MainNavigationShell.switchTab(
                                    context,
                                    MainNavigationShell.tabExplorer,
                                    explorerCategory: pillar.code,
                                  ),
                                ),
                              ),
                            );
                          }),
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

  // ════════════════════════════════════════════════════════════════════════════
  // 5. AVIS DES VOYAGEURS D'EXCEPTION
  // ════════════════════════════════════════════════════════════════════════════

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
        isDesktop ? 48 : 32,
        horizontalPad,
        isDesktop ? 48 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TÉMOIGNAGES',
                style: AppTheme.bodyStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.terracotta,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Avis des visiteurs',
                style: AppTheme.headingStyle(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOf(context),
                ),
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

  // ════════════════════════════════════════════════════════════════════════════
  // 6. L'ENGAGEMENT CASAMANCE TOURISME
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildLuxuryPledgesSection(double horizontalPad, bool isDesktop) {
    const pledges = [
      _PledgeSpec(
        icon: Icons.verified_user_outlined,
        title: 'Authenticité Certifiée',
        description:
            'Partenariat officiel direct avec les conservateurs, guides et communautés locales.',
      ),
      _PledgeSpec(
        icon: Icons.shield_outlined,
        title: 'Voyage d\'Exception',
        description:
            'Des itinéraires respectueux de la nature, des traditions et de l\'hospitalité teranga.',
      ),
      _PledgeSpec(
        icon: Icons.qr_code_2_rounded,
        title: 'Billetterie Dématérialisée',
        description:
            'Accès numériques instantanés utilisables hors-ligne lors de toutes vos traversées.',
      ),
      _PledgeSpec(
        icon: Icons.volunteer_activism_outlined,
        title: 'Impact Éco-responsable',
        description:
            'Chaque visite soutient directement l\'artisanat local et la préservation de la mangrove.',
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
        isDesktop ? 48 : 34,
        horizontalPad,
        isDesktop ? 52 : 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POURQUOI CHOISIR CASAMANCE TOURISME',
                style: AppTheme.bodyStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.terracotta,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'L\'excellence au service de vos découvertes',
                style: AppTheme.headingStyle(
                  fontSize: isDesktop ? 30 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOf(context),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final int cols = w >= 980 ? 4 : (w >= 540 ? 2 : 1);
                  final rowCount = (pledges.length / cols).ceil();

                  return Column(
                    children: List.generate(rowCount, (r) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: r < rowCount - 1 ? 16 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(cols, (c) {
                            final idx = r * cols + c;
                            if (idx >= pledges.length) {
                              return const Expanded(
                                child: SizedBox.shrink(),
                              );
                            }
                            final spec = pledges[idx];
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 16.0 * c / cols,
                                  right: 16.0 * (cols - 1 - c) / cols,
                                ),
                                child: _LuxuryPledgeCard(spec: spec),
                              ),
                            );
                          }),
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

  // ════════════════════════════════════════════════════════════════════════════
  // 7. FOOTER COMPLET & ÉPURÉ
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildFooter(double horizontalPad, bool isDesktop) {
    return Container(
      color: AppTheme.deepForest,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: isDesktop ? 48 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            children: [
              Wrap(
                spacing: 32,
                runSpacing: 24,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.goldenSand.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CASAMANCE TOURISME & VISITES',
                              style: AppTheme.headingStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Plateforme officielle de valorisation et de réservation patrimoniale',
                              style: AppTheme.bodyStyle(
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
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _footerLink(
                        'Accueil',
                        () => MainNavigationShell.switchTab(
                          context,
                          MainNavigationShell.tabAccueil,
                        ),
                      ),
                      _footerLink(
                        'Destinations',
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
              const SizedBox(height: 28),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '© 2026 Casamance Tourisme · UASZ L3-2I (Collé SYLL & Ndeye Thiamba FAYE)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bodyStyle(
                        fontSize: 12,
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
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COMPOSANTS INTERNES LUXURY
// ════════════════════════════════════════════════════════════════════════════

/// Carte flottante de destination mise en avant sur le Hero
class _HeroDestinationSpotlightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String detail;
  final List<Map<String, String>> panoramas;
  final int currentIndex;
  final ValueChanged<int> onSelectPanorama;
  final VoidCallback onTap;

  const _HeroDestinationSpotlightCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.panoramas,
    required this.currentIndex,
    required this.onSelectPanorama,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.radius24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.terracotta,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'EN VEDETTE',
                  style: AppTheme.bodyStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.verified_rounded,
                size: 16,
                color: AppTheme.goldenSand,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTheme.headingStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.bodyStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.directions_boat_filled_rounded,
                size: 14,
                color: AppTheme.goldenSand,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  detail,
                  style: AppTheme.bodyStyle(
                    fontSize: 11.5,
                    color: AppTheme.goldenSand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sélecteur de panoramas miniatures
          Row(
            children: List.generate(panoramas.length, (i) {
              final isSel = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelectPanorama(i),
                  child: Container(
                    height: 44,
                    margin: EdgeInsets.only(right: i < panoramas.length - 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? AppTheme.goldenSand : Colors.white24,
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        panoramas[i]['asset']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Grande carte destination majeure de la grille magazine
class _MagazineHeroSiteCard extends StatelessWidget {
  final Patrimoine site;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _MagazineHeroSiteCard({
    required this.site,
    required this.rating,
    required this.reviewCount,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 430,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius24),
          boxShadow: AppTheme.shadowFor(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SitePhotoView(site: site, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            // Badge catégorie + Bouton favori
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      SiteMediaHelper.labelCategorie(site.categorie),
                      style: AppTheme.bodyStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleFavorite,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                    ),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? AppTheme.terracotta : Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Contenu bas
            Positioned(
              bottom: 22,
              left: 22,
              right: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 18, color: AppTheme.goldenSand),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)}/5',
                        style: AppTheme.bodyStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ' • $reviewCount avis',
                        style: AppTheme.bodyStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    site.nom,
                    style: AppTheme.headingStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 15, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          site.localisation,
                          style: AppTheme.bodyStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    site.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte destination compacte de la grille magazine
class _MagazineCompactSiteCard extends StatelessWidget {
  final Patrimoine site;
  final double rating;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _MagazineCompactSiteCard({
    required this.site,
    required this.rating,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius24),
          boxShadow: AppTheme.shadowFor(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SitePhotoView(site: site, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.40, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.80),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.deepForest.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      SiteMediaHelper.labelCategorie(site.categorie),
                      style: AppTheme.bodyStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? AppTheme.terracotta : Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 14,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.headingStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          site.localisation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodyStyle(
                            fontSize: 11.5,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '★ ${rating.toStringAsFixed(1)}',
                        style: AppTheme.bodyStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.goldenSand,
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
    );
  }
}

/// Carte de pilier d'immersion territoriale (L'Âme de la Casamance)
class _LuxuryPillarCard extends StatelessWidget {
  final _PillarSpec pillar;
  final VoidCallback onTap;

  const _LuxuryPillarCard({required this.pillar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius24),
          boxShadow: AppTheme.shadowFor(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              pillar.asset,
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.40, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 18,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(pillar.icon, color: AppTheme.goldenSand, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    pillar.title,
                    style: AppTheme.headingStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pillar.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'engagement qualité & prestige
class _LuxuryPledgeCard extends StatelessWidget {
  final _PledgeSpec spec;

  const _LuxuryPledgeCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.backgroundOf(context),
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(spec.icon, color: AppTheme.emeraldGreen, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            spec.title,
            style: AppTheme.headingStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            spec.description,
            style: AppTheme.bodyStyle(
              fontSize: 12.5,
              color: AppTheme.mutedOf(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'avis visiteur authentique
class _VisitorReviewCard extends StatelessWidget {
  final Avis avis;

  const _VisitorReviewCard({required this.avis});

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surfaceOf(context);
    final border = AppTheme.borderOf(context);

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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppTheme.paleGreen,
                child: Text(
                  avis.auteur.isNotEmpty ? avis.auteur[0].toUpperCase() : 'V',
                  style: AppTheme.bodyStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.emeraldGreen,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avis.auteur,
                      style: AppTheme.bodyStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textOf(context),
                      ),
                    ),
                    Text(
                      avis.datePublication,
                      style: AppTheme.bodyStyle(
                        fontSize: 11,
                        color: AppTheme.mutedOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: i < avis.note ? AppTheme.goldenSand : Colors.black12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '« ${avis.commentaire} »',
            style: AppTheme.bodyStyle(
              fontSize: 12.5,
              color: AppTheme.textOf(context),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarSpec {
  final String code;
  final String title;
  final String subtitle;
  final String asset;
  final IconData icon;

  const _PillarSpec({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.icon,
  });
}

class _PledgeSpec {
  final IconData icon;
  final String title;
  final String description;

  const _PledgeSpec({
    required this.icon,
    required this.title,
    required this.description,
  });
}
