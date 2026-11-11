import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reservation_visites_touristiques/core/models/patrimoine.dart';
import 'package:reservation_visites_touristiques/features_colle/splash/splash_screen.dart';
import 'package:reservation_visites_touristiques/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  test('Patrimoine.fromJson classe les 6 catégories réelles du catalogue', () {
    expect(
      Patrimoine.fromJson({'id': 1, 'nom': 'Alliance Franco-Sénégalaise'})
          .categorie,
      'CULTURE',
    );
    expect(
      Patrimoine.fromJson({'id': 4, 'nom': 'Village Artisanal de Ziguinchor'})
          .categorie,
      'ARTISANAT',
    );
    expect(
      Patrimoine.fromJson({'id': 5, 'nom': 'Mémorial & Musée Le Joola'})
          .categorie,
      'MUSEE',
    );
    expect(
      Patrimoine.fromJson({'id': 6, 'nom': 'Écosystème des Bolongs & Mangroves'})
          .categorie,
      'NATURE',
    );
    expect(
      Patrimoine.fromJson({'id': 7, 'nom': 'Cases Traditionnelles à Étages de Mlomp'})
          .categorie,
      'ARCHITECTURE',
    );
    expect(
      Patrimoine.fromJson({'id': 3, 'nom': 'Cathédrale Saint-Antoine de Padoue'})
          .categorie,
      'MONUMENT',
    );
  });

  testWidgets('SplashScreen affiche le nom, slogan et bouton Commencer',
      (tester) async {
    bool started = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(onStart: () => started = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tourisme & Visites'), findsOneWidget);
    expect(find.text('Explorez. Réservez. Profitez.'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);

    await tester.tap(find.text('Commencer'));
    expect(started, isTrue);
  });

  testWidgets('MainNavigationShell expose les 5 onglets demandés',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('Carte GPS'), findsOneWidget);
    expect(find.text('Favoris'), findsOneWidget);
    expect(find.text('Compte'), findsOneWidget);
  });
}
