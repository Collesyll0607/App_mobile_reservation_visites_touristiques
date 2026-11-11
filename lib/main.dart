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
  late bool _showSplash;
  late int _initialTabIndex;

  @override
  void initState() {
    super.initState();
    final page = (Uri.base.queryParameters['page'] ?? '').toLowerCase();
    switch (page) {
      case 'accueil':
        _initialTabIndex = 0;
        _showSplash = false;
        break;
      case 'explorer':
        _initialTabIndex = 1;
        _showSplash = false;
        break;
      case 'carte':
        _initialTabIndex = 2;
        _showSplash = false;
        break;
      case 'favoris':
        _initialTabIndex = 3;
        _showSplash = false;
        break;
      case 'compte':
        _initialTabIndex = 4;
        _showSplash = false;
        break;
      default:
        _initialTabIndex = 0;
        _showSplash = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casamance Tourisme & Visites',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _showSplash
            ? SplashScreen(
                onStart: () => setState(() => _showSplash = false),
              )
            : MainNavigationShell(initialIndex: _initialTabIndex),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  /// Permet aux écrans enfants de changer d'onglet avec filtre optionnel vers Explorer
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
  late int _currentIndex;
  String _explorerCategory = 'TOUS';
  String _explorerQuery = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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

  static const List<Map<String, dynamic>> _navItems = [
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
      'label': 'Carte GPS',
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
    final isDesktopOrTablet = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: isDesktopOrTablet
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.pureWhite,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderLight),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppTheme.maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _setTab(0),
                            borderRadius: BorderRadius.circular(10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.paleGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.park_rounded,
                                    color: AppTheme.forestGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Casamance Tourisme',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(4, (i) {
                                    final item = _navItems[i];
                                    final selected = i == _currentIndex;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: TextButton.icon(
                                        onPressed: () => _setTab(i),
                                        style: TextButton.styleFrom(
                                          backgroundColor: selected
                                              ? AppTheme.paleGreen
                                              : Colors.transparent,
                                          foregroundColor: selected
                                              ? AppTheme.forestGreen
                                              : AppTheme.textDark,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        icon: Icon(
                                          selected
                                              ? item['activeIcon'] as IconData
                                              : item['icon'] as IconData,
                                          size: 18,
                                        ),
                                        label: Text(
                                          item['label'] as String,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Bouton Compte
                          ElevatedButton.icon(
                            onPressed: () => _setTab(4),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentIndex == 4
                                  ? AppTheme.forestGreen
                                  : AppTheme.pureWhite,
                              foregroundColor: _currentIndex == 4
                                  ? Colors.white
                                  : AppTheme.textDark,
                              side: BorderSide(
                                color: _currentIndex == 4
                                    ? AppTheme.forestGreen
                                    : AppTheme.borderLight,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: Icon(
                              _currentIndex == 4
                                  ? Icons.person_rounded
                                  : Icons.person_outline_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Compte',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildScreenForIndex(_currentIndex),
        ),
      ),
      bottomNavigationBar: isDesktopOrTablet
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppTheme.pureWhite,
                border: Border(top: BorderSide(color: AppTheme.borderLight)),
              ),
              child: SafeArea(
                top: false,
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor: AppTheme.pureWhite,
                    indicatorColor: AppTheme.paleGreen,
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? AppTheme.forestGreen
                            : AppTheme.textMuted,
                      );
                    }),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        color: selected
                            ? AppTheme.forestGreen
                            : AppTheme.textMuted,
                        size: 22,
                      );
                    }),
                  ),
                  child: NavigationBar(
                    height: 62,
                    elevation: 0,
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (i) => _setTab(i),
                    destinations: _navItems
                        .map(
                          (item) => NavigationDestination(
                            icon: Icon(item['icon'] as IconData),
                            selectedIcon: Icon(item['activeIcon'] as IconData),
                            label: item['label'] as String,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
