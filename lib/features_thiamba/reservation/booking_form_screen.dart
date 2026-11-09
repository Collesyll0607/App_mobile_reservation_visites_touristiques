import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../core/models/reservation.dart';
import '../../core/models/utilisateur.dart';
import '../ticketing/ticket_qr_screen.dart';

/// Écran du Formulaire de Réservation d'une Visite Touristique
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)
class BookingFormScreen extends StatefulWidget {
  final Patrimoine site;

  const BookingFormScreen({super.key, required this.site});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  String _selectedSlot = '09h00 - 11h00';
  int _nombrePersonnes = 2;
  Utilisateur? _selectedGuide;
  String _modePaiement = 'WAVE';

  double get _montantTotal {
    final totalEntrees = widget.site.tarifEntree * _nombrePersonnes;
    final tarifGuide = _selectedGuide?.tarifGuideJournalier ?? 0;
    return totalEntrees + tarifGuide;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une Visite'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.site.nom,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 1. Sélection de la date
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.calendar_today, color: Color(0xFF1B5E20)),
              title: const Text('Date de la visite'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: const Text('Modifier'),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Créneau horaire
            DropdownButtonFormField<String>(
              initialValue: _selectedSlot,
              decoration: const InputDecoration(
                labelText: 'Créneau horaire',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(
                    value: '09h00 - 11h00', child: Text('Matin (09h00 - 11h00)')),
                DropdownMenuItem(
                    value: '11h30 - 13h30', child: Text('Midi (11h30 - 13h30)')),
                DropdownMenuItem(
                    value: '15h00 - 17h30',
                    child: Text('Après-midi (15h00 - 17h30)')),
              ],
              onChanged: (val) =>
                  setState(() => _selectedSlot = val ?? '09h00 - 11h00'),
            ),
            const SizedBox(height: 14),

            // 3. Nombre de visiteurs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nombre de participants :',
                    style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _nombrePersonnes > 1
                          ? () => setState(() => _nombrePersonnes--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_nombrePersonnes',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _nombrePersonnes++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Sélection d'un guide touristique (Optionnel)
            DropdownButtonFormField<Utilisateur?>(
              initialValue: _selectedGuide,
              decoration: const InputDecoration(
                labelText: 'Accompagnement par un Guide Touristique',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem<Utilisateur?>(
                  value: null,
                  child: Text('Visite libre (Sans guide)'),
                ),
                ...ApiConfig.guidesDisponibles.map(
                  (g) => DropdownMenuItem<Utilisateur?>(
                    value: g,
                    child: Text(
                        '${g.nomComplet} (+${g.tarifGuideJournalier!.toInt()} FCFA)'),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _selectedGuide = val),
            ),
            const SizedBox(height: 14),

            // 5. Mode de paiement
            DropdownButtonFormField<String>(
              initialValue: _modePaiement,
              decoration: const InputDecoration(
                labelText: 'Moyen de paiement',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'WAVE', child: Text('Wave Mobile Money')),
                DropdownMenuItem(
                    value: 'ORANGE_MONEY', child: Text('Orange Money')),
                DropdownMenuItem(
                    value: 'SUR_PLACE', child: Text('Paiement au guichet')),
              ],
              onChanged: (val) => setState(() => _modePaiement = val ?? 'WAVE'),
            ),
            const SizedBox(height: 24),

            // Récapitulatif du tarif
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Montant Total :',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_montantTotal.toInt()} FCFA',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                final nouvelleReservation = Reservation(
                  id: DateTime.now().millisecondsSinceEpoch % 10000,
                  patrimoineId: widget.site.id,
                  nomPatrimoine: widget.site.nom,
                  nomTouriste: 'Touriste Visiteur',
                  dateVisite:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  creneauHoraire: _selectedSlot,
                  nombrePersonnes: _nombrePersonnes,
                  nomGuide: _selectedGuide?.nomComplet,
                  montantTotal: _montantTotal,
                  modePaiement: _modePaiement,
                  statut: 'CONFIRMEE',
                  codeReservation:
                      'ZIG-${DateTime.now().millisecondsSinceEpoch % 100000}',
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TicketQrScreen(reservation: nouvelleReservation),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Confirmer & Générer le Billet QR'),
            ),
          ],
        ),
      ),
    );
  }
}
