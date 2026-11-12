import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features_colle/auth/auth_service.dart';
import 'features_colle/auth/login_screen.dart';
import 'features_colle/catalogue/home_screen.dart';
import 'features_colle/catalogue/sites_list_screen.dart';
import 'features_colle/map/map_explore_screen.dart';
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
  late int _initialTabIndex;

  @override
  void initState() {
    super.initState();
    final page = (Uri.base.queryParameters['page'] ?? '').toLowerCase();
    switch (page) {
      case 'explorer':
        _initialTabIndex = MainNavigationShell.tabExplorer;
        break;
      case 'carte':
        _initialTabIndex = MainNavigationShell.tabCarte;
        break;
      case 'reservations':
        _initialTabIndex = MainNavigationShell.tabReservations;
        break;
      case 'favoris':
        _initialTabIndex = MainNavigationShell.tabFavoris;
        break;
      case 'compte':
      case 'connexion':
      case 'profil':
        _initialTabIndex = MainNavigationShell.tabCompte;
        break;
      default:
        _initialTabIndex = MainNavigationShell.tabAccueil;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Casamance Tourisme & Visites',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: MainNavigationShell(initialIndex: _initialTabIndex),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  static const int tabAccueil = 0;
  static const int tabExplorer = 1;
  static const int tabCarte = 2;
  static const int tabReservations = 3;
  static const int tabFavoris = 4;
  static const int tabCompte = 5;

  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = tabAccueil});

  /// Permet aux écrans enfants de changer d'onglet avec filtres optionnels vers Explorer
  static void switchTab(
    BuildContext context,
    int index, {
    String? explorerCategory,
    String? explorerQuery,
    String? explorerLocation,
  }) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    state?._setTab(
      index,
      explorerCategory: explorerCategory,
      explorerQuery: explorerQuery,
      explorerLocation: explorerLocation,
    );
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  String _explorerCategory = 'TOUS';
  String _explorerQuery = '';
  String _explorerLocation = 'TOUTES';
  String? _userFirstName;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _refreshAuthState();
  }

  Future<void> _refreshAuthState() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _userFirstName = user?.nomComplet.trim().split(' ').first;
    });
  }

  void _setTab(
    int index, {
    String? explorerCategory,
    String? explorerQuery,
    String? explorerLocation,
  }) {
    if (index >= 0 && index <= 5) {
      setState(() {
        _currentIndex = index;
        if (explorerCategory != null) _explorerCategory = explorerCategory;
        if (explorerQuery != null) _explorerQuery = explorerQuery;
        if (explorerLocation != null) _explorerLocation = explorerLocation;
      });
      _refreshAuthState();
    }
  }

  Widget _buildScreenForIndex(int index) {
    switch (index) {
      case MainNavigationShell.tabAccueil:
        return const HomeScreen();
      case MainNavigationShell.tabExplorer:
        return SitesListScreen(
          initialCategory: _explorerCategory,
          initialQuery: _explorerQuery,
          initialLocation: _explorerLocation,
        );
      case MainNavigationShell.tabCarte:
        return const MapExploreScreen();
      case MainNavigationShell.tabReservations:
        return const MyBookingsScreen();
      case MainNavigationShell.tabFavoris:
        return const FavoritesScreen();
      case MainNavigationShell.tabCompte:
        return const LoginScreen();
      default:
        return const HomeScreen();
    }
  }

  static const List<Map<String, dynamic>> _desktopLinks = [
    {
      'index': MainNavigationShell.tabAccueil,
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
      'label': 'Accueil',
    },
    {
      'index': MainNavigationShell.tabExplorer,
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore_rounded,
      'label': 'Explorer',
    },
    {
      'index': MainNavigationShell.tabCarte,
      'icon': Icons.map_outlined,
      'activeIcon': Icons.map_rounded,
      'label': 'Carte GPS',
    },
    {
      'index': MainNavigationShell.tabReservations,
      'icon': Icons.confirmation_number_outlined,
      'activeIcon': Icons.confirmation_number_rounded,
      'label': 'Réservations',
    },
    {
      'index': MainNavigationShell.tabFavoris,
      'icon': Icons.favorite_border_rounded,
      'activeIcon': Icons.favorite_rounded,
      'label': 'Favoris',
    },
  ];

  static const List<Map<String, dynamic>> _mobileBottomTabs = [
    {
      'index': MainNavigationShell.tabAccueil,
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
      'label': 'Accueil',
    },
    {
      'index': MainNavigationShell.tabExplorer,
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore_rounded,
      'label': 'Explorer',
    },
    {
      'index': MainNavigationShell.tabCarte,
      'icon': Icons.map_outlined,
      'activeIcon': Icons.map_rounded,
      'label': 'Carte GPS',
    },
    {
      'index': MainNavigationShell.tabFavoris,
      'icon': Icons.favorite_border_rounded,
      'activeIcon': Icons.favorite_rounded,
      'label': 'Favoris',
    },
    {
      'index': MainNavigationShell.tabCompte,
      'icon': Icons.person_outline_rounded,
      'activeIcon': Icons.person_rounded,
      'label': 'Compte',
    },
  ];

  int get _mobileSelectedIdx {
    for (int i = 0; i < _mobileBottomTabs.length; i++) {
      if (_mobileBottomTabs[i]['index'] == _currentIndex) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 980;
    final accountLabel = _userFirstName != null && _userFirstName!.isNotEmpty
        ? 'Profil ($_userFirstName)'
        : 'Connexion';

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isDesktop ? 68 : 58),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.pureWhite,
            border: Border(
              bottom: BorderSide(color: AppTheme.borderLight),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 14),
                  child: Row(
                    children: [
                      // Logo Casamance Tourisme & Visites
                      InkWell(
                        onTap: () => _setTab(MainNavigationShell.tabAccueil),
                        borderRadius: BorderRadius.circular(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: isDesktop ? 38 : 34,
                              height: isDesktop ? 38 : 34,
                              decoration: BoxDecoration(
                                color: AppTheme.forestGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.park_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Casamance',
                                  style: GoogleFonts.poppins(
                                    fontSize: isDesktop ? 15 : 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.forestGreen,
                                    height: 1.05,
                                  ),
                                ),
                                Text(
                                  'Tourisme & Visites',
                                  style: GoogleFonts.poppins(
                                    fontSize: isDesktop ? 11 : 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.naturalGreen,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: _desktopLinks.map((item) {
                                  final idx = item['index'] as int;
                                  final selected = _currentIndex == idx;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: TextButton.icon(
                                      onPressed: () => _setTab(idx),
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
                                        size: 17,
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
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _setTab(MainNavigationShell.tabCompte),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _currentIndex == MainNavigationShell.tabCompte
                                    ? AppTheme.naturalGreen
                                    : AppTheme.forestGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          icon: Icon(
                            _userFirstName != null
                                ? Icons.person_rounded
                                : Icons.login_rounded,
                            size: 17,
                          ),
                          label: Text(
                            accountLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ] else ...[
                        const Spacer(),
                        IconButton(
                          tooltip: 'Mes réservations',
                          onPressed: () =>
                              _setTab(MainNavigationShell.tabReservations),
                          icon: Icon(
                            _currentIndex ==
                                    MainNavigationShell.tabReservations
                                ? Icons.confirmation_number_rounded
                                : Icons.confirmation_number_outlined,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildScreenForIndex(_currentIndex),
        ),
      ),
      bottomNavigationBar: isDesktop
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
                    selectedIndex: _mobileSelectedIdx,
                    onDestinationSelected: (i) {
                      final targetIndex = _mobileBottomTabs[i]['index'] as int;
                      _setTab(targetIndex);
                    },
                    destinations: _mobileBottomTabs
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
