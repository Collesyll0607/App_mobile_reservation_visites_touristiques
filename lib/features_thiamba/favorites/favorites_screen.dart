import 'package:flutter/material.dart';

/// TODO (Ndeye Thiamba FAYE - Pôle 2) :
/// Développer ici la gestion des sites favoris en mode hors-ligne (SharedPreferences / SQLite).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoris (Module Thiamba)')),
      body: const Center(
        child: Text(
          'Module Favoris Hors-Ligne\n(À développer par Ndeye Thiamba FAYE)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
