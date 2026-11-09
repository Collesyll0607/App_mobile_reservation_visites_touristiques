import 'package:flutter/material.dart';

/// TODO (Ndeye Thiamba FAYE - Pôle 2) :
/// Développer ici l'historique des réservations du touriste et l'espace Guide.
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Réservations (Module Thiamba)')),
      body: const Center(
        child: Text(
          'Module Mes Réservations & Espace Guide\n(À développer par Ndeye Thiamba FAYE)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
