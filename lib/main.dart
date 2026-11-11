import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features_colle/auth/login_screen.dart';
import 'features_colle/catalogue/home_screen.dart';
import 'features_colle/catalogue/sites_list_screen.dart';
import 'features_colle/map/map_explore_screen.dart';
import 'features_colle/splash/splash_screen.dart';
import 'features_thiamba/favorites/favorites_screen.dart';

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
        duration: const Duration(milliseconds: 420),
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

  /// Permet aux écrans enfants de changer d'onglet, avec filtre optionnel pour Explorer
  static void switchTab(
    BuildContext context,
    int index, {
    String? explorerCategory,
    String? explorerQuery,
  }) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    state?._setTab(
      index,
      explorerCategory: explorerCategory,
      explorerQuery: explorerQuery,
    );
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  String _explorerCategory = 'TOUS';
  String _explorerQuery = '';

  void _setTab(
    int index, {
    String? explorerCategory,
    String? explorerQuery,
  }) {
    if (index >= 0 && index < 5) {
      setState(() {
        _currentIndex = index;
        if (explorerCategory != null) {
          _explorerCategory = explorerCategory;
        }
        if (explorerQuery != null) {
          _explorerQuery = explorerQuery;
        }
      });
    }
  }

  Widget _buildScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return SitesListScreen(
          initialCategory: _explorerCategory,
          initialQuery: _explorerQuery,
        );
      case 2:
        return const MapExploreScreen();
      case 3:
        return const FavoritesScreen();
      case 4:
        return const LoginScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildScreenForIndex(_currentIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          border: const Border(
            top: BorderSide(color: AppTheme.borderLight),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppTheme.pureWhite,
              indicatorColor: AppTheme.lightGreen,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppTheme.forestGreen
                      : AppTheme.textSecondary,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: selected
                      ? AppTheme.forestGreen
                      : AppTheme.textSecondary,
                  size: 23,
                );
              }),
            ),
            child: NavigationBar(
              height: 64,
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => _setTab(i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Explorer',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded),
                  label: 'Carte GPS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favoris',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Compte',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
