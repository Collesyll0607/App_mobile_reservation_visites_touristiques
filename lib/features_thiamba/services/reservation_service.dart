import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/reservation.dart';

/// Service de gestion des réservations connecté à MySQL (via ms-patrimoine /api/reservations)
/// avec synchronisation locale SharedPreferences pour le mode hors-ligne.
class ReservationService {
  static const String _storageKey = 'pole2_reservations';
  static const List<String> _candidateBaseUrls = [
    'http://127.0.0.1:8081/api/reservations',
    'http://10.0.2.2:8081/api/reservations',
  ];

  // Singleton
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  // ─── LECTURE ──────────────────────────────────────────────────────────────

  /// Charge les réservations depuis l'API Spring Boot / MySQL,
  /// puis met à jour le cache local. Bascule en mode local si le serveur est éteint.
  Future<List<Reservation>> loadAll() async {
    for (final baseUrl in _candidateBaseUrls) {
      try {
        final resp = await http
            .get(Uri.parse(baseUrl))
            .timeout(const Duration(seconds: 2));
        if (resp.statusCode == 200) {
          final decoded =
              jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>;
          final list = decoded
              .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
              .toList();
          await _persistLocal(list);
          return list;
        }
      } catch (_) {
        // Test de l'URL suivante ou bascule locale
      }
    }
    return await _loadLocal();
  }

  /// Charge une seule réservation par son [codeReservation].
  Future<Reservation?> loadByCode(String codeReservation) async {
    final all = await loadAll();
    try {
      return all.firstWhere((r) => r.codeReservation == codeReservation);
    } catch (_) {
      return null;
    }
  }

  /// Charge toutes les réservations filtrées par statut.
  Future<List<Reservation>> loadByStatut(String statut) async {
    final all = await loadAll();
    return all.where((r) => r.statut == statut).toList();
  }

  /// Charge toutes les réservations associées à un guide.
  Future<List<Reservation>> loadByGuide(String nomGuide) async {
    final all = await loadAll();
    return all.where((r) => r.nomGuide == nomGuide).toList();
  }

  // ─── ÉCRITURE ─────────────────────────────────────────────────────────────

  /// Enregistre la réservation dans MySQL (table reservations_mobile) ET en cache local.
  Future<bool> save(Reservation reservation) async {
    Reservation savedToStore = reservation;

    for (final baseUrl in _candidateBaseUrls) {
      try {
        final resp = await http
            .post(
              Uri.parse(baseUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(reservation.toJson()),
            )
            .timeout(const Duration(seconds: 3));

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          final map =
              jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
          savedToStore = Reservation.fromJson(map);
          break;
        }
      } catch (_) {
        // Essai URL suivante ou sauvegarde locale seule
      }
    }

    return await _saveLocal(savedToStore);
  }

  // ─── MISE À JOUR DE STATUT ────────────────────────────────────────────────

  /// Met à jour le statut d'une réservation dans MySQL et en local.
  Future<bool> updateStatut(
      String codeReservation, String nouveauStatut) async {
    bool savedInBackend = false;

    for (final baseUrl in _candidateBaseUrls) {
      try {
        final resp = await http
            .put(
              Uri.parse('$baseUrl/$codeReservation/statut'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'statut': nouveauStatut}),
            )
            .timeout(const Duration(seconds: 3));

        if (resp.statusCode == 200) {
          savedInBackend = true;
          final map =
              jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
          await _saveLocal(Reservation.fromJson(map));
          break;
        }
      } catch (_) {}
    }

    if (savedInBackend) return true;

    try {
      final List<Reservation> all = await _loadLocal();
      final int index = all.indexWhere(
        (r) => r.codeReservation == codeReservation,
      );
      if (index < 0) return false;
      all[index] = all[index].copyWith(statut: nouveauStatut);
      return await _persistLocal(all);
    } catch (_) {
      return false;
    }
  }

  // ─── SUPPRESSION ──────────────────────────────────────────────────────────

  Future<bool> delete(String codeReservation) async {
    for (final baseUrl in _candidateBaseUrls) {
      try {
        final resp = await http
            .delete(Uri.parse('$baseUrl/$codeReservation'))
            .timeout(const Duration(seconds: 2));
        if (resp.statusCode == 204 || resp.statusCode == 200) {
          break;
        }
      } catch (_) {}
    }

    try {
      final List<Reservation> all = await _loadLocal();
      final int countBefore = all.length;
      all.removeWhere((r) => r.codeReservation == codeReservation);
      if (all.length == countBefore) return false;
      return await _persistLocal(all);
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (_) {
      return false;
    }
  }

  // ─── CACHE LOCAL (HORS-LIGNE) ─────────────────────────────────────────────

  Future<List<Reservation>> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_storageKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await _clearCorruptedData();
      return [];
    }
  }

  Future<bool> _saveLocal(Reservation reservation) async {
    try {
      final List<Reservation> all = await _loadLocal();
      final int existingIndex = all.indexWhere(
        (r) =>
            r.codeReservation == reservation.codeReservation ||
            r.id == reservation.id,
      );
      if (existingIndex >= 0) {
        all[existingIndex] = reservation;
      } else {
        all.insert(0, reservation);
      }
      return await _persistLocal(all);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _persistLocal(List<Reservation> reservations) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      reservations.map((r) => r.toJson()).toList(),
    );
    return await prefs.setString(_storageKey, encoded);
  }

  Future<void> _clearCorruptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}
