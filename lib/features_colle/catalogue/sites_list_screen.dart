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

/// Écran Explorer : Recherche avancée, filtres par catégorie, tri et favoris
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

  final List<Map<String, dynamic>> _categories = const [
    {'code': 'TOUS', 'label': 'Tous', 'icon': Icons.apps_rounded},
    {'code': 'NATURE', 'label': 'Nature', 'icon': Icons.eco_outlined},
    {
      'code': 'MONUMENT',
      'label': 'Monuments',
      'icon': Icons.account_balance_outlined
    },
    {'code': 'MUSEE', 'label': 'Musées', 'icon': Icons.museum_outlined},
    {
      'code': 'ARCHITECTURE',
      'label': 'Architecture',
      'icon': Icons.holiday_village_outlined
    },
    {'code': 'CULTURE', 'label': 'Culture', 'icon': Icons.theater_comedy_outlined},
    {'code': 'ARTISANAT', 'label': 'Artisanat', 'icon': Icons.handyman_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _searchQuery = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
    _initData();
  }

  @override
  void didUpdateWidget(covariant SitesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() => _selectedCategory = widget.initialCategory);
    }
    if (widget.initialQuery != oldWidget.initialQuery) {
      _searchController.text = widget.initialQuery;
      setState(() => _searchQuery = widget.initialQuery);
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
              'Serveur backend indisponible. Mode aperçu local affiché.');
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

  List<Patrimoine> get _filteredSites {
    final list = _sites.where((site) {
      final matchesCat = _selectedCategory == 'TOUS' ||
          site.categorie.toUpperCase() == _selectedCategory;
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
      list.sort((a, b) {
        final rateA = _reviewRatings[a.id] ?? a.noteMoyenne;
        final rateB = _reviewRatings[b.id] ?? b.noteMoyenne;
        return rateB.compareTo(rateA);
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sites = _filteredSites;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // En-tête moderne vert forêt
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.forestGreen, AppTheme.naturalGreen],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (canPop)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explorer la Casamance',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${sites.length} site${sites.length > 1 ? 's' : ''} disponible${sites.length > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.86),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PopupMenuButton<String>(
                            tooltip: 'Trier les sites',
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: AppTheme.warmOrange,
                            ),
                            onSelected: (val) => setState(() => _sortBy = val),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'NOTE',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: _sortBy == 'NOTE'
                                          ? AppTheme.warmOrange
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Mieux notés'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'PRIX_ASC',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 18,
                                      color: _sortBy == 'PRIX_ASC'
                                          ? AppTheme.forestGreen
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Prix croissant'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'PRIX_DESC',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      size: 18,
                                      color: _sortBy == 'PRIX_DESC'
                                          ? AppTheme.forestGreen
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Prix décroissant'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Barre de recherche moderne
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un site, un quartier, un thème...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppTheme.forestGreen,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        fillColor: AppTheme.pureWhite,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.warmOrange,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filtres par catégorie
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final selected = _selectedCategory == cat['code'];
                          return ChoiceChip(
                            avatar: Icon(
                              cat['icon'] as IconData,
                              size: 15,
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.9),
                            ),
                            label: Text(cat['label'] as String),
                            selected: selected,
                            selectedColor: AppTheme.warmOrange,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.16),
                            side: BorderSide.none,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: Colors.white,
                            ),
                            showCheckmark: false,
                            onSelected: (_) => setState(
                              () => _selectedCategory = cat['code'] as String,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: CasamanceApiErrorBanner(
                message: _errorMessage!,
                onRetry: _loadSitesFromBackend,
              ),
            ),

          // Contenu liste / chargement / vide
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
                              const SizedBox(height: 50),
                              CasamanceEmptyState(
                                icon: Icons.travel_explore_rounded,
                                title: 'Aucun site trouvé',
                                subtitle:
                                    'Essayez un autre mot-clé ou réinitialisez les filtres de catégorie.',
                                actionLabel: 'Réinitialiser les filtres',
                                onAction: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedCategory = 'TOUS';
                                    _searchQuery = '';
                                  });
                                },
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                            itemCount: sites.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final site = sites[index];
                              final isFav = _favoriteIds.contains(site.id);
                              final rating =
                                  _reviewRatings[site.id] ?? site.noteMoyenne;
                              final reviewCount = _reviewCounts[site.id] ?? 0;

                              return _ExplorerSiteCard(
                                site: site,
                                isFavorite: isFav,
                                rating: rating,
                                reviewCount: reviewCount,
                                onToggleFavorite: () => _toggleFavorite(site),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SiteDetailScreen(site: site),
                                    ),
                                  );
                                  _loadFavorites();
                                  _loadReviewStats();
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

class _ExplorerSiteCard extends StatelessWidget {
  final Patrimoine site;
  final bool isFavorite;
  final double rating;
  final int reviewCount;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _ExplorerSiteCard({
    required this.site,
    required this.isFavorite,
    required this.rating,
    required this.reviewCount,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = site.tarifEntree <= 0;
    final priceText =
        isFree ? 'Gratuit' : '${site.tarifEntree.toStringAsFixed(0)} FCFA';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
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
                      height: 175,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        SiteMediaHelper.labelCategorie(site.categorie),
                        style: GoogleFonts.poppins(
                          color: AppTheme.forestGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CasamanceFavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onToggleFavorite,
                      size: 38,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priceText,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            site.nom,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warmOrange.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: AppTheme.warmOrange,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                ' ($reviewCount)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppTheme.naturalGreen,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            site.localisation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      site.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          site.horairesOuverture,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Voir détails',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.forestGreen,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
