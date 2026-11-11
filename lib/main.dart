import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features_colle/auth/login_screen.dart';
import 'features_colle/catalogue/home_screen.dart';
import 'features_colle/map/map_explore_screen.dart';
import 'features_colle/splash/splash_screen.dart';
import 'features_thiamba/favorites/favorites_screen.dart';
import 'features_thiamba/my_bookings/my_bookings_screen.dart';

void main() {
  runApp(const ZiguinchorTourismeApp());
}

class ZiguinchorTourismeApp extends StatefulWidget {
  const ZiguinchorTourismeApp({super.key});

  @override
  State<ZiguinchorTourismeApp> createState() => _ZiguinchorTourismeAppState();
}

class _ZiguinchorTourismeAppState extends State<ZiguinchorTourismeApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casamance Tourisme & Visites',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _showSplash
            ? SplashScreen(
                onStart: () => setState(() => _showSplash = false),
              )
            : const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  /// Permet à n'importe quel écran enfant (ex. Profil) de basculer vers un onglet précis
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    state?._setTab(index);
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _setTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(), // 0 - Pôle 1 : Accueil & Découverte
    MapExploreScreen(), // 1 - Pôle 1 : Carte Interactive GPS
    MyBookingsScreen(), // 2 - Pôle 2 : Réservations & QR
    FavoritesScreen(), // 3 - Pôle 2 : Favoris Hors-Ligne
    LoginScreen(), // 4 - Pôle 1 : Profil & Compte
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.deepForest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppTheme.deepForest,
              indicatorColor: AppTheme.solarGold.withValues(alpha: 0.22),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return AppTheme.bodyStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? AppTheme.solarGold
                      : AppTheme.ivorySand.withValues(alpha: 0.78),
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: selected
                      ? AppTheme.solarGold
                      : AppTheme.ivorySand.withValues(alpha: 0.78),
                  size: 24,
                );
              }),
            ),
            child: NavigationBar(
              height: 66,
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: _setTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded),
                  label: 'Carte GPS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.confirmation_number_outlined),
                  selectedIcon: Icon(Icons.confirmation_number_rounded),
                  label: 'Réservations',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favoris',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
