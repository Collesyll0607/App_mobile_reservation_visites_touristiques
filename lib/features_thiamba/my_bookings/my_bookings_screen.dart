
import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../ticketing/ticket_qr_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final List<Reservation> reservations;

  const MyBookingsScreen({
    super.key,
    this.reservations = const [],
  });

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late List<Reservation> _reservations;

  @override
  void initState() {
    super.initState();
    _reservations = List.from(widget.reservations);
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return Colors.green;
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ANNULEE':
        return Colors.red;
      case 'EFFECTUEE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _nomStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return 'Confirmée';
      case 'EN_ATTENTE':
        return 'En attente';
      case 'ANNULEE':
        return 'Annulée';
      case 'EFFECTUEE':
        return 'Effectuée';
      default:
        return statut;
    }
  }

  void _annulerReservation(Reservation reservation) {
    setState(() {
      final index = _reservations.indexOf(reservation);

      if (index != -1) {
        _reservations[index] = Reservation(
          id: reservation.id,
          patrimoineId: reservation.patrimoineId,
          nomPatrimoine: reservation.nomPatrimoine,
          nomTouriste: reservation.nomTouriste,
          dateVisite: reservation.dateVisite,
          creneauHoraire: reservation.creneauHoraire,
          nombrePersonnes: reservation.nombrePersonnes,
          nomGuide: reservation.nomGuide,
          montantTotal: reservation.montantTotal,
          modePaiement: reservation.modePaiement,
          statut: 'ANNULEE',
          codeReservation: reservation.codeReservation,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation annulée.'),
      ),
    );
  }

  Future<void> _confirmerAnnulation(
    Reservation reservation,
  ) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: const Text(
          'Voulez-vous vraiment annuler cette visite ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmation == true && mounted) {
      _annulerReservation(reservation);
    }
  }

  Widget _carteReservation(Reservation reservation) {
    final couleur = _couleurStatut(reservation.statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.nomPatrimoine,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(reservation.dateVisite),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text(reservation.creneauHoraire),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.people, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${reservation.nombrePersonnes} participant(s)',
                ),
              ],
            ),

            if (reservation.nomGuide != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 18),
                  const SizedBox(width: 8),
                  Text('Guide : ${reservation.nomGuide}'),
                ],
              ),
            ],

            const SizedBox(height: 12),

            Text(
              '${reservation.montantTotal.toInt()} FCFA',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: couleur.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _nomStatut(reservation.statut),
                    style: TextStyle(
                      color: couleur,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),

                if (reservation.statut == 'EN_ATTENTE')
                  TextButton(
                    onPressed: () =>
                        _confirmerAnnulation(reservation),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                if (reservation.statut == 'CONFIRMEE' ||
                    reservation.statut == 'EFFECTUEE')
                  IconButton(
                    tooltip: 'Voir mon billet QR',
                    icon: const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF1B5E20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketQrScreen(
                            reservation: reservation,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: _reservations.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune réservation pour le moment.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                return _carteReservation(
                  _reservations[index],
                );
              },
            ),
    );
  }
}
