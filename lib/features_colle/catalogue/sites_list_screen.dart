import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../reviews/reviews_service.dart';
import 'patrimoine_service.dart';
import 'site_detail_screen.dart';

/// Écran « Explorer la Casamance » — Design System v2
/// Typographie Fraunces + Plus Jakarta Sans, dark-aware, skeleton loaders
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue)
class SitesListScreen extends StatefulWidget {
  final List<Patrimoine>? initialSites;
  final String initialCategory;
  final String initialQuery;
  final String initialLocation;

  const SitesListScreen({
    super.key,
    this.initialSites,
    this.initialCategory = 'TOUS',
    this.initialQuery = '',
    this.initialLocation = 'TOUTES',
  });

  @override
  State<SitesListScreen> createState() => _SitesListScreenState();
}

class _SitesListScreenState extends State<SitesListScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  late final TextEditingController _searchController;

  List<Patrimoine> _sites = [];
  Set<int> _favoriteIds = {};
  final Map<int, int> _reviewCounts = {};
  final Map<int, double> _reviewRatings = {};

  bool _isLoading = true;
  String? _errorMessage;
  late String _selectedCategory;
  late String _searchQuery;
  late String _selectedLocation;
  String _sortBy = 'NOTE';
  bool _freeOnly = false;

  static const List<Map<String, dynamic>> _filters = [
    {'code': 'TOUS', 'label': 'Tous', 'icon': Icons.apps_rounded},
    {'code': 'NATURE', 'label': 'Nature', 'icon': Icons.eco_outlined},
    {
      'code': 'PATRIMOINE',
      'label': 'Patrimoine',
      'icon': Icons.account_balance_outlined
    },
    {
      'code': 'ARCHITECTURE',
      'label': 'Architecture',
      'icon': Icons.holiday_village_outlined
    },
    {'code': 'MUSEE', 'label': 'Musées', 'icon': Icons.museum_outlined},
    {'code': 'PLAGES', 'label': 'Plages', 'icon': Icons.beach_access_outlined},
    {
      'code': 'ARTISANAT',
      'label': 'Artisanat',
      'icon': Icons.handyman_outlined
    },
    {
      'code': 'CULTURE',
      'label': 'Culture',
      'icon': Icons.theater_comedy_outlined
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _normalizeFilter(widget.initialCategory);
    _searchQuery = widget.initialQuery;
    _selectedLocation = widget.initialLocation;
    _searchController = TextEditingController(text: widget.initialQuery);
    _initData();
  }

  String _normalizeFilter(String raw) {
    final up = raw.toUpperCase();
    if (up == 'MONUMENT') return 'PATRIMOINE';
    if (up == 'MUSEES' || up == 'MUSÉES' || up == 'MUSÉE') return 'MUSEE';
    return up;
  }

  @override
  void didUpdateWidget(covariant SitesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = _normalizeFilter(widget.initialCategory);
      });
    }
    if (widget.initialQuery != oldWidget.initialQuery) {
      _searchController.text = widget.initialQuery;
      setState(() => _searchQuery = widget.initialQuery);
    }
    if (widget.initialLocation != oldWidget.initialLocation) {
      setState(() => _selectedLocation = widget.initialLocation);
    }
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
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        backgroundColor: AppTheme.forestGreen,
        content: Row(
          children: [
            Icon(
              isNow ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isNow
                    ? '${site.nom} ajouté aux favoris'
                    : '${site.nom} retiré des favoris',
                style: AppTheme.bodyStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double _ratingFor(Patrimoine site) =>
      _reviewRatings[site.id] ?? site.noteMoyenne;

  bool _matchesCategory(Patrimoine site, String filterCode) {
    return SiteMediaHelper.matchesExplorerTheme(site, filterCode);
  }

  List<Patrimoine> get _filteredSites {
    final loc = _selectedLocation.trim().toLowerCase();
    final list = _sites.where((site) {
      final matchesCat = _matchesCategory(site, _selectedCategory);
      final matchesFree = !_freeOnly || site.tarifEntree <= 0;
      final matchesLoc = _selectedLocation == 'TOUTES' ||
          loc.isEmpty ||
          site.localisation.toLowerCase().contains(loc) ||
          site.nom.toLowerCase().contains(loc) ||
          site.description.toLowerCase().contains(loc);
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          site.nom.toLowerCase().contains(q) ||
          site.localisation.toLowerCase().contains(q) ||
          site.description.toLowerCase().contains(q) ||
          site.categorie.toLowerCase().contains(q);
      return matchesCat && matchesFree && matchesLoc && matchesSearch;
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

  void _openAdvancedFiltersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius24),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final surface = AppTheme.surfaceOf(context);
            final border = AppTheme.borderOf(context);
            final textCol = AppTheme.textOf(context);
            final mutedCol = AppTheme.mutedOf(context);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppTheme.maxFormWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poignée
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Titre
                    Text(
                      'Filtres & Tri',
                      style: AppTheme.headingStyle(
                        fontSize: 20,
                        color: textCol,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Accès gratuit
                    _FilterSwitchTile(
                      label: 'Accès gratuit uniquement',
                      icon: Icons.money_off_rounded,
                      value: _freeOnly,
                      activeColor: AppTheme.forestGreen,
                      surface: surface,
                      border: border,
                      textColor: textCol,
                      onChanged: (v) {
                        setSheetState(() => _freeOnly = v);
                        setState(() => _freeOnly = v);
                      },
                    ),
                    const SizedBox(height: 20),

                    Divider(color: border, height: 1),
                    const SizedBox(height: 16),

                    Text(
                      'Trier par',
                      style: AppTheme.bodyStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mutedCol,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _SortOptionTile(
                      code: 'NOTE',
                      label: 'Mieux notés en premier',
                      icon: Icons.star_rounded,
                      selected: _sortBy == 'NOTE',
                      textColor: textCol,
                      onTap: () {
                        setState(() => _sortBy = 'NOTE');
                        Navigator.pop(ctx);
                      },
                    ),
                    _SortOptionTile(
                      code: 'PRIX_ASC',
                      label: 'Tarif croissant',
                      icon: Icons.trending_up_rounded,
                      selected: _sortBy == 'PRIX_ASC',
                      textColor: textCol,
                      onTap: () {
                        setState(() => _sortBy = 'PRIX_ASC');
                        Navigator.pop(ctx);
                      },
                    ),
                    _SortOptionTile(
                      code: 'PRIX_DESC',
                      label: 'Tarif décroissant',
                      icon: Icons.trending_down_rounded,
                      selected: _sortBy == 'PRIX_DESC',
                      textColor: textCol,
                      onTap: () {
                        setState(() => _sortBy = 'PRIX_DESC');
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sites = _filteredSites;
    final canPop = Navigator.canPop(context);
    final isWide = MediaQuery.sizeOf(context).width >= 640;
    final surface = AppTheme.surfaceOf(context);
    final background = AppTheme.backgroundOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);
    final hasActiveFilters = _sortBy != 'NOTE' || _freeOnly;

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────────────
          _ExplorerHeader(
            canPop: canPop,
            isWide: isWide,
            surface: surface,
            border: border,
            textCol: textCol,
            mutedCol: mutedCol,
            siteCount: _isLoading ? null : sites.length,
            searchController: _searchController,
            searchQuery: _searchQuery,
            hasActiveFilters: hasActiveFilters,
            selectedCategory: _selectedCategory,
            selectedLocation: _selectedLocation,
            filters: _filters,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onSearchCleared: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onOpenFilters: _openAdvancedFiltersSheet,
            onCategorySelected: (code) =>
                setState(() => _selectedCategory = code),
            onLocationCleared: () =>
                setState(() => _selectedLocation = 'TOUTES'),
          ),

          // ── BANNIÈRE D'ERREUR ───────────────────────────────────────────
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 12, isWide ? 24 : 16, 0),
              child: CasamanceApiErrorBanner(
                message: _errorMessage!,
                onRetry: _loadSitesFromBackend,
              ),
            ),

          // ── GRILLE PRINCIPALE ───────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? _ExplorerSkeletonGrid(isWide: isWide)
                : RefreshIndicator(
                    color: AppTheme.forestGreen,
                    backgroundColor: surface,
                    onRefresh: _loadSitesFromBackend,
                    child: sites.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 56),
                              CasamanceEmptyState(
                                icon: Icons.travel_explore_rounded,
                                title: 'Aucun site trouvé',
                                subtitle:
                                    'Essayez un autre mot-clé ou réinitialisez vos filtres.',
                                actionLabel: 'Réinitialiser les filtres',
                                onAction: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedCategory = 'TOUS';
                                    _selectedLocation = 'TOUTES';
                                    _searchQuery = '';
                                    _freeOnly = false;
                                  });
                                },
                              ),
                            ],
                          )
                        : _ExplorerSiteGrid(
                            sites: sites,
                            favoriteIds: _favoriteIds,
                            reviewCounts: _reviewCounts,
                            isWide: isWide,
                            ratingFor: _ratingFor,
                            onToggleFavorite: _toggleFavorite,
                            onLoadFavorites: _loadFavorites,
                            onLoadReviews: _loadReviewStats,
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HEADER — Titre, Recherche, Chips de filtres
// ════════════════════════════════════════════════════════════════════════════

class _ExplorerHeader extends StatelessWidget {
  final bool canPop;
  final bool isWide;
  final Color surface;
  final Color border;
  final Color textCol;
  final Color mutedCol;
  final int? siteCount;
  final TextEditingController searchController;
  final String searchQuery;
  final bool hasActiveFilters;
  final String selectedCategory;
  final String selectedLocation;
  final List<Map<String, dynamic>> filters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final VoidCallback onOpenFilters;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onLocationCleared;

  const _ExplorerHeader({
    required this.canPop,
    required this.isWide,
    required this.surface,
    required this.border,
    required this.textCol,
    required this.mutedCol,
    required this.siteCount,
    required this.searchController,
    required this.searchQuery,
    required this.hasActiveFilters,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.filters,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onOpenFilters,
    required this.onCategorySelected,
    required this.onLocationCleared,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = isWide ? 24.0 : 16.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre & sous-titre
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (canPop) ...[
                        Material(
                          color: Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radius12),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radius12),
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: textCol,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explorer la Casamance',
                              style: AppTheme.headingStyle(
                                fontSize: isWide ? 26 : 22,
                                color: textCol,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: siteCount == null
                                  ? Text(
                                      'Chargement des sites…',
                                      key: const ValueKey('loading'),
                                      style: AppTheme.bodyStyle(
                                        fontSize: 13,
                                        color: mutedCol,
                                      ),
                                    )
                                  : Text(
                                      '$siteCount site${siteCount! > 1 ? 's' : ''} '
                                      'touristique${siteCount! > 1 ? 's' : ''} disponible${siteCount! > 1 ? 's' : ''}',
                                      key: const ValueKey('count'),
                                      style: AppTheme.bodyStyle(
                                        fontSize: 13,
                                        color: mutedCol,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Barre de recherche + bouton filtres
                  Row(
                    children: [
                      Expanded(
                        child: _SearchField(
                          controller: searchController,
                          query: searchQuery,
                          border: border,
                          onChanged: onSearchChanged,
                          onCleared: onSearchCleared,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _FiltersButton(
                        isActive: hasActiveFilters,
                        onPressed: onOpenFilters,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pills de catégories
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final f = filters[i];
                        final code = f['code'] as String;
                        final selected = selectedCategory == code;
                        return _CategoryChip(
                          label: f['label'] as String,
                          icon: f['icon'] as IconData,
                          selected: selected,
                          onTap: () => onCategorySelected(code),
                        );
                      },
                    ),
                  ),

                  // Badge lieu actif
                  if (selectedLocation != 'TOUTES') ...[
                    const SizedBox(height: 10),
                    _LocationBadge(
                      location: selectedLocation,
                      onClear: onLocationCleared,
                    ),
                  ],
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COMPOSANTS INTERNES — Header
// ════════════════════════════════════════════════════════════════════════════

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final Color border;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  const _SearchField({
    required this.controller,
    required this.query,
    required this.border,
    required this.onChanged,
    required this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    final background = AppTheme.backgroundOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.bodyStyle(fontSize: 14, color: textCol),
        decoration: InputDecoration(
          hintText: 'Site, quartier, thème…',
          hintStyle: AppTheme.bodyStyle(fontSize: 14, color: mutedCol),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: mutedCol,
            size: 20,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: mutedCol),
                  onPressed: onCleared,
                )
              : null,
          fillColor: background,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            borderSide:
                const BorderSide(color: AppTheme.forestGreen, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const _FiltersButton({required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          boxShadow: isActive ? AppTheme.softShadow : [],
        ),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isActive ? Colors.white : AppTheme.textDark,
            backgroundColor: isActive ? AppTheme.forestGreen : AppTheme.surfaceOf(context),
            side: BorderSide(
              color: isActive ? AppTheme.forestGreen : AppTheme.borderOf(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
          ),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: Text(
            'Filtres',
            style: AppTheme.bodyStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.textOf(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surfaceOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.forestGreen : surface,
          borderRadius: BorderRadius.circular(AppTheme.radius24),
          border: Border.all(
            color: selected ? AppTheme.forestGreen : border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? AppTheme.softShadow : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : AppTheme.naturalGreen,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.bodyStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationBadge extends StatelessWidget {
  final String location;
  final VoidCallback onClear;

  const _LocationBadge({required this.location, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.paleGreen,
        borderRadius: BorderRadius.circular(AppTheme.radius24),
        border: Border.all(
          color: AppTheme.naturalGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 14,
            color: AppTheme.forestGreen,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Lieu : $location',
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodyStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.forestGreen,
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(
              Icons.close_rounded,
              size: 15,
              color: AppTheme.forestGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SKELETON LOADER — Pendant le chargement
// ════════════════════════════════════════════════════════════════════════════

class _ExplorerSkeletonGrid extends StatelessWidget {
  final bool isWide;

  const _ExplorerSkeletonGrid({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final hPad = isWide ? 24.0 : 16.0;
    final cols = MediaQuery.sizeOf(context).width >= 1024
        ? 3
        : (MediaQuery.sizeOf(context).width >= 640 ? 2 : 1);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: cols == 1 ? 1.6 : 0.78,
            ),
            itemCount: cols * 2,
            itemBuilder: (_, __) => const CasamanceSkeletonCard(),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// GRILLE DE SITES
// ════════════════════════════════════════════════════════════════════════════

class _ExplorerSiteGrid extends StatelessWidget {
  final List<Patrimoine> sites;
  final Set<int> favoriteIds;
  final Map<int, int> reviewCounts;
  final bool isWide;
  final double Function(Patrimoine) ratingFor;
  final Future<void> Function(Patrimoine) onToggleFavorite;
  final Future<void> Function() onLoadFavorites;
  final Future<void> Function() onLoadReviews;

  const _ExplorerSiteGrid({
    required this.sites,
    required this.favoriteIds,
    required this.reviewCounts,
    required this.isWide,
    required this.ratingFor,
    required this.onToggleFavorite,
    required this.onLoadFavorites,
    required this.onLoadReviews,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = isWide ? 24.0 : 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final int cols = w >= 1024 ? 3 : (w >= 640 ? 2 : 1);
        final rowCount = (sites.length / cols).ceil();

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
          itemCount: rowCount,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, rowIndex) {
            return Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
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
                            left: 18.0 * col / cols,
                            right: 18.0 * (cols - 1 - col) / cols,
                          ),
                          child: CasamanceSiteCard(
                            site: site,
                            heroTagPrefix: 'site_explore_card',
                            isFavorite: favoriteIds.contains(site.id),
                            rating: ratingFor(site),
                            reviewCount: reviewCounts[site.id] ?? 0,
                            onToggleFavorite: () => onToggleFavorite(site),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 280),
                                  pageBuilder: (_, anim, __) =>
                                      FadeTransition(
                                    opacity: anim,
                                    child: SiteDetailScreen(site: site),
                                  ),
                                ),
                              );
                              onLoadFavorites();
                              onLoadReviews();
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
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COMPOSANTS DU BOTTOM SHEET FILTRES
// ════════════════════════════════════════════════════════════════════════════

class _FilterSwitchTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final Color activeColor;
  final Color surface;
  final Color border;
  final Color textColor;
  final ValueChanged<bool> onChanged;

  const _FilterSwitchTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.activeColor,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? AppTheme.paleGreen.withValues(alpha: 0.6)
            : surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(
          color: value ? AppTheme.forestGreen.withValues(alpha: 0.4) : border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: value ? activeColor : AppTheme.naturalGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String code;
  final String label;
  final IconData icon;
  final bool selected;
  final Color textColor;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.code,
    required this.label,
    required this.icon,
    required this.selected,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.forestGreen.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radius12),
              border: Border.all(
                color: selected
                    ? AppTheme.forestGreen.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? AppTheme.forestGreen
                      : AppTheme.mutedOf(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.bodyStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? AppTheme.forestGreen : textColor,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppTheme.forestGreen,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
