import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';
import '../../features_thiamba/reservation/booking_form_screen.dart';

/// Écran de Détail d'un Site Touristique
/// Responsable : Collé SYLL (Pôle 1)
class SiteDetailScreen extends StatelessWidget {
  final Patrimoine site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(site.nom),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière / Catégorie
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
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.place, color: Color(0xFF1B5E20)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    site.localisation,
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
            const Divider(height: 32),

            const Text(
              'Description de la visite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(site.description, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 20),

            const Text(
              'Histoire & Valeur Patrimoniale',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(site.historique, style: const TextStyle(fontSize: 15, height: 1.5)),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(site: site),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Réserver'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
