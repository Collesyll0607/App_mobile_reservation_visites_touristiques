import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../catalogue/site_detail_screen.dart';
import 'location_service.dart';

/// Écran de Cartographie & Géolocalisation GPS des Sites Touristiques
/// Responsable : Collé SYLL (Pôle 1 - Module Cartographie & GPS)
class MapExploreScreen extends StatefulWidget {
  const MapExploreScreen({super.key});

  @override
  State<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends State<MapExploreScreen> {
  PointRepereGps _positionActuelle = LocationService.positionsReference.first;

  void _afficherDialogueItineraire(Patrimoine site, double distanceKm) {
    final urlMaps = LocationService.genererLienGoogleMaps(
      departLat: _positionActuelle.latitude,
      departLon: _positionActuelle.longitude,
      destLat: site.latitude,
      destLon: site.longitude,
    );
    final duree = LocationService.estimerTempsTrajet(distanceKm);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Itinéraire vers ${site.nom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Départ : ${_positionActuelle.nom}'),
            const SizedBox(height: 6),
            Text('Arrivée : ${site.localisation}'),
            const Divider(height: 20),
            Text(
              'Distance calculée (Haversine) : $distanceKm km',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Temps de trajet estimé : $duree'),
            const SizedBox(height: 12),
            const Text(
              'Lien Google Maps Directions :',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SelectableText(
              urlMaps,
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: urlMaps));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Lien Google Maps copié dans le presse-papiers')),
              );
            },
            child: const Text('Copier le lien Maps'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SiteDetailScreen(site: site),
                ),
              );
            },
            child: const Text('Voir la fiche du site'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sitesTries = LocationService.trierParProximite(
      sites: ApiConfig.sitesCasamance,
      userLat: _positionActuelle.latitude,
      userLon: _positionActuelle.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Géolocalisation GPS & Proximité'),
      ),
      body: Column(
        children: [
          // Sélecteur de position GPS du touriste
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.my_location, color: Color(0xFF1B5E20), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Ma position GPS actuelle :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PointRepereGps>(
                  initialValue: _positionActuelle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: LocationService.positionsReference.map((pt) {
                    return DropdownMenuItem<PointRepereGps>(
                      value: pt,
                      child: Text(
                        pt.nom,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _positionActuelle = val);
                    }
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  'Coordonnées actives : Lat ${_positionActuelle.latitude.toStringAsFixed(4)}, Lon ${_positionActuelle.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Liste des sites triés du plus proche au plus éloigné
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sitesTries.length,
              itemBuilder: (context, index) {
                final site = sitesTries[index];
                final distKm = LocationService.calculerDistanceKm(
                  lat1: _positionActuelle.latitude,
                  lon1: _positionActuelle.longitude,
                  lat2: site.latitude,
                  lon2: site.longitude,
                );
                final duree = LocationService.estimerTempsTrajet(distKm);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0
                          ? Colors.amber.shade700
                          : const Color(0xFF1B5E20),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      site.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Distance : $distKm km ($duree)\nGPS : ${site.latitude.toStringAsFixed(4)}, ${site.longitude.toStringAsFixed(4)}',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton.icon(
                      onPressed: () =>
                          _afficherDialogueItineraire(site, distKm),
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Trajet'),
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
