import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../features_colle/catalogue/site_detail_screen.dart';

/// Écran des Sites Favoris Sauvegardés en Mode Hors-Ligne
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoris = ApiConfig.sitesCasamance.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris (Hors-Ligne)'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoris.length,
        itemBuilder: (context, index) {
          final site = favoris[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: Text(
                site.nom,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(site.localisation),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SiteDetailScreen(site: site),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
