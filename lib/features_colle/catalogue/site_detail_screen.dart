import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../features_thiamba/reservation/booking_form_screen.dart';
import '../../features_thiamba/services/favorites_service.dart';
import '../map/location_service.dart';
import '../map/map_explore_screen.dart';
import '../reviews/reviews_section.dart';

/// Écran de Détail d'un Site Touristique
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue)
class SiteDetailScreen extends StatefulWidget {
  final Patrimoine site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await _favoritesService.isFavorite(widget.site.id);
    if (!mounted) return;
    setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final isNowFavorite =
        await _favoritesService.toggleFavorite(widget.site);
    if (!mounted) return;
    setState(() => _isFavorite = isNowFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite
              ? '${widget.site.nom} ajouté aux favoris (accessible hors-ligne) !'
              : '${widget.site.nom} retiré des favoris.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    final distZiguinchor = LocationService.calculerDistanceKm(
      lat1: 12.5833,
      lon1: -16.2719,
      lat2: site.latitude,
      lon2: site.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(site.nom),
        actions: [
          IconButton(
            tooltip: _isFavorite
                ? 'Retirer des favoris'
                : 'Ajouter aux favoris',
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière Catégorie & Note
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text(site.categorie)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${site.noteMoyenne} / 5',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              site.nom,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.place, color: Color(0xFF1B5E20)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${site.localisation} ($distZiguinchor km du centre de Ziguinchor)',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF1B5E20)),
                const SizedBox(width: 6),
                Text('Horaires : ${site.horairesOuverture}'),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.gps_fixed, color: Color(0xFF1B5E20)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'GPS : Lat ${site.latitude.toStringAsFixed(4)}, Lon ${site.longitude.toStringAsFixed(4)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapExploreScreen(initialSite: site),
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Voir sur la carte & Tracer l\'itinéraire'),
            ),
            const Divider(height: 32),

            const Text(
              'Description de la visite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              site.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),

            const Text(
              'Histoire & Valeur Patrimoniale',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              site.historique,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Tarif et bouton de réservation (Pont vers le Pôle 2 de Ndeye Thiamba)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tarif d\'entrée officiel'),
                      Text(
                        '${site.tarifEntree.toInt()} FCFA / personne',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(site: site),
                        ),
                      );
                      _checkFavorite();
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Réserver'),
                  ),
                ],
              ),
            ),

            const Divider(height: 36),

            // Module 4 de Collé SYLL : Avis & Notes des visiteurs
            ReviewsSection(
              patrimoineId: site.id,
              initialAverage: site.noteMoyenne,
            ),
          ],
        ),
      ),
    );
  }
}
