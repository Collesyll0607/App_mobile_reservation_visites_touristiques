import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/services/favorites_service.dart';
import 'site_detail_screen.dart';

/// Écran dédié : Liste complète des Sites Touristiques avec filtres et tri
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue)
class SitesListScreen extends StatefulWidget {
  final List<Patrimoine> initialSites;
  final String initialCategory;

  const SitesListScreen({
    super.key,
    required this.initialSites,
    this.initialCategory = 'TOUS',
  });

  @override
  State<SitesListScreen> createState() => _SitesListScreenState();
}

class _SitesListScreenState extends State<SitesListScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  Set<int> _favoriteIds = {};
  late String _selectedCategory;
  String _searchQuery = '';
  String _sortBy = 'NOTE';

  final List<Map<String, String>> _categories = const [
    {'code': 'TOUS', 'label': 'Tous'},
    {'code': 'NATURE', 'label': 'Nature'},
    {'code': 'MONUMENT', 'label': 'Culture'},
    {'code': 'MUSEE', 'label': 'Musées'},
    {'code': 'ARCHITECTURE', 'label': 'Traditions'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadFavorites();
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
              ? '${site.nom} ajouté aux favoris (hors-ligne)'
              : '${site.nom} retiré des favoris',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Patrimoine> get _filteredSites {
    final list = widget.initialSites.where((site) {
      final matchesCat =
          _selectedCategory == 'TOUS' || site.categorie == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          site.nom.toLowerCase().contains(q) ||
          site.localisation.toLowerCase().contains(q) ||
          site.description.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    if (_sortBy == 'PRIX_ASC') {
      list.sort((a, b) => a.tarifEntree.compareTo(b.tarifEntree));
    } else {
      list.sort((a, b) => b.noteMoyenne.compareTo(a.noteMoyenne));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sites = _filteredSites;

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          // En-tête vert forêt avec barre de recherche et filtres
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.deepForest,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            'Nos Sites Touristiques',
                            style: AppTheme.editorialTitle(
                              fontSize: 21,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Trier les sites',
                          icon: const Icon(Icons.tune_rounded,
                              color: AppTheme.solarGold),
                          onSelected: (val) => setState(() => _sortBy = val),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'NOTE',
                              child: Text('Trier par meilleure note'),
                            ),
                            PopupMenuItem(
                              value: 'PRIX_ASC',
                              child: Text('Trier par tarif croissant'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un site, un village...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.deepForest),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                            label: Text(cat['label']!),
                            selected: selected,
                            selectedColor: AppTheme.solarGold,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.14),
                            labelStyle: AppTheme.bodyStyle(
                              fontSize: 12.5,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? AppTheme.deepForest
                                  : Colors.white,
                            ),
                            showCheckmark: false,
                            onSelected: (_) => setState(
                                () => _selectedCategory = cat['code']!),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Compteur de résultats
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sites.length} destination${sites.length > 1 ? "s" : ""} trouvée${sites.length > 1 ? "s" : ""}',
                  style: AppTheme.bodyStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  _sortBy == 'PRIX_ASC' ? 'Tarif croissant' : 'Mieux notés',
                  style: AppTheme.bodyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.bolongTurquoise,
                  ),
                ),
              ],
            ),
          ),

          // Liste des cartes
          Expanded(
            child: sites.isEmpty
                ? Center(
                    child: Text(
                      'Aucun site ne correspond à votre recherche.',
                      style: AppTheme.bodyStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: sites.length,
                    itemBuilder: (context, index) {
                      final site = sites[index];
                      final isFav = _favoriteIds.contains(site.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SiteDetailScreen(site: site),
                              ),
                            );
                            _loadFavorites();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    SitePhotoView(
                                      site: site,
                                      width: 112,
                                      height: 102,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.deepForest
                                              .withValues(alpha: 0.85),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${site.tarifEntree.toInt()} F',
                                          style: AppTheme.bodyStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.solarGold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        site.nom,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.editorialTitle(
                                          fontSize: 16.5,
                                          color: AppTheme.deepForest,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14,
                                              color: AppTheme.bolongTurquoise),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              site.localisation,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTheme.bodyStyle(
                                                fontSize: 12,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              size: 17,
                                              color: AppTheme.solarGold),
                                          const SizedBox(width: 4),
                                          Text(
                                            site.noteMoyenne.toString(),
                                            style: AppTheme.bodyStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () =>
                                                _toggleFavorite(site),
                                            icon: Icon(
                                              isFav
                                                  ? Icons.favorite_rounded
                                                  : Icons
                                                      .favorite_border_rounded,
                                              size: 20,
                                              color: isFav
                                                  ? AppTheme.lateriteRed
                                                  : AppTheme.textMuted,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            color: AppTheme.deepForest,
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
