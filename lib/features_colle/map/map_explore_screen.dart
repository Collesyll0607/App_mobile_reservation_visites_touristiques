import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../catalogue/site_detail_screen.dart';

/// Écran de Cartographie & Géolocalisation GPS des Sites Touristiques
/// Responsable : Collé SYLL (Pôle 1)
class MapExploreScreen extends StatelessWidget {
  const MapExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte GPS — Ziguinchor & Casamance'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ApiConfig.sitesCasamance.length,
        itemBuilder: (context, index) {
          final site = ApiConfig.sitesCasamance[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1B5E20),
                child: Icon(Icons.location_on, color: Colors.white),
              ),
              title: Text(site.nom,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'GPS : ${site.latitude.toStringAsFixed(4)}, ${site.longitude.toStringAsFixed(4)}\n${site.localisation}',
              ),
              isThreeLine: true,
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SiteDetailScreen(site: site),
                    ),
                  );
                },
                child: const Text('Itinéraire'),
              ),
            ),
          );
        },
      ),
    );
  }
}
