import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../catalogue/patrimoine_service.dart';
import '../catalogue/site_detail_screen.dart';
import 'location_service.dart';

/// Écran de Cartographie Interactive & Géolocalisation GPS intégrée — Design System v2
/// Palette sable et mangrove, marqueurs riches personnalisés, popup stylisée,
/// typographie Fraunces/Plus Jakarta Sans, responsive et dark-aware.
/// Responsable : Collé SYLL (Pôle 1 - Module Cartographie & GPS)
class MapExploreScreen extends StatefulWidget {
  final Patrimoine? initialSite;

  const MapExploreScreen({super.key, this.initialSite});

  @override
  State<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends State<MapExploreScreen> {
  final MapController _mapController = MapController();

  List<Patrimoine> _sites = ApiConfig.sitesCasamance;
  final List<PointRepereGps> _positionsDisponibles =
      List.from(LocationService.positionsReference);
  late PointRepereGps _positionActuelle;

  Patrimoine? _siteSelectionne;
  ItineraireResultat? _itineraireActif;
  bool _calculEnCours = false;
  bool _gpsEnCours = false;
  bool _cartePleinEcran = false;
  double _currentZoom = 12.2;

  @override
  void initState() {
    super.initState();
    _positionActuelle = _positionsDisponibles.first;
    _chargerSitesEtInitialiser();
  }

  Future<void> _chargerSitesEtInitialiser() async {
    final result = await PatrimoineService.fetchPatrimoines();
    if (!mounted) return;
    setState(() {
      _sites = result.sites;
    });

    if (widget.initialSite != null) {
      await _selectionnerSite(widget.initialSite!, centrerSurTrajet: true);
    }
  }

  Future<void> _localiserAppareil() async {
    setState(() => _gpsEnCours = true);
    final pos = await LocationService.obtenirPositionReelle();
    if (!mounted) return;

    setState(() => _gpsEnCours = false);

    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12),
          ),
          content: const Text(
            'GPS navigateur/appareil non autorisé. Choisissez un repère dans la liste.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _positionsDisponibles.removeWhere((p) => p.nom == pos.nom);
      _positionsDisponibles.insert(0, pos);
      _positionActuelle = pos;
    });

    _deplacerCarte(pos.toLatLng(), 13.0);

    if (_siteSelectionne != null) {
      await _selectionnerSite(_siteSelectionne!, centrerSurTrajet: false);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.forestGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        content: Text(
          'Position GPS détectée : ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
        ),
      ),
    );
  }

  Future<void> _selectionnerSite(
    Patrimoine site, {
    bool centrerSurTrajet = true,
  }) async {
    setState(() {
      _siteSelectionne = site;
      _calculEnCours = true;
    });

    final itineraire = await LocationService.calculerItineraire(
      depart: _positionActuelle,
      destination: site,
    );

    if (!mounted) return;
    setState(() {
      _itineraireActif = itineraire;
      _calculEnCours = false;
    });

    if (centrerSurTrajet) {
      final midLat = (_positionActuelle.latitude + site.latitude) / 2;
      final midLon = (_positionActuelle.longitude + site.longitude) / 2;
      final zoom = itineraire.distanceKm > 25
          ? 10.5
          : (itineraire.distanceKm > 8 ? 11.8 : 13.5);
      _deplacerCarte(LatLng(midLat, midLon), zoom);
    }
  }

  void _deplacerCarte(LatLng centre, double zoom) {
    _currentZoom = zoom.clamp(4.0, 18.0);
    _mapController.move(centre, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    final sitesTries = LocationService.trierParProximite(
      sites: _sites,
      userLat: _positionActuelle.latitude,
      userLon: _positionActuelle.longitude,
    );
    final surface = AppTheme.surfaceOf(context);
    final background = AppTheme.backgroundOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          // ── EN-TÊTE PROFESSIONNEL AVEC SÉLECTEUR DE REPÈRE GPS ──
          Container(
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 14, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_rounded, color: textCol),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Carte & Itinéraires GPS',
                                style: AppTheme.headingStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: textCol,
                                ),
                              ),
                              Text(
                                '${_sites.length} sites géolocalisés en Casamance',
                                style: AppTheme.bodyStyle(
                                  fontSize: 12,
                                  color: mutedCol,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: _cartePleinEcran
                              ? 'Afficher la liste'
                              : 'Agrandir la carte',
                          onPressed: () => setState(
                              () => _cartePleinEcran = !_cartePleinEcran),
                          style: IconButton.styleFrom(
                            backgroundColor: _cartePleinEcran
                                ? AppTheme.paleGreen
                                : surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radius12),
                              side: BorderSide(color: border),
                            ),
                          ),
                          icon: Icon(
                            _cartePleinEcran
                                ? Icons.view_agenda_rounded
                                : Icons.fullscreen_rounded,
                            color: AppTheme.forestGreen,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<PointRepereGps>(
                            key: ValueKey(_positionActuelle.nom),
                            initialValue: _positionActuelle,
                            isExpanded: true,
                            dropdownColor: surface,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.my_location_rounded,
                                color: AppTheme.oceanBlue,
                                size: 20,
                              ),
                              fillColor: background,
                              filled: true,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radius12),
                                borderSide: BorderSide(color: border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radius12),
                                borderSide: BorderSide(color: border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radius12),
                                borderSide: const BorderSide(
                                  color: AppTheme.forestGreen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            items: _positionsDisponibles.map((pt) {
                              return DropdownMenuItem<PointRepereGps>(
                                value: pt,
                                child: Text(
                                  pt.nom,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.bodyStyle(
                                    fontSize: 13,
                                    color: textCol,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              if (val == null) return;
                              setState(() => _positionActuelle = val);
                              _deplacerCarte(val.toLatLng(), 12.8);
                              if (_siteSelectionne != null) {
                                await _selectionnerSite(_siteSelectionne!);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forestGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radius12),
                            ),
                          ),
                          onPressed: _gpsEnCours ? null : _localiserAppareil,
                          child: _gpsEnCours
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.gps_fixed_rounded, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CARTE INTERACTIVE FLUTTER_MAP ──
          Expanded(
            flex: _cartePleinEcran ? 10 : 6,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _siteSelectionne != null
                        ? LatLng(
                            _siteSelectionne!.latitude,
                            _siteSelectionne!.longitude,
                          )
                        : _positionActuelle.toLatLng(),
                    initialZoom: _currentZoom,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'sn.uasz.reservation_visites',
                    ),
                    if (_itineraireActif != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _itineraireActif!.points,
                            strokeWidth: 5.0,
                            color: AppTheme.oceanBlue,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Repère position du touriste
                        Marker(
                          point: _positionActuelle.toLatLng(),
                          width: 46,
                          height: 46,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.oceanBlue.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppTheme.oceanBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: AppTheme.softShadow,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Marqueurs stylisés des sites touristiques
                        ...sitesTries.map((site) {
                          final isSelected = _siteSelectionne?.id == site.id;
                          return Marker(
                            point: LatLng(site.latitude, site.longitude),
                            width: isSelected ? 180 : 44,
                            height: isSelected ? 68 : 44,
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () => _selectionnerSite(site),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.forestGreen,
                                        borderRadius: BorderRadius.circular(AppTheme.radius12),
                                        boxShadow: AppTheme.softShadow,
                                      ),
                                      child: Text(
                                        site.nom,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.bodyStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: isSelected ? 40 : 34,
                                    color: isSelected
                                        ? AppTheme.ocreDark
                                        : AppTheme.forestGreen,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // Contrôles de zoom & recentrage
                Positioned(
                  right: 14,
                  top: 14,
                  child: Column(
                    children: [
                      _mapControlBtn(
                        heroTag: 'zoom_in',
                        icon: Icons.add,
                        surface: surface,
                        border: border,
                        color: textCol,
                        onTap: () => _deplacerCarte(
                          _mapController.camera.center,
                          _currentZoom + 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _mapControlBtn(
                        heroTag: 'zoom_out',
                        icon: Icons.remove,
                        surface: surface,
                        border: border,
                        color: textCol,
                        onTap: () => _deplacerCarte(
                          _mapController.camera.center,
                          _currentZoom - 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _mapControlBtn(
                        heroTag: 'recenter_me',
                        icon: Icons.center_focus_strong_rounded,
                        surface: surface,
                        border: border,
                        color: AppTheme.forestGreen,
                        onTap: () =>
                            _deplacerCarte(_positionActuelle.toLatLng(), 12.8),
                      ),
                    ],
                  ),
                ),

                // ── POPUP FLOTTANTE DU SITE SÉLECTIONNÉ ──
                if (_siteSelectionne != null)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                        border: Border.all(color: border),
                        boxShadow: AppTheme.shadowFor(context),
                      ),
                      child: Row(
                        children: [
                          SitePhotoView(
                            site: _siteSelectionne!,
                            width: 60,
                            height: 60,
                            borderRadius: BorderRadius.circular(AppTheme.radius12),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _siteSelectionne!.nom,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.headingStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textCol,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                if (_calculEnCours)
                                  Text(
                                    'Calcul du trajet en cours…',
                                    style: AppTheme.bodyStyle(
                                      fontSize: 12,
                                      color: mutedCol,
                                    ),
                                  )
                                else if (_itineraireActif != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.navigation_rounded,
                                        size: 13,
                                        color: AppTheme.oceanBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_itineraireActif!.distanceKm} km • ${_itineraireActif!.dureeEstimee}',
                                        style: AppTheme.bodyStyle(
                                          fontSize: 12.5,
                                          color: AppTheme.oceanBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SiteDetailScreen(
                                    site: _siteSelectionne!,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.forestGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radius12),
                              ),
                            ),
                            child: Text(
                              'Découvrir',
                              style: AppTheme.bodyStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── LISTE SYNCHRONISÉE DES SITES PAR PROXIMITÉ ──
          if (!_cartePleinEcran)
            Expanded(
              flex: 4,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: sitesTries.length,
                itemBuilder: (context, index) {
                  final site = sitesTries[index];
                  final distKm = LocationService.calculerDistanceKm(
                    lat1: _positionActuelle.latitude,
                    lon1: _positionActuelle.longitude,
                    lat2: site.latitude,
                    lon2: site.longitude,
                  );
                  final duree = LocationService.estimerTempsTrajet(distKm);
                  final isSelected = _siteSelectionne?.id == site.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF192D24) : AppTheme.paleGreen)
                          : surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                      border: Border.all(
                        color: isSelected ? AppTheme.forestGreen : border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected ? AppTheme.softShadow : [],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: index == 0
                            ? AppTheme.ocreGold
                            : AppTheme.forestGreen,
                        child: Text(
                          '#${index + 1}',
                          style: AppTheme.bodyStyle(
                            color: index == 0
                                ? AppTheme.textDark
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        site.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                        ),
                      ),
                      subtitle: Text(
                        'À $distKm km • $duree • ${site.localisation}',
                        style: AppTheme.bodyStyle(
                          fontSize: 12,
                          color: mutedCol,
                        ),
                      ),
                      trailing: TextButton.icon(
                        onPressed: () => _selectionnerSite(site),
                        icon: const Icon(
                          Icons.directions_rounded,
                          size: 18,
                          color: AppTheme.forestGreen,
                        ),
                        label: Text(
                          'Tracer',
                          style: AppTheme.bodyStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                      onTap: () => _selectionnerSite(site),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _mapControlBtn({
    required String heroTag,
    required IconData icon,
    required VoidCallback onTap,
    required Color surface,
    required Color border,
    Color color = AppTheme.textDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: border),
        boxShadow: AppTheme.softShadow,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
