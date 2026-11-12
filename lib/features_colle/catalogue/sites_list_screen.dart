import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../reviews/reviews_service.dart';
import 'patrimoine_service.dart';
import 'site_detail_screen.dart';

/// Écran « Explorer la Casamance » — Architecture claire, moderne et responsive
/// (Grille 1 colonne sur mobile, 2 colonnes sur tablette, 3 colonnes sur ordinateur)
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
      backgroundColor: AppTheme.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppTheme.maxFormWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Filtres avancés & Tri',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.forestGreen,
                      title: Text(
                        'Accès gratuit uniquement',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: _freeOnly,
                      onChanged: (v) {
                        setSheetState(() => _freeOnly = v);
                        setState(() => _freeOnly = v);
                      },
                    ),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 6),
                    Text(
                      'Trier par',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _sortTile(ctx, 'NOTE', 'Mieux notés en premier'),
                    _sortTile(ctx, 'PRIX_ASC', 'Tarif croissant'),
                    _sortTile(ctx, 'PRIX_DESC', 'Tarif décroissant'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sortTile(BuildContext ctx, String code, String label) {
    final active = _sortBy == code;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        active ? Icons.radio_button_checked : Icons.radio_button_off,
        color: active ? AppTheme.forestGreen : AppTheme.textMuted,
        size: 20,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: AppTheme.textDark,
        ),
      ),
      onTap: () {
        setState(() => _sortBy = code);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sites = _filteredSites;
    final canPop = Navigator.canPop(context);
    final isWide = MediaQuery.sizeOf(context).width >= 640;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // Zone supérieure claire, structurée et aérée (aucun bandeau sombre massif)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.pureWhite,
              border: Border(
                bottom: BorderSide(color: AppTheme.borderLight),
              ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre & sous-titre
                    Row(
                      children: [
                        if (canPop) ...[
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppTheme.textDark,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explorer la Casamance',
                                style: GoogleFonts.poppins(
                                  fontSize: isWide ? 24 : 21,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${sites.length} site${sites.length > 1 ? 's' : ''} touristique${sites.length > 1 ? 's' : ''} disponible${sites.length > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Barre de recherche + Bouton filtres avancés
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: AppTheme.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Rechercher un site, un quartier, un thème...',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AppTheme.textMuted,
                                  size: 20,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: AppTheme.textMuted,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                fillColor: AppTheme.offWhite,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.borderLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.forestGreen,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _openAdvancedFiltersSheet,
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  (_sortBy != 'NOTE' || _freeOnly)
                                      ? Colors.white
                                      : AppTheme.textDark,
                              backgroundColor:
                                  (_sortBy != 'NOTE' || _freeOnly)
                                      ? AppTheme.forestGreen
                                      : AppTheme.pureWhite,
                              side: BorderSide(
                                color: (_sortBy != 'NOTE' || _freeOnly)
                                    ? AppTheme.forestGreen
                                    : AppTheme.borderLight,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: Text(
                              'Filtres',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filtres horizontaux très contrastés et toujours lisibles
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final f = _filters[index];
                          final code = f['code'] as String;
                          final selected = _selectedCategory == code;
                          return InkWell(
                            onTap: () =>
                                setState(() => _selectedCategory = code),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.forestGreen
                                    : AppTheme.pureWhite,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.forestGreen
                                      : AppTheme.borderLight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    f['icon'] as IconData,
                                    size: 15,
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.naturalGreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    f['label'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedLocation != 'TOUTES') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.paleGreen,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.naturalGreen
                                    .withValues(alpha: 0.35),
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
                                Text(
                                  'Lieu : $_selectedLocation',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => setState(
                                      () => _selectedLocation = 'TOUTES'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 15,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          if (_errorMessage != null)
            CasamanceResponsiveContainer(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                12,
                isWide ? 24 : 16,
                0,
              ),
              child: CasamanceApiErrorBanner(
                message: _errorMessage!,
                onRetry: _loadSitesFromBackend,
              ),
            ),

          // Contenu principal : Grille responsive 1 / 2 / 3 colonnes
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.forestGreen,
                    ),
                  )
                : RefreshIndicator(
                    color: AppTheme.forestGreen,
                    onRefresh: _loadSitesFromBackend,
                    child: sites.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 48),
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
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final int cols =
                                  w >= 1024 ? 3 : (w >= 640 ? 2 : 1);
                              final rowCount = (sites.length / cols).ceil();
                              final horizontalPad = w >= 640 ? 24.0 : 16.0;

                              return ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPad,
                                  18,
                                  horizontalPad,
                                  28,
                                ),
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
                                            final itemIndex =
                                                rowIndex * cols + col;
                                            if (itemIndex >= sites.length) {
                                              return const Expanded(
                                                child: SizedBox.shrink(),
                                              );
                                            }
                                            final site = sites[itemIndex];
                                            return Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 18.0 * col / cols,
                                                  right: 18.0 *
                                                      (cols - 1 - col) /
                                                      cols,
                                                ),
                                                child: CasamanceSiteCard(
                                                  site: site,
                                                  heroTagPrefix:
                                                      'site_explore_card',
                                                  isFavorite: _favoriteIds
                                                      .contains(site.id),
                                                  rating: _ratingFor(site),
                                                  reviewCount:
                                                      _reviewCounts[site.id] ??
                                                          0,
                                                  onToggleFavorite: () =>
                                                      _toggleFavorite(site),
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
                                                    _loadFavorites();
                                                    _loadReviewStats();
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
