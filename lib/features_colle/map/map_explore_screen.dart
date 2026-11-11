import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
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
            'GPS navigateur/appareil non autorisé. Vous pouvez choisir un point de départ dans la liste.',
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
      appBar: AppBar(
        title: const Text('Carte Interactive & GPS'),
        actions: [
          IconButton(
            tooltip: _cartePleinEcran ? 'Afficher la liste' : 'Agrandir la carte',
            onPressed: () =>
                setState(() => _cartePleinEcran = !_cartePleinEcran),
            icon: Icon(
              _cartePleinEcran ? Icons.view_agenda_outlined : Icons.fullscreen,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de sélection du point de départ GPS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Color(0xFF1B5E20)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<PointRepereGps>(
                    key: ValueKey(_positionActuelle.nom),
                    initialValue: _positionActuelle,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Ma position de départ',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    items: _positionsDisponibles.map((pt) {
                      return DropdownMenuItem<PointRepereGps>(
                        value: pt,
                        child: Text(
                          pt.nom,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
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
                      : const Icon(Icons.gps_fixed, size: 20),
                ),
              ],
            ),
          ),

          // CARTE INTERACTIVE INTÉGRÉE (OpenStreetMap via flutter_map)
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

                    // Tracé de l'itinéraire sélectionné
                    if (_itineraireActif != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _itineraireActif!.points,
                            strokeWidth: 5.0,
                            color: const Color(0xFF1565C0),
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),

                    // Marqueurs (Position du touriste + Sites touristiques)
                    MarkerLayer(
                      markers: [
                        // Marqueur de la position actuelle du touriste
                        Marker(
                          point: _positionActuelle.toLatLng(),
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
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
                            width: isSelected ? 170 : 44,
                            height: isSelected ? 64 : 44,
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () => _selectionnerSite(site),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B5E20),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4)
                                        ],
                                      ),
                                      child: Text(
                                        site.nom,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    Icons.location_on,
                                    size: isSelected ? 38 : 34,
                                    color: isSelected
                                        ? Colors.amber.shade700
                                        : const Color(0xFF1B5E20),
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

                // Boutons de contrôle Zoom & Recentrage sur la carte
                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        onPressed: () => _deplacerCarte(
                          _mapController.camera.center,
                          _currentZoom + 1,
                        ),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 6),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        onPressed: () => _deplacerCarte(
                          _mapController.camera.center,
                          _currentZoom - 1,
                        ),
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 6),
                      FloatingActionButton.small(
                        heroTag: 'recenter_me',
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B5E20),
                        onPressed: () =>
                            _deplacerCarte(_positionActuelle.toLatLng(), 12.5),
                        child: const Icon(Icons.center_focus_strong),
                      ),
                    ],
                  ),
                ),

                // Carte flottante d'information sur l'itinéraire actif
                if (_siteSelectionne != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _siteSelectionne!.nom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (_calculEnCours)
                                    const Text(
                                      'Calcul de l\'itinéraire en cours...',
                                      style: TextStyle(fontSize: 12),
                                    )
                                  else if (_itineraireActif != null)
                                    Text(
                                      '${_itineraireActif!.distanceKm} km • ${_itineraireActif!.dureeEstimee} (${_itineraireActif!.traceRoutierReel ? "Tracé routier" : "Trajet direct / fluvial"})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.w600,
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
                              child: const Text('Fiche & Réserver'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des sites triés par proximité (masquée si mode plein écran)
          if (!_cartePleinEcran)
            Expanded(
              flex: 4,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
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

                  return Card(
                    color: isSelected ? Colors.green.shade50 : Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: index == 0
                            ? Colors.amber.shade700
                            : const Color(0xFF1B5E20),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        site.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('À $distKm km • $duree'),
                      trailing: TextButton.icon(
                        onPressed: () => _selectionnerSite(site),
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Tracer'),
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
}
