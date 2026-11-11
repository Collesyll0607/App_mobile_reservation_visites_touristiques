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

/// Écran Éditorial « Explorez la Casamance » — Refonte Artistique Premium
/// Composition magazine asymétrique sur fond Ivoire Sable (#F4EBDD)
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue)
class SitesListScreen extends StatefulWidget {
  final List<Patrimoine>? initialSites;
  final String initialCategory;
  final String initialQuery;

  const SitesListScreen({
    super.key,
    this.initialSites,
    this.initialCategory = 'TOUS',
    this.initialQuery = '',
  });

  @override
  State<SitesListScreen> createState() => _SitesListScreenState();
}

class _SitesListScreenState extends State<SitesListScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _mosaicSectionKey = GlobalKey();
  late final TextEditingController _searchController;

  List<Patrimoine> _sites = [];
  Set<int> _favoriteIds = {};
  final Map<int, int> _reviewCounts = {};
  final Map<int, double> _reviewRatings = {};

  bool _isLoading = true;
  String? _errorMessage;
  late String _selectedCategory;
  late String _searchQuery;
  String _sortBy = 'NOTE';

  final List<Map<String, dynamic>> _themeArches = const [
    {
      'code': 'TOUS',
      'label': 'Tout voir',
      'asset': SiteMediaHelper.heritageFooterAsset,
      'icon': Icons.explore_outlined,
    },
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

  @override
  void initState() {
    super.initState();
    _selectedCategory = _normalizeCategory(widget.initialCategory);
    _searchQuery = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
    _initData();
  }

  String _normalizeCategory(String raw) {
    switch (raw.toUpperCase()) {
      case 'MONUMENT':
      case 'MUSEE':
      case 'ARCHITECTURE':
        return 'PATRIMOINE';
      default:
        return raw.toUpperCase();
    }
  }

  @override
  void didUpdateWidget(covariant SitesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = _normalizeCategory(widget.initialCategory);
      });
    }
    if (widget.initialQuery != oldWidget.initialQuery) {
      _searchController.text = widget.initialQuery;
      setState(() => _searchQuery = widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
      await _loadSitesFromBackend();
    }
  }

  Future<void> _loadSitesFromBackend() async {
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
              'Serveur backend injoignable. Aperçu hors-ligne actif.');
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

  double _ratingFor(Patrimoine site) =>
      _reviewRatings[site.id] ?? site.noteMoyenne;

  Patrimoine _siteWithLiveRating(Patrimoine site) {
    final live = _ratingFor(site);
    if (live == site.noteMoyenne) return site;
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
      noteMoyenne: live,
    );
  }

  List<Patrimoine> get _filteredSites {
    final list = _sites.where((site) {
      final matchesCat =
          SiteMediaHelper.matchesExplorerTheme(site, _selectedCategory);
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          site.nom.toLowerCase().contains(q) ||
          site.localisation.toLowerCase().contains(q) ||
          site.description.toLowerCase().contains(q) ||
          SiteMediaHelper.labelCategorie(site.categorie)
              .toLowerCase()
              .contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    if (_sortBy == 'PRIX_ASC') {
      list.sort((a, b) => a.tarifEntree.compareTo(b.tarifEntree));
    } else if (_sortBy == 'PRIX_DESC') {
      list.sort((a, b) => b.tarifEntree.compareTo(a.tarifEntree));
    } else {
      list.sort((a, b) => _ratingFor(b).compareTo(_ratingFor(a)));
    }
    return list;
  }

  void _scrollToDestinations() {
    final ctx = _mosaicSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 520),
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

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.ivorySand,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.earthBrown.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trier les destinations',
                style: AppTheme.editorialTitle(
                  fontSize: 21,
                  color: AppTheme.deepForest,
                ),
              ),
              const SizedBox(height: 14),
              _sortOptionTile(
                ctx,
                code: 'NOTE',
                icon: Icons.star_rounded,
                title: 'Coup de cœur & mieux notés',
                subtitle: 'Classement selon les avis des voyageurs',
              ),
              _sortOptionTile(
                ctx,
                code: 'PRIX_ASC',
                icon: Icons.south_east_rounded,
                title: 'Tarifs croissants',
                subtitle: 'Idéal pour les visites accessibles',
              ),
              _sortOptionTile(
                ctx,
                code: 'PRIX_DESC',
                icon: Icons.north_east_rounded,
                title: 'Expériences complètes',
                subtitle: 'Du tarif le plus élevé au plus doux',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sortOptionTile(
    BuildContext ctx, {
    required String code,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final active = _sortBy == code;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: active ? AppTheme.deepForest : AppTheme.warmCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? AppTheme.champagneGold : AppTheme.sandBorder,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: active ? AppTheme.champagneGold : AppTheme.earthBrown,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppTheme.deepForest,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: active
                ? AppTheme.ivorySand.withValues(alpha: 0.82)
                : AppTheme.textMuted,
          ),
        ),
        trailing: active
            ? const Icon(Icons.check_circle_rounded, color: AppTheme.champagneGold)
            : null,
        onTap: () {
          setState(() => _sortBy = code);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sites = _filteredSites;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: RefreshIndicator(
        color: AppTheme.deepForest,
        backgroundColor: AppTheme.ivorySand,
        onRefresh: _loadSitesFromBackend,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. En-tête éditorial fin et respirant sur Ivoire Sable (#F4EBDD)
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      if (canPop) ...[
                        _circleHeaderButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                      ],
                      const CasamanceEmblemMark(size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Casamance Tourisme',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.editorialTitle(
                                fontSize: 17.5,
                                color: AppTheme.deepForest,
                              ),
                            ),
                            Text(
                              'Ziguinchor • Sud du Sénégal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.earthBrown,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _circleHeaderButton(
                        icon: Icons.person_outline_rounded,
                        tooltip: 'Mon compte',
                        onTap: () => MainNavigationShell.switchTab(context, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Section d'introduction panoramique + Barre de recherche verre dépoli chevauchante
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    CasamanceReveal(
                      delayMs: 0,
                      child: SizedBox(
                        height: 272,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                                bottom: Radius.circular(32),
                              ),
                              child: ClipPath(
                                clipper:
                                    const CasamanceBolongWaveClipper(depth: 18),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    const CasamanceAssetPhoto(
                                      assetPath:
                                          SiteMediaHelper.splashRiverAsset,
                                      fit: BoxFit.cover,
                                    ),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          stops: const [0.0, 0.55, 1.0],
                                          colors: [
                                            AppTheme.deepForest
                                                .withValues(alpha: 0.72),
                                            AppTheme.deepForest
                                                .withValues(alpha: 0.42),
                                            AppTheme.earthBrown
                                                .withValues(alpha: 0.76),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(22, 22, 22, 42),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.ivorySand
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.champagneGold
                                            .withValues(alpha: 0.75),
                                      ),
                                    ),
                                    child: Text(
                                      'GUIDE ÉDITORIAL • CASAMANCE',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.ivorySand,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Explorez la\nCasamance',
                                    style: AppTheme.editorialTitle(
                                      fontSize: 33,
                                      color: Colors.white,
                                      height: 1.08,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Entre mangroves, plages sauvages et traditions vivantes, découvrez une destination exceptionnelle.',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.bodyStyle(
                                      fontSize: 12.5,
                                      color: AppTheme.ivorySand
                                          .withValues(alpha: 0.94),
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: _scrollToDestinations,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.champagneGold,
                                      foregroundColor: AppTheme.deepForest,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                    ),
                                    icon: const Text('Découvrir la région'),
                                    label: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Barre de recherche flottante chevauchant le visuel héro
                    Transform.translate(
                      offset: const Offset(0, -24),
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
                                    AppTheme.deepForest.withValues(alpha: 0.14),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    color: AppTheme.deepForest,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Rechercher un site, un village...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppTheme.textMuted,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: AppTheme.earthBrown,
                                      size: 21,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                              color: AppTheme.hibiscusRed,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              Container(
                                height: 26,
                                width: 1,
                                color: AppTheme.sandBorder,
                              ),
                              IconButton(
                                tooltip: 'Trier & Filtrer',
                                onPressed: _openFilterSheet,
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color: _sortBy != 'NOTE'
                                      ? AppTheme.hibiscusRed
                                      : AppTheme.deepForest,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Arches Photographiques des Catégories
            SliverToBoxAdapter(
              child: CasamanceReveal(
                delayMs: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: Row(
                        children: [
                          Text(
                            'Univers de découverte',
                            style: AppTheme.editorialTitle(
                              fontSize: 18.5,
                              color: AppTheme.deepForest,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const CasamanceHibiscusBlossom(
                            size: 18,
                            opacity: 0.75,
                          ),
                          const Spacer(),
                          Text(
                            '${sites.length} escale${sites.length > 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.earthBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 112,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: _themeArches.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 11),
                        itemBuilder: (context, index) {
                          final theme = _themeArches[index];
                          final code = theme['code'] as String;
                          return CasamanceArchCategoryTile(
                            label: theme['label'] as String,
                            assetPath: theme['asset'] as String,
                            icon: theme['icon'] as IconData,
                            selected: _selectedCategory == code,
                            onTap: () =>
                                setState(() => _selectedCategory = code),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Indication contextuelle raffinée pour Plages & Gastronomie
            if (_selectedCategory == 'PLAGES' ||
                _selectedCategory == 'GASTRONOMIE')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.terracottaSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.earthBrown.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedCategory == 'PLAGES'
                              ? Icons.waves_rounded
                              : Icons.restaurant_menu_rounded,
                          color: AppTheme.hibiscusRed,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedCategory == 'PLAGES'
                                ? 'Escales littorales & embarcadères vers Carabane et le littoral de Cap Skirring.'
                                : 'Saveurs authentiques de Casamance autour des quais de Boudody et de Carabane.',
                            style: GoogleFonts.poppins(
                              fontSize: 11.8,
                              color: AppTheme.deepForest,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: CasamanceApiErrorBanner(
                    message: _errorMessage!,
                    onRetry: _loadSitesFromBackend,
                  ),
                ),
              ),

            // Titre de la grille asymétrique
            SliverToBoxAdapter(
              key: _mosaicSectionKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destinations à vivre',
                            style: AppTheme.editorialTitle(
                              fontSize: 22.5,
                              color: AppTheme.deepForest,
                            ),
                          ),
                          Text(
                            'Compositions visuelles & adresses sélectionnées',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Contenu principal : Chargement / État vide / Mosaïque Éditoriale Asymétrique
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.deepForest,
                    ),
                  ),
                ),
              )
            else if (sites.isEmpty)
              SliverToBoxAdapter(
                child: CasamanceEmptyState(
                  icon: Icons.travel_explore_rounded,
                  title: 'Aucune escale trouvée',
                  subtitle:
                      'Modifiez votre recherche ou revenez à toutes les thématiques de Casamance.',
                  actionLabel: 'Réinitialiser',
                  onAction: () {
                    _searchController.clear();
                    setState(() {
                      _selectedCategory = 'TOUS';
                      _searchQuery = '';
                    });
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: SliverToBoxAdapter(
                  child: _EditorialDestinationMosaic(
                    sites: sites.map(_siteWithLiveRating).toList(),
                    favoriteIds: _favoriteIds,
                    reviewCounts: _reviewCounts,
                    onTapSite: _openSiteDetail,
                    onToggleFavorite: _toggleFavorite,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _circleHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Material(
      color: AppTheme.warmCream,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip ?? '',
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.sandBorder),
            ),
            child: Icon(icon, size: 19, color: AppTheme.deepForest),
          ),
        ),
      ),
    );
  }
}

/// Grille éditoriale asymétrique : alterne portrait vertical + pile droite,
/// bannière panoramique pleine largeur et cartes papier/brique en quinconce.
class _EditorialDestinationMosaic extends StatelessWidget {
  final List<Patrimoine> sites;
  final Set<int> favoriteIds;
  final Map<int, int> reviewCounts;
  final ValueChanged<Patrimoine> onTapSite;
  final ValueChanged<Patrimoine> onToggleFavorite;

  const _EditorialDestinationMosaic({
    required this.sites,
    required this.favoriteIds,
    required this.reviewCounts,
    required this.onTapSite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> blocks = [];
    int idx = 0;

    while (idx < sites.length) {
      // Bloc A (Bento Asymétrique : 1 grande carte verticale gauche + 2 cartes empilées droite)
      if (idx + 2 < sites.length) {
        final sLeft = sites[idx];
        final sTopRight = sites[idx + 1];
        final sBottomRight = sites[idx + 2];

        blocks.add(
          CasamanceReveal(
            delayMs: 110,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 330;
                if (narrow) {
                  return Column(
                    children: [
                      _BentoTallCard(
                        site: sLeft,
                        isFavorite: favoriteIds.contains(sLeft.id),
                        height: 260,
                        onTap: () => onTapSite(sLeft),
                        onToggleFavorite: () => onToggleFavorite(sLeft),
                      ),
                      const SizedBox(height: 12),
                      _BentoCompactCard(
                        site: sTopRight,
                        isFavorite: favoriteIds.contains(sTopRight.id),
                        badgeColor: AppTheme.earthBrown,
                        height: 150,
                        onTap: () => onTapSite(sTopRight),
                        onToggleFavorite: () => onToggleFavorite(sTopRight),
                      ),
                      const SizedBox(height: 12),
                      _BentoCompactCard(
                        site: sBottomRight,
                        isFavorite: favoriteIds.contains(sBottomRight.id),
                        badgeColor: AppTheme.hibiscusRed,
                        height: 150,
                        onTap: () => onTapSite(sBottomRight),
                        onToggleFavorite: () => onToggleFavorite(sBottomRight),
                      ),
                    ],
                  );
                }

                return SizedBox(
                  height: 314,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 11,
                        child: _BentoTallCard(
                          site: sLeft,
                          isFavorite: favoriteIds.contains(sLeft.id),
                          height: 314,
                          onTap: () => onTapSite(sLeft),
                          onToggleFavorite: () => onToggleFavorite(sLeft),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            Expanded(
                              child: _BentoCompactCard(
                                site: sTopRight,
                                isFavorite: favoriteIds.contains(sTopRight.id),
                                badgeColor: AppTheme.earthBrown,
                                onTap: () => onTapSite(sTopRight),
                                onToggleFavorite: () =>
                                    onToggleFavorite(sTopRight),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _BentoCompactCard(
                                site: sBottomRight,
                                isFavorite:
                                    favoriteIds.contains(sBottomRight.id),
                                badgeColor: AppTheme.hibiscusRed,
                                onTap: () => onTapSite(sBottomRight),
                                onToggleFavorite: () =>
                                    onToggleFavorite(sBottomRight),
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
        );
        blocks.add(const SizedBox(height: 14));
        idx += 3;
      }

      // Bloc B (Bannière panoramique pleine largeur avec motif tissé diola)
      if (idx < sites.length) {
        final sWide = sites[idx];
        blocks.add(
          CasamanceReveal(
            delayMs: 170,
            child: _PanoramicDestinationBanner(
              site: sWide,
              isFavorite: favoriteIds.contains(sWide.id),
              reviewCount: reviewCounts[sWide.id] ?? 0,
              onTap: () => onTapSite(sWide),
              onToggleFavorite: () => onToggleFavorite(sWide),
            ),
          ),
        );
        blocks.add(const SizedBox(height: 14));
        idx += 1;
      }

      // Bloc C (Mosaïque papier éditoriale en quinconce : 2 cartes contrastées)
      if (idx + 1 < sites.length) {
        final s1 = sites[idx];
        final s2 = sites[idx + 1];
        blocks.add(
          CasamanceReveal(
            delayMs: 220,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 340) {
                  return Column(
                    children: [
                      _PaperMagazineCard(
                        site: s1,
                        isFavorite: favoriteIds.contains(s1.id),
                        warmTint: false,
                        reviewCount: reviewCounts[s1.id] ?? 0,
                        onTap: () => onTapSite(s1),
                        onToggleFavorite: () => onToggleFavorite(s1),
                      ),
                      const SizedBox(height: 12),
                      _PaperMagazineCard(
                        site: s2,
                        isFavorite: favoriteIds.contains(s2.id),
                        warmTint: true,
                        reviewCount: reviewCounts[s2.id] ?? 0,
                        onTap: () => onTapSite(s2),
                        onToggleFavorite: () => onToggleFavorite(s2),
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PaperMagazineCard(
                        site: s1,
                        isFavorite: favoriteIds.contains(s1.id),
                        warmTint: false,
                        reviewCount: reviewCounts[s1.id] ?? 0,
                        onTap: () => onTapSite(s1),
                        onToggleFavorite: () => onToggleFavorite(s1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: _PaperMagazineCard(
                          site: s2,
                          isFavorite: favoriteIds.contains(s2.id),
                          warmTint: true,
                          reviewCount: reviewCounts[s2.id] ?? 0,
                          onTap: () => onTapSite(s2),
                          onToggleFavorite: () => onToggleFavorite(s2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        blocks.add(const SizedBox(height: 14));
        idx += 2;
      } else if (idx < sites.length) {
        final sLast = sites[idx];
        blocks.add(
          CasamanceReveal(
            delayMs: 220,
            child: _PaperMagazineCard(
              site: sLast,
              isFavorite: favoriteIds.contains(sLast.id),
              warmTint: true,
              reviewCount: reviewCounts[sLast.id] ?? 0,
              onTap: () => onTapSite(sLast),
              onToggleFavorite: () => onToggleFavorite(sLast),
            ),
          ),
        );
        idx += 1;
      }
    }

    // Signature florale discrète en pied de mosaïque
    blocks.add(
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CasamanceHibiscusBlossom(size: 20, opacity: 0.45),
            const SizedBox(width: 8),
            Text(
              'Patrimoine vivant de Casamance',
              style: AppTheme.editorialTitle(
                fontSize: 13.5,
                color: AppTheme.earthBrown.withValues(alpha: 0.72),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 8),
            const CasamanceHibiscusBlossom(size: 20, opacity: 0.45),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks,
    );
  }
}

class _BentoTallCard extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _BentoTallCard({
    required this.site,
    required this.isFavorite,
    required this.height,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = site.tarifEntree <= 0;
    final priceText =
        isFree ? 'Accès libre' : '${site.tarifEntree.toInt()} FCFA';

    return SizedBox(
      height: height,
      child: CasamanceInteractiveCard(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'site_photo_explore_${site.id}',
              child: SitePhotoView(site: site, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.16),
                    Colors.transparent,
                    AppTheme.deepForest.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 12,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
                decoration: const BoxDecoration(
                  color: AppTheme.champagneGold,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(9)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppTheme.deepForest,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      site.noteMoyenne.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepForest,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CasamanceFavoriteButton(
                isFavorite: isFavorite,
                onTap: onToggleFavorite,
                size: 34,
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.editorialTitle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    site.localisation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.8,
                      color: AppTheme.ivorySand.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.ivorySand,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priceText,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepForest,
                      ),
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

class _BentoCompactCard extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final Color badgeColor;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _BentoCompactCard({
    required this.site,
    required this.isFavorite,
    required this.badgeColor,
    required this.onTap,
    required this.onToggleFavorite,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = CasamanceInteractiveCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'site_photo_explore_${site.id}',
            child: SitePhotoView(site: site, fit: BoxFit.cover),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.14),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.84),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                SiteMediaHelper.labelCategorie(site.categorie).toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CasamanceFavoriteButton(
              isFavorite: isFavorite,
              onTap: onToggleFavorite,
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
                  site.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.editorialTitle(
                    fontSize: 14.5,
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
                      site.noteMoyenne.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.champagneGold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      site.tarifEntree <= 0
                          ? 'Gratuit'
                          : '${site.tarifEntree.toInt()} F',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ivorySand,
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

    if (height != null) {
      return SizedBox(height: height, child: card);
    }
    return card;
  }
}

class _PanoramicDestinationBanner extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final int reviewCount;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _PanoramicDestinationBanner({
    required this.site,
    required this.isFavorite,
    required this.reviewCount,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = site.tarifEntree <= 0
        ? 'Accès libre'
        : '${site.tarifEntree.toInt()} FCFA';

    return SizedBox(
      height: 172,
      child: CasamanceInteractiveCard(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'site_photo_explore_${site.id}',
              child: SitePhotoView(site: site, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppTheme.deepForest.withValues(alpha: 0.88),
                    AppTheme.bolongTurquoise.withValues(alpha: 0.48),
                    Colors.black.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.ivorySand,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      priceText,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepForest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CasamanceFavoriteButton(
                    isFavorite: isFavorite,
                    onTap: onToggleFavorite,
                    size: 34,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppTheme.champagneGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${site.noteMoyenne.toStringAsFixed(1)} • ${reviewCount > 0 ? "$reviewCount avis" : SiteMediaHelper.labelCategorie(site.categorie)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.champagneGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    site.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.editorialTitle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${site.localisation} • ${site.description}',
                    maxLines: 2,
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
                height: 7,
                color: AppTheme.champagneGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperMagazineCard extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final bool warmTint;
  final int reviewCount;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _PaperMagazineCard({
    required this.site,
    required this.isFavorite,
    required this.warmTint,
    required this.reviewCount,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = warmTint ? AppTheme.terracottaSoft : AppTheme.warmCream;
    final priceText = site.tarifEntree <= 0
        ? 'Gratuit'
        : '${site.tarifEntree.toInt()} FCFA';

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.sandBorder),
        boxShadow: AppTheme.softShadow,
      ),
      child: CasamanceInteractiveCard(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'site_photo_explore_${site.id}',
                  child: SitePhotoView(
                    site: site,
                    width: double.infinity,
                    height: 138,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: warmTint
                          ? AppTheme.earthBrown
                          : AppTheme.deepForest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      SiteMediaHelper.labelCategorie(site.categorie),
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ivorySand,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CasamanceFavoriteButton(
                    isFavorite: isFavorite,
                    onTap: onToggleFavorite,
                    size: 32,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.editorialTitle(
                      fontSize: 15.5,
                      color: AppTheme.deepForest,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppTheme.champagneGold,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        site.noteMoyenne.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepForest,
                        ),
                      ),
                      if (reviewCount > 0)
                        Text(
                          ' ($reviewCount)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        priceText,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.earthBrown,
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
