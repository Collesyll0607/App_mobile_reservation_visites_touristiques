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

  /// Bascule d'onglet avec transmission optionnelle de filtre vers Explorer
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
        if (explorerCategory != null) _explorerCategory = explorerCategory;
        if (explorerQuery != null) _explorerQuery = explorerQuery;
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

  static const List<Map<String, dynamic>> _destinations = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
      'label': 'Accueil',
    },
    {
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore_rounded,
      'label': 'Explorer',
    },
    {
      'icon': Icons.map_outlined,
      'activeIcon': Icons.map_rounded,
      'label': 'Carte',
    },
    {
      'icon': Icons.favorite_border_rounded,
      'activeIcon': Icons.favorite_rounded,
      'label': 'Favoris',
    },
    {
      'icon': Icons.person_outline_rounded,
      'activeIcon': Icons.person_rounded,
      'label': 'Compte',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 78),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _buildScreenForIndex(_currentIndex),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.deepForest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.champagneGold.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepForest.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_destinations.length, (i) {
                final item = _destinations[i];
                final selected = i == _currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _setTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.champagneGold.withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected
                                ? item['activeIcon'] as IconData
                                : item['icon'] as IconData,
                            size: 20,
                            color: selected
                                ? AppTheme.champagneGold
                                : AppTheme.ivorySand.withValues(alpha: 0.72),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['label'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10.2,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected
                                  ? AppTheme.champagneGold
                                  : AppTheme.ivorySand.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
