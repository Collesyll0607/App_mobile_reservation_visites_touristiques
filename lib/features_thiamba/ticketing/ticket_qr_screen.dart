import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';

/// TODO (Ndeye Thiamba FAYE - Pôle 2) :
/// Développer ici l'écran du billet numérique et QR Code après réservation.
class TicketQrScreen extends StatelessWidget {
  final Reservation reservation;

  const TicketQrScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billet QR (Module Thiamba)')),
      body: const Center(
        child: Text(
          'Module Billetterie QR Code\n(À développer par Ndeye Thiamba FAYE)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
