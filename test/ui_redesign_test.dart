import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reservation_visites_touristiques/core/config/api_config.dart';
import 'package:reservation_visites_touristiques/core/models/patrimoine.dart';
import 'package:reservation_visites_touristiques/core/utils/site_media_helper.dart';
import 'package:reservation_visites_touristiques/features_colle/catalogue/home_screen.dart';
import 'package:reservation_visites_touristiques/features_colle/catalogue/sites_list_screen.dart';
import 'package:reservation_visites_touristiques/features_colle/splash/splash_screen.dart';
import 'package:reservation_visites_touristiques/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  test('Patrimoine.fromJson classe les catégories réelles du catalogue', () {
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

  test('SiteMediaHelper.matchesExplorerTheme couvre les 7 thématiques réelles',
      () {
    const sites = ApiConfig.sitesCasamance;
    for (final code in const [
      'NATURE',
      'PATRIMOINE',
      'ARCHITECTURE',
      'MUSEES',
      'PLAGES',
      'ARTISANAT',
      'CULTURE',
    ]) {
      final matches =
          sites.where((s) => SiteMediaHelper.matchesExplorerTheme(s, code));
      expect(
        matches,
        isNotEmpty,
        reason: 'La catégorie $code doit correspondre à au moins un site réel',
      );
    }
  });

  testWidgets('SplashScreen reste fonctionnel avec slogan et bouton Commencer',
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

  testWidgets('MainNavigationShell adapte la navigation mobile et desktop',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Ouvre directement la plateforme sur Accueil (pas d'écran Splash bloquant)
    expect(find.text('Là où la nature rencontre l\'authenticité.'), findsOneWidget);
    expect(find.text('Accueil'), findsAtLeastNWidgets(1));
    expect(find.text('Explorer'), findsAtLeastNWidgets(1));
    expect(find.text('Carte GPS'), findsAtLeastNWidgets(1));
    expect(find.text('Favoris'), findsAtLeastNWidgets(1));
    expect(find.text('Compte'), findsOneWidget);

    // Bascule sur largeur ordinateur (1280px)
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('CASAMANCE'), findsWidgets);
    expect(find.text('Accueil'), findsAtLeastNWidgets(1));
    expect(find.text('Destinations'), findsAtLeastNWidgets(1));
    expect(find.text('Carte GPS'), findsAtLeastNWidgets(1));
    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets(
      'HomeScreen affiche Hero, Recherche, Incontournables, 7 Catégories et Expériences sans overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(initialSites: ApiConfig.sitesCasamance),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Là où la nature rencontre l\'authenticité.'), findsOneWidget);
    expect(
      find.text(
        'Découvrez les trésors cachés de la Casamance, entre fleuves majestueux, patrimoine séculaire et traditions vivantes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Explorer la Casamance'), findsOneWidget);
    expect(find.text('Les incontournables'), findsOneWidget);
    expect(
      find.text('Des lieux qui méritent le détour'),
      findsOneWidget,
    );
    expect(find.text('L\'âme de la Casamance'), findsOneWidget);
    expect(find.text('Avis des visiteurs'), findsOneWidget);

    for (final pillarTitle in const [
      'Nature & Mangroves',
      'Patrimoine & Histoire',
      'Architecture Diola',
      'Mémoire & Musées',
      'Fleuves & Plages Sauvages',
      'Artisanat & Savoir-faire',
    ]) {
      expect(find.text(pillarTitle), findsAtLeastNWidgets(1));
    }

    // Largeur mobile 390px
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.text('Là où la nature rencontre l\'authenticité.'), findsOneWidget);
    expect(find.text('Explorer la Casamance'), findsOneWidget);
  });

  testWidgets(
      'SitesListScreen filtre les 8 pilules, les lieux et s\'adapte sur mobile et desktop',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SitesListScreen(
          initialSites: ApiConfig.sitesCasamance,
          initialLocation: 'Carabane',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explorer la Casamance'), findsOneWidget);
    expect(find.text('Lieu : Carabane'), findsOneWidget);
    expect(find.textContaining('Carabane'), findsAtLeastNWidgets(1));

    for (final label in const [
      'Tous',
      'Nature',
      'Patrimoine',
      'Architecture',
      'Musées',
      'Plages',
      'Artisanat',
      'Culture',
    ]) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }

    // Retire le filtre lieu puis teste le filtre Nature
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nature').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Bolongs'), findsAtLeastNWidgets(1));

    // Test responsive largeur smartphone
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.text('Explorer la Casamance'), findsOneWidget);
  });
}
