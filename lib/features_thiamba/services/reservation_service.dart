import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/reservation.dart';

/// Service de persistance locale des reservations (Pole 2 - Ndeye Thiamba FAYE)
///
/// Toutes les reservations sont stockees dans SharedPreferences sous forme
/// d'une liste JSON serialisee. La cle utilisee est [_storageKey].
///
/// Prevu pour fonctionner 100 % hors-ligne (sans backend Spring Boot).
/// Lorsque le backend sera disponible, ce service pourra etre remplace
/// ou complete par un appel HTTP tout en conservant la meme interface.
class ReservationService {
  // Cle de stockage
  static const String _storageKey = 'pole2_reservations';

  // Singleton
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  // ─── LECTURE ──────────────────────────────────────────────────────────────

  /// Charge toutes les reservations sauvegardees localement.
  /// Retourne une liste vide en cas d'erreur ou si aucune reservation n'existe.
  Future<List<Reservation>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_storageKey);

      if (rawJson == null || rawJson.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await _clearCorruptedData();
      return [];
    }
  }

  /// Charge une seule reservation par son [codeReservation].
  /// Retourne null si introuvable.
  Future<Reservation?> loadByCode(String codeReservation) async {
    final all = await loadAll();
    try {
      return all.firstWhere((r) => r.codeReservation == codeReservation);
    } catch (_) {
      return null;
    }
  }

  /// Charge toutes les reservations filtrees par statut.
  /// [statut] : 'EN_ATTENTE', 'CONFIRMEE', 'ANNULEE', 'EFFECTUEE'
  Future<List<Reservation>> loadByStatut(String statut) async {
    final all = await loadAll();
    return all.where((r) => r.statut == statut).toList();
  }

  /// Charge toutes les reservations associees a un guide (Espace Guide - Etape 5).
  Future<List<Reservation>> loadByGuide(String nomGuide) async {
    final all = await loadAll();
    return all.where((r) => r.nomGuide == nomGuide).toList();
  }

  // ─── ECRITURE ─────────────────────────────────────────────────────────────

  /// Sauvegarde une reservation (upsert par codeReservation).
  /// Si une reservation avec le meme code existe deja, elle est remplacee.
  /// Retourne true si la sauvegarde a reussi, false sinon.
  Future<bool> save(Reservation reservation) async {
    try {
      final List<Reservation> all = await loadAll();

      final int existingIndex = all.indexWhere(
        (r) =>
            r.codeReservation == reservation.codeReservation ||
            r.id == reservation.id,
      );

      if (existingIndex >= 0) {
        all[existingIndex] = reservation; // Mise a jour
      } else {
        all.add(reservation); // Nouvel ajout
      }

      return await _persist(all);
    } catch (e) {
      return false;
    }
  }

  // ─── MISE A JOUR DE STATUT ────────────────────────────────────────────────

  /// Met a jour le statut d'une reservation identifiee par [codeReservation].
  /// Retourne true si la mise a jour a reussi, false si introuvable ou erreur.
  Future<bool> updateStatut(String codeReservation, String nouveauStatut) async {
    try {
      final List<Reservation> all = await loadAll();
      final int index = all.indexWhere(
        (r) => r.codeReservation == codeReservation,
      );

      if (index < 0) return false;

      all[index] = all[index].copyWith(statut: nouveauStatut);
      return await _persist(all);
    } catch (e) {
      return false;
    }
  }

  // ─── SUPPRESSION ──────────────────────────────────────────────────────────

  /// Supprime definitivement une reservation par son [codeReservation].
  /// Pour annuler, preferer updateStatut(..., 'ANNULEE') pour garder l'historique.
  /// Retourne true si la suppression a reussi, false si introuvable ou erreur.
  Future<bool> delete(String codeReservation) async {
    try {
      final List<Reservation> all = await loadAll();
      final int countBefore = all.length;

      all.removeWhere((r) => r.codeReservation == codeReservation);

      if (all.length == countBefore) return false;

      return await _persist(all);
    } catch (e) {
      return false;
    }
  }

  /// Supprime TOUTES les reservations. Utiliser uniquement en developpement.
  Future<bool> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      return false;
    }
  }

  // ─── UTILITAIRES PRIVES ───────────────────────────────────────────────────

  /// Serialise la liste et l'ecrit dans SharedPreferences.
  Future<bool> _persist(List<Reservation> reservations) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      reservations.map((r) => r.toJson()).toList(),
    );
    return await prefs.setString(_storageKey, encoded);
  }

  /// Supprime la cle corrompue pour eviter de bloquer l'application.
  Future<void> _clearCorruptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {
      // Rien a faire
    }
  }
}
