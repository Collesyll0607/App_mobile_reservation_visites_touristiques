import 'package:flutter/material.dart';
import '../../core/models/patrimoine.dart';

/// TODO (Ndeye Thiamba FAYE - Pôle 2) :
/// Développer ici le formulaire de réservation (Date, Horaire, Nb personnes, Guide, Tarif).
class BookingFormScreen extends StatelessWidget {
  final Patrimoine site;

  const BookingFormScreen({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réservation (Module Thiamba)')),
      body: Center(
        child: Text(
          'Module Réservation pour : ${site.nom}\n(À développer par Ndeye Thiamba FAYE)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
