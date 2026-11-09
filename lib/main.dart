import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features_colle/catalogue/home_screen.dart';
import 'features_colle/map/map_explore_screen.dart';
import 'features_colle/auth/login_screen.dart';
import 'features_thiamba/my_bookings/my_bookings_screen.dart';
import 'features_thiamba/favorites/favorites_screen.dart';

void main() {
  runApp(const ZiguinchorTourismeApp());
}

class ZiguinchorTourismeApp extends StatelessWidget {
  const ZiguinchorTourismeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziguinchor Visites & Réservations',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),        // Pôle 1 : Collé SYLL
    MapExploreScreen(),  // Pôle 1 : Collé SYLL
    MyBookingsScreen(),  // Pôle 2 : Ndeye Thiamba FAYE
    FavoritesScreen(),   // Pôle 2 : Ndeye Thiamba FAYE
    LoginScreen(),       // Pôle 1 : Collé SYLL
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Sites',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Carte GPS',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Réservations',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}
