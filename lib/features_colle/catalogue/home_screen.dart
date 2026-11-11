import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../features_thiamba/services/favorites_service.dart';
import 'patrimoine_service.dart';
import 'site_detail_screen.dart';

/// Écran d'Accueil & Catalogue des Sites Touristiques
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue & API)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  List<Patrimoine> _allSites = ApiConfig.sitesCasamance;
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  bool _fromApiRest = false;

  String _searchQuery = '';
  String _selectedCategory = 'TOUS';
  String _sortBy = 'NOTE'; // NOTE, PRIX_ASC

  final List<String> _categories = [
    'TOUS',
    'MONUMENT',
    'NATURE',
    'MUSEE',
    'ARCHITECTURE',
  ];

  @override
  void initState() {
    super.initState();
    _loadSites();
    _loadFavorites();
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
      final matchesSearch = site.nom
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          site.localisation.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casamance Tourisme & Visites'),
        actions: [
          IconButton(
            tooltip: 'Actualiser depuis l\'API',
            onPressed: () {
              _loadSites();
              _loadFavorites();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bandeau d'état de connexion avec l'API REST Spring Boot
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: _fromApiRest ? Colors.green.shade100 : Colors.amber.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fromApiRest
                      ? '● Connecté au serveur API Spring Boot (ms-patrimoine)'
                      : '● Mode Local (Cache de secours actif)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _fromApiRest
                        ? Colors.green.shade900
                        : Colors.brown.shade800,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'NOTE',
                      child: Text('Tri : Meilleure note',
                          style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'PRIX_ASC',
                      child: Text('Tri : Tarif croissant',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _sortBy = val ?? 'NOTE'),
                ),
              ],
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un site à Ziguinchor, Carabane, Mlomp...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtres par catégorie
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Liste des sites touristiques
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredSites.length,
                    itemBuilder: (context, index) {
                      final site = _filteredSites[index];
                      final isFav = _favoriteIds.contains(site.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      label: Text(
                                        site.categorie,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          site.noteMoyenne.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          tooltip: isFav
                                              ? 'Retirer des favoris'
                                              : 'Ajouter aux favoris',
                                          onPressed: () =>
                                              _toggleFavorite(site),
                                          icon: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFav
                                                ? Colors.redAccent
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  site.nom,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        site.localisation,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  site.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tarif : ${site.tarifEntree.toInt()} FCFA / pers.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                    const Text(
                                      'Détails & Avis →',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                  ],
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
