import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../auth/auth_service.dart';
import 'patrimoine_service.dart';
import 'site_detail_screen.dart';
import 'sites_list_screen.dart';

/// Écran d'Accueil Immersif & Catalogue — Casamance Tourisme
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue & API)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final PageController _bannerController = PageController(viewportFraction: 1.0);

  List<Patrimoine> _allSites = ApiConfig.sitesCasamance;
  Set<int> _favoriteIds = {};
  String? _userFirstName;
  bool _isLoading = true;
  bool _fromApiRest = false;

  String _searchQuery = '';
  String _selectedCategory = 'TOUS';
  String _sortBy = 'NOTE';
  int _bannerIndex = 0;

  final List<Map<String, dynamic>> _categories = const [
    {
      'code': 'TOUS',
      'label': 'Tout voir',
      'icon': Icons.explore_outlined,
    },
    {
      'code': 'NATURE',
      'label': 'Nature',
      'icon': Icons.eco_outlined,
    },
    {
      'code': 'MONUMENT',
      'label': 'Culture',
      'icon': Icons.account_balance_outlined,
    },
    {
      'code': 'MUSEE',
      'label': 'Musées',
      'icon': Icons.museum_outlined,
    },
    {
      'code': 'ARCHITECTURE',
      'label': 'Traditions',
      'icon': Icons.holiday_village_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSites();
    _loadFavorites();
    _loadUserGreeting();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadUserGreeting() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted || user == null) return;
    final first = user.nomComplet.trim().split(' ').first;
    setState(() => _userFirstName = first);
  }

  Future<void> _loadSites() async {
    setState(() => _isLoading = true);
    final result = await PatrimoineService.fetchPatrimoines();
    if (!mounted) return;
    setState(() {
      _allSites = result.sites;
      _fromApiRest = result.fromApiRest;
      _isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final favs = await _favoritesService.loadAll();
    if (!mounted) return;
    setState(() {
      _favoriteIds = favs.map((s) => s.id).toSet();
    });
  }

  Future<void> _toggleFavorite(Patrimoine site) async {
    final isNowFavorite = await _favoritesService.toggleFavorite(site);
    if (!mounted) return;
    setState(() {
      if (isNowFavorite) {
        _favoriteIds.add(site.id);
      } else {
        _favoriteIds.remove(site.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite
              ? '${site.nom} ajouté aux favoris (accessible hors-ligne) !'
              : '${site.nom} retiré des favoris.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Patrimoine> get _filteredSites {
    final list = _allSites.where((site) {
      final matchesCategory =
          _selectedCategory == 'TOUS' || site.categorie == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          site.nom.toLowerCase().contains(q) ||
          site.localisation.toLowerCase().contains(q) ||
          site.description.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();

    if (_sortBy == 'PRIX_ASC') {
      list.sort((a, b) => a.tarifEntree.compareTo(b.tarifEntree));
    } else {
      list.sort((a, b) => b.noteMoyenne.compareTo(a.noteMoyenne));
    }
    return list;
  }

  void _openAllSitesScreen([String? category]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SitesListScreen(
          initialSites: _allSites,
          initialCategory: category ?? _selectedCategory,
        ),
      ),
    ).then((_) => _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    final sites = _filteredSites;
    final featuredSites = _allSites.take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: RefreshIndicator(
        color: AppTheme.deepForest,
        onRefresh: () async {
          await _loadSites();
          await _loadFavorites();
          await _loadUserGreeting();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. GRAND EN-TÊTE VERT FORÊT COURBÉ
              CasamanceCurvedHeader(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre supérieure : localisation + statut API + actualiser
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppTheme.solarGold, size: 15),
                              const SizedBox(width: 5),
                              Text(
                                'Casamance, Sénégal',
                                style: AppTheme.bodyStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: _fromApiRest
                              ? 'Synchronisé avec MySQL (ms-patrimoine)'
                              : 'Mode cache hors-ligne actif',
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _fromApiRest
                                  ? const Color(0xFF4ADE80)
                                  : AppTheme.solarGold,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  width: 1.5),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Actualiser depuis MySQL',
                          onPressed: () {
                            _loadSites();
                            _loadFavorites();
                          },
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Titre éditorial personnalisé
                    Text(
                      _userFirstName != null
                          ? 'Bienvenue à\nZiguinchor, $_userFirstName !'
                          : 'Bienvenue\nen Casamance !',
                      style: AppTheme.editorialTitle(
                        fontSize: 28,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Une terre d\'histoire, de nature et de culture à réserver.',
                      style: AppTheme.bodyStyle(
                        fontSize: 13,
                        color: AppTheme.ivorySand.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Barre de recherche élégante
                    TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText:
                            'Rechercher un site (Carabane, Mlomp, Joola...)',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppTheme.deepForest),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. GRANDE BANNIÈRE IMMERSIVE (CARROUSEL)
              if (_searchQuery.isEmpty && featuredSites.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: SizedBox(
                    height: 205,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: featuredSites.length,
                      onPageChanged: (idx) =>
                          setState(() => _bannerIndex = idx),
                      itemBuilder: (context, index) {
                        final site = featuredSites[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SiteDetailScreen(site: site),
                              ),
                            );
                            _loadFavorites();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  SitePhotoView(site: site),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.12),
                                          Colors.black.withValues(alpha: 0.72),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 14,
                                    left: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.deepForest
                                            .withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_awesome,
                                              size: 13,
                                              color: AppTheme.solarGold),
                                          const SizedBox(width: 5),
                                          Text(
                                            'À découvrir',
                                            style: AppTheme.bodyStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 14,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
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
                                                '${site.localisation} • ${site.tarifEntree.toInt()} FCFA',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTheme.bodyStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.ivorySand,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.solarGold,
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Découvrir',
                                                style: AppTheme.bodyStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.deepForest,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_forward,
                                                  size: 14,
                                                  color: AppTheme.deepForest),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Indicateurs du carrousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(featuredSites.length, (idx) {
                    final active = _bannerIndex == idx;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      width: active ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.deepForest
                            : AppTheme.deepForest.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
              ],

              // 3. SECTION CATÉGORIES
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catégories',
                      style: AppTheme.editorialTitle(
                        fontSize: 21,
                        color: AppTheme.deepForest,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openAllSitesScreen(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Voir tout',
                            style: AppTheme.bodyStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.bolongTurquoise,
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 18, color: AppTheme.bolongTurquoise),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 98,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['code'];

                    return GestureDetector(
                      onTap: () => setState(
                          () => _selectedCategory = cat['code'] as String),
                      child: SizedBox(
                        width: 78,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.deepForest
                                    : AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.solarGold
                                      : AppTheme.deepForest
                                          .withValues(alpha: 0.10),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                size: 28,
                                color: isSelected
                                    ? AppTheme.solarGold
                                    : AppTheme.deepForest,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['label'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.bodyStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.deepForest
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 4. SECTION DESTINATIONS POPULAIRES / SITES FILTRÉS
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory == 'TOUS'
                          ? 'Sites populaires'
                          : SiteMediaHelper.labelCategorie(_selectedCategory),
                      style: AppTheme.editorialTitle(
                        fontSize: 21,
                        color: AppTheme.deepForest,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: AppTheme.deepForest),
                        items: [
                          DropdownMenuItem(
                            value: 'NOTE',
                            child: Text('Meilleure note',
                                style: AppTheme.bodyStyle(fontSize: 11.5)),
                          ),
                          DropdownMenuItem(
                            value: 'PRIX_ASC',
                            child: Text('Tarif croissant',
                                style: AppTheme.bodyStyle(fontSize: 11.5)),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _sortBy = val ?? 'NOTE'),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (sites.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Aucun site trouvé pour cette recherche.',
                      style: AppTheme.bodyStyle(color: AppTheme.textMuted),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    final isFav = _favoriteIds.contains(site.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SiteDetailScreen(site: site),
                            ),
                          );
                          _loadFavorites();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo du site avec badges note + favoris
                            Stack(
                              children: [
                                SitePhotoView(
                                  site: site,
                                  width: double.infinity,
                                  height: 165,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(22),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.deepForest
                                          .withValues(alpha: 0.88),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      SiteMediaHelper.labelCategorie(
                                          site.categorie),
                                      style: AppTheme.bodyStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.ivorySand,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      tooltip: isFav
                                          ? 'Retirer des favoris'
                                          : 'Ajouter aux favoris',
                                      onPressed: () => _toggleFavorite(site),
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: isFav
                                            ? AppTheme.lateriteRed
                                            : AppTheme.deepForest,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          site.nom,
                                          style: AppTheme.editorialTitle(
                                            fontSize: 19,
                                            color: AppTheme.deepForest,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.solarGold
                                              .withValues(alpha: 0.22),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                color: AppTheme.solarGold,
                                                size: 16),
                                            const SizedBox(width: 3),
                                            Text(
                                              site.noteMoyenne.toString(),
                                              style: AppTheme.bodyStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 15,
                                          color: AppTheme.bolongTurquoise),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          site.localisation,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.bodyStyle(
                                            fontSize: 12.5,
                                            color: AppTheme.textMuted,
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
                                    style: AppTheme.bodyStyle(
                                      fontSize: 13,
                                      color: AppTheme.textDark
                                          .withValues(alpha: 0.85),
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'À partir de',
                                            style: AppTheme.bodyStyle(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          Text(
                                            '${site.tarifEntree.toInt()} FCFA / pers.',
                                            style: AppTheme.bodyStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.deepForest,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 9),
                                        decoration: BoxDecoration(
                                          color: AppTheme.deepForest,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Explorer',
                                              style: AppTheme.bodyStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 15,
                                              color: AppTheme.solarGold,
                                            ),
                                          ],
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
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
