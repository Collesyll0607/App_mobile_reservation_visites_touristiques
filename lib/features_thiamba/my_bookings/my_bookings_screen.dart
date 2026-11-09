import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../ticketing/ticket_qr_screen.dart';

/// Écran Historique des Réservations & Suivi de Statut
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  static const List<Reservation> _demoBookings = [
    Reservation(
      id: 1,
      patrimoineId: 1,
      nomPatrimoine: 'Île Historique de Carabane',
      nomTouriste: 'Touriste Visiteur',
      dateVisite: '25/11/2026',
      creneauHoraire: '09h00 - 11h00',
      nombrePersonnes: 2,
      nomGuide: 'Mamadou Lamine Diedhiou',
      montantTotal: 16000,
      modePaiement: 'WAVE',
      statut: 'CONFIRMEE',
      codeReservation: 'ZIG-2026-841',
    ),
    Reservation(
      id: 2,
      patrimoineId: 2,
      nomPatrimoine: 'Cases à Impluvium d\'Enampore & Mlomp',
      nomTouriste: 'Touriste Visiteur',
      dateVisite: '28/11/2026',
      creneauHoraire: '15h00 - 17h30',
      nombrePersonnes: 3,
      nomGuide: null,
      montantTotal: 6000,
      modePaiement: 'ORANGE_MONEY',
      statut: 'EN_ATTENTE',
      codeReservation: 'ZIG-2026-912',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations & Billets'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _demoBookings.length,
        itemBuilder: (context, index) {
          final res = _demoBookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1B5E20),
                child: Icon(Icons.confirmation_number_outlined,
                    color: Colors.white),
              ),
              title: Text(
                res.nomPatrimoine,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Date : ${res.dateVisite} (${res.creneauHoraire})\nMontant : ${res.montantTotal.toInt()} FCFA — Statut : ${res.statut}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.qr_code, color: Color(0xFF1B5E20)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketQrScreen(reservation: res),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
