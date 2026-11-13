import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
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
      case 'destinations':
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

/// Coquille de Navigation Principale — Architecture Premium
/// Navigation desktop épurée en 3 zones (Logo gauche / Navigation centre / Profil & Actions droite)
/// et BottomNavigationBar ergonomique sur mobile.
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = tabAccueil,
  });

  static const int tabAccueil = 0;
  static const int tabExplorer = 1;
  static const int tabCarte = 2;
  static const int tabReservations = 3;
  static const int tabFavoris = 4;
  static const int tabCompte = 5;

  /// Permet aux écrans enfants de changer d'onglet
  static void switchTab(
    BuildContext context,
    int index, {
    String? explorerCategory,
    String? explorerQuery,
    String? explorerLocation,
  }) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    if (state != null) {
      state.changeTab(
        index,
        explorerCategory: explorerCategory,
        explorerQuery: explorerQuery,
        explorerLocation: explorerLocation,
      );
    }
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  String? _userFirstName;

  String _explorerCategory = 'TOUS';
  String _explorerQuery = '';
  String _explorerLocation = 'TOUTES';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        final rawName = user?.nomComplet.trim() ?? '';
        _userFirstName = rawName.isNotEmpty ? rawName.split(' ').first : null;
      });
    }
  }

  void changeTab(
    int index, {
    String? explorerCategory,
    String? explorerQuery,
    String? explorerLocation,
  }) {
    setState(() {
      _currentIndex = index;
      if (explorerCategory != null) _explorerCategory = explorerCategory;
      if (explorerQuery != null) _explorerQuery = explorerQuery;
      if (explorerLocation != null) _explorerLocation = explorerLocation;
    });
  }

  void _setTab(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
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

  static const List<Map<String, dynamic>> _centerLinks = [
    {
      'index': MainNavigationShell.tabAccueil,
      'label': 'Accueil',
    },
    {
      'index': MainNavigationShell.tabExplorer,
      'label': 'Destinations',
    },
    {
      'index': MainNavigationShell.tabCarte,
      'label': 'Carte GPS',
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
    final surface = AppTheme.surfaceOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);
    final accountLabel = _userFirstName != null && _userFirstName!.isNotEmpty
        ? _userFirstName!
        : 'Connexion';

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isDesktop ? 74 : 60),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.96),
            border: Border(
              bottom: BorderSide(color: border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                  child: Row(
                    children: [
                      // 1. GAUCHE : Logo & Identité Luxury
                      InkWell(
                        onTap: () => _setTab(MainNavigationShell.tabAccueil),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: isDesktop ? 40 : 36,
                              height: isDesktop ? 40 : 36,
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldGreen,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.emeraldGreen.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CASAMANCE',
                                  style: AppTheme.headingStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.emeraldGreen,
                                    height: 1.05,
                                  ),
                                ),
                                Text(
                                  'TOURISME & VOYAGES D\'EXCEPTION',
                                  style: AppTheme.bodyStyle(
                                    fontSize: isDesktop ? 9 : 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.terracotta,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 2. CENTRE : Navigation Principale (Desktop)
                      if (isDesktop) ...[
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _centerLinks.map((item) {
                            final idx = item['index'] as int;
                            final selected = _currentIndex == idx;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: TextButton(
                                onPressed: () => _setTab(idx),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: selected
                                      ? AppTheme.paleGreen
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  item['label'] as String,
                                  style: AppTheme.bodyStyle(
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? AppTheme.emeraldGreen
                                        : textCol,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const Spacer(),
                      ] else ...[
                        const Spacer(),
                      ],

                      // 3. DROITE : Favoris, Réservations & Profil
                      if (isDesktop) ...[
                        // Bouton Favoris
                        IconButton(
                          tooltip: 'Favoris',
                          onPressed: () => _setTab(MainNavigationShell.tabFavoris),
                          icon: Icon(
                            _currentIndex == MainNavigationShell.tabFavoris
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _currentIndex == MainNavigationShell.tabFavoris
                                ? AppTheme.terracotta
                                : textCol,
                            size: 20,
                          ),
                        ),
                        // Bouton Réservations
                        IconButton(
                          tooltip: 'Mes Réservations',
                          onPressed: () =>
                              _setTab(MainNavigationShell.tabReservations),
                          icon: Icon(
                            _currentIndex == MainNavigationShell.tabReservations
                                ? Icons.confirmation_number_rounded
                                : Icons.confirmation_number_outlined,
                            color: _currentIndex == MainNavigationShell.tabReservations
                                ? AppTheme.emeraldGreen
                                : textCol,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Bouton Profil / Connexion Luxury
                        InkWell(
                          onTap: () => _setTab(MainNavigationShell.tabCompte),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _currentIndex == MainNavigationShell.tabCompte
                                  ? AppTheme.emeraldGreen
                                  : AppTheme.deepForest,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  accountLabel,
                                  style: AppTheme.bodyStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Action mobile directe
                        IconButton(
                          icon: const Icon(Icons.tune_rounded),
                          color: textCol,
                          onPressed: () =>
                              _setTab(MainNavigationShell.tabExplorer),
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
      body: _buildBody(),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: surface,
                border: Border(top: BorderSide(color: border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _mobileSelectedIdx,
                backgroundColor: surface,
                indicatorColor: AppTheme.paleGreen,
                height: 64,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                onDestinationSelected: (pos) {
                  _setTab(_mobileBottomTabs[pos]['index'] as int);
                },
                destinations: _mobileBottomTabs.map((item) {
                  return NavigationDestination(
                    icon: Icon(
                      item['icon'] as IconData,
                      color: AppTheme.mutedOf(context),
                      size: 22,
                    ),
                    selectedIcon: Icon(
                      item['activeIcon'] as IconData,
                      color: AppTheme.emeraldGreen,
                      size: 22,
                    ),
                    label: item['label'] as String,
                  );
                }).toList(),
              ),
            ),
    );
  }
}
