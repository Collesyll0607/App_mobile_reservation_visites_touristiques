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

/// Écran de Cartographie Interactive & Géolocalisation GPS intégrée
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
        const SnackBar(
          content: Text(
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

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          // En-tête vert forêt avec sélecteur GPS intégré
          Container(
            color: AppTheme.deepForest,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 12, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                        Expanded(
                          child: Text(
                            'Carte & Itinéraires GPS',
                            style: AppTheme.editorialTitle(
                              fontSize: 21,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: _cartePleinEcran
                              ? 'Afficher la liste'
                              : 'Agrandir la carte',
                          onPressed: () => setState(
                              () => _cartePleinEcran = !_cartePleinEcran),
                          icon: Icon(
                            _cartePleinEcran
                                ? Icons.view_agenda_outlined
                                : Icons.fullscreen_rounded,
                            color: AppTheme.solarGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<PointRepereGps>(
                            key: ValueKey(_positionActuelle.nom),
                            initialValue: _positionActuelle,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.my_location_rounded,
                                  color: AppTheme.bolongTurquoise, size: 20),
                              fillColor: Colors.white,
                              filled: true,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                            items: _positionsDisponibles.map((pt) {
                              return DropdownMenuItem<PointRepereGps>(
                                value: pt,
                                child: Text(
                                  pt.nom,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.bodyStyle(fontSize: 12.5),
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
                            backgroundColor: AppTheme.bolongTurquoise,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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

          // CARTE INTERACTIVE INTÉGRÉE
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
                            color: AppTheme.bolongTurquoise,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Position du touriste
                        Marker(
                          point: _positionActuelle.toLatLng(),
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.bolongTurquoise
                                  .withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppTheme.bolongTurquoise,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Marqueurs des sites touristiques
                        ...sitesTries.map((site) {
                          final isSelected = _siteSelectionne?.id == site.id;
                          return Marker(
                            point: LatLng(site.latitude, site.longitude),
                            width: isSelected ? 175 : 44,
                            height: isSelected ? 66 : 44,
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () => _selectionnerSite(site),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.deepForest,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: AppTheme.softShadow,
                                      ),
                                      child: Text(
                                        site.nom,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.bodyStyle(
                                          color: AppTheme.solarGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: isSelected ? 40 : 34,
                                    color: isSelected
                                        ? AppTheme.lateriteRed
                                        : AppTheme.deepForest,
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
                  right: 12,
                  top: 12,
                  child: Column(
                    children: [
                      _mapControlBtn(
                        heroTag: 'zoom_in',
                        icon: Icons.add,
                        onTap: () => _deplacerCarte(
                          _mapController.camera.center,
                          _currentZoom + 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _mapControlBtn(
                        heroTag: 'zoom_out',
                        icon: Icons.remove,
                        onTap: () => _deplacerCarte(
                          _mapController.camera.center,
                          _currentZoom - 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _mapControlBtn(
                        heroTag: 'recenter_me',
                        icon: Icons.center_focus_strong_rounded,
                        color: AppTheme.deepForest,
                        onTap: () =>
                            _deplacerCarte(_positionActuelle.toLatLng(), 12.5),
                      ),
                    ],
                  ),
                ),

                // Carte flottante d'info itinéraire
                if (_siteSelectionne != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          SitePhotoView(
                            site: _siteSelectionne!,
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _siteSelectionne!.nom,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.editorialTitle(
                                    fontSize: 15.5,
                                    color: AppTheme.deepForest,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (_calculEnCours)
                                  Text(
                                    'Calcul du trajet...',
                                    style: AppTheme.bodyStyle(fontSize: 11.5),
                                  )
                                else if (_itineraireActif != null)
                                  Text(
                                    '${_itineraireActif!.distanceKm} km • ${_itineraireActif!.dureeEstimee}',
                                    style: AppTheme.bodyStyle(
                                      fontSize: 12,
                                      color: AppTheme.bolongTurquoise,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Découvrir'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des sites triés par proximité
          if (!_cartePleinEcran)
            Expanded(
              flex: 4,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
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
                          ? AppTheme.sageSurface
                          : AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.deepForest
                            : AppTheme.deepForest.withValues(alpha: 0.08),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 17,
                        backgroundColor: index == 0
                            ? AppTheme.solarGold
                            : AppTheme.deepForest,
                        child: Text(
                          '#${index + 1}',
                          style: AppTheme.bodyStyle(
                            color: index == 0
                                ? AppTheme.deepForest
                                : Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        site.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'À $distKm km • $duree',
                        style: AppTheme.bodyStyle(
                            fontSize: 11.5, color: AppTheme.textMuted),
                      ),
                      trailing: TextButton.icon(
                        onPressed: () => _selectionnerSite(site),
                        icon: const Icon(Icons.directions,
                            size: 17, color: AppTheme.bolongTurquoise),
                        label: Text(
                          'Tracer',
                          style: AppTheme.bodyStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.bolongTurquoise,
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
    Color color = AppTheme.textDark,
  }) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: AppTheme.cardSurface,
      foregroundColor: color,
      onPressed: onTap,
      child: Icon(icon, size: 20),
    );
  }
}
