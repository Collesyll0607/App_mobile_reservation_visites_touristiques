
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/models/reservation.dart';

/// Écran du billet numérique avec véritable QR Code
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)

class TicketQrScreen extends StatelessWidget {
  final Reservation reservation;

  const TicketQrScreen({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pass de Visite Numérique'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF1B5E20),
                    size: 48,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'RÉSERVATION CONFIRMÉE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      letterSpacing: 1.2,
                    ),
                  ),

                  const Divider(height: 28),

                  Text(
                    reservation.nomPatrimoine,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildRow(
                    'Code billet :',
                    reservation.codeReservation,
                  ),

                  _buildRow(
                    'Date de visite :',
                    reservation.dateVisite,
                  ),

                  _buildRow(
                    'Créneau :',
                    reservation.creneauHoraire,
                  ),

                  _buildRow(
                    'Visiteurs :',
                    '${reservation.nombrePersonnes} personne(s)',
                  ),

                  _buildRow(
                    'Guide :',
                    reservation.nomGuide ?? 'Visite libre',
                  ),

                  _buildRow(
                    'Paiement :',
                    reservation.modePaiement,
                  ),

                  _buildRow(
                    'Montant total :',
                    '${reservation.montantTotal.toInt()} FCFA',
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Présentez ce QR Code à votre arrivée',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Véritable QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black26,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: reservation.codeReservation,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    reservation.codeReservation,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Retour à l’accueil'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
