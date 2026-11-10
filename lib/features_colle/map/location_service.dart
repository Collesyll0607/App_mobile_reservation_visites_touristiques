import 'dart:math';
import '../../core/models/patrimoine.dart';

/// Point de repère GPS pour simuler ou définir la position du touriste
class PointRepereGps {
  final String nom;
  final double latitude;
  final double longitude;

  const PointRepereGps({
    required this.nom,
    required this.latitude,
    required this.longitude,
  });
}

/// Service de Géolocalisation GPS & Algorithme de Haversine
/// Responsable : Collé SYLL (Pôle 1 - Module Cartographie & GPS)
class LocationService {
  /// Positions GPS de référence à Ziguinchor & Casamance
  static const List<PointRepereGps> positionsReference = [
    PointRepereGps(
      nom: 'Centre-ville de Ziguinchor (Quartier Escale)',
      latitude: 12.5833,
      longitude: -16.2719,
    ),
    PointRepereGps(
      nom: 'Université Assane Seck de Ziguinchor (UASZ - Diabir)',
      latitude: 12.5483,
      longitude: -16.2869,
    ),
    PointRepereGps(
      nom: 'Port Maritime de Ziguinchor (Quai)',
      latitude: 12.5875,
      longitude: -16.2738,
    ),
    PointRepereGps(
      nom: 'Aéroport de Ziguinchor',
      latitude: 12.5556,
      longitude: -16.2817,
    ),
    PointRepereGps(
      nom: 'Station Balnéaire de Cap Skirring',
      latitude: 12.3833,
      longitude: -16.7167,
    ),
  ];

  /// Algorithme de Haversine : Calcule la distance orthodromique en kilomètres (km)
  /// entre deux points GPS (lat1, lon1) et (lat2, lon2) sur la sphère terrestre.
  static double calculerDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double rayonTerreKm = 6371.0;

    final double dLat = _degresEnRadians(lat2 - lat1);
    final double dLon = _degresEnRadians(lon2 - lon1);

    final double a = pow(sin(dLat / 2), 2) +
        cos(_degresEnRadians(lat1)) *
            cos(_degresEnRadians(lat2)) *
            pow(sin(dLon / 2), 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = rayonTerreKm * c;

    return double.parse(distance.toStringAsFixed(2));
  }

  /// Estime la durée du trajet en fonction de la distance en km
  static String estimerTempsTrajet(double distanceKm) {
    if (distanceKm < 2.0) {
      final minutesPied = (distanceKm / 4.5 * 60).round().clamp(3, 45);
      return '$minutesPied min à pied';
    }
    final minutesRoute = (distanceKm / 45.0 * 60).round().clamp(5, 180);
    return '$minutesRoute min en véhicule / pirogue';
  }

  /// Trie une liste de sites touristiques du plus proche au plus éloigné
  static List<Patrimoine> trierParProximite({
    required List<Patrimoine> sites,
    required double userLat,
    required double userLon,
  }) {
    final copie = List<Patrimoine>.from(sites);
    copie.sort((a, b) {
      final distA = calculerDistanceKm(
        lat1: userLat,
        lon1: userLon,
        lat2: a.latitude,
        lon2: a.longitude,
      );
      final distB = calculerDistanceKm(
        lat1: userLat,
        lon1: userLon,
        lat2: b.latitude,
        lon2: b.longitude,
      );
      return distA.compareTo(distB);
    });
    return copie;
  }

  /// Génère l'URL officielle Google Maps Directions vers le site touristique
  static String genererLienGoogleMaps({
    required double departLat,
    required double departLon,
    required double destLat,
    required double destLon,
  }) {
    return 'https://www.google.com/maps/dir/?api=1&origin=$departLat,$departLon&destination=$destLat,$destLon&travelmode=driving';
  }

  static double _degresEnRadians(double degres) {
    return degres * (pi / 180.0);
  }
}
