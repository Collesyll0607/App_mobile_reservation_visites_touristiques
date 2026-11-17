import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/patrimoine.dart';

import '../../features_colle/auth/auth_service.dart';

/// Service de persistance locale des sites favoris (Pôle 2 - Ndeye Thiamba FAYE)
///
/// Stocke les sites favoris sous forme d'une liste JSON dans SharedPreferences
/// isolée par compte utilisateur connecté pour garantir l'indépendance des profils.
class FavoritesService {
  static const String _defaultStorageKey = 'pole2_favoris_sites';

  // Singleton
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  Future<String> _getStorageKey() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && user.email.isNotEmpty) {
      final sanitized = user.email.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
      return 'pole2_favoris_$sanitized';
    }
    return _defaultStorageKey;
  }

  /// Charge tous les sites favoris sauvegardés localement.
  /// Retourne une liste vide si aucun favori n'est présent ou en cas d'erreur.
  Future<List<Patrimoine>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getStorageKey();
      final String? rawJson = prefs.getString(key);

      if (rawJson == null || rawJson.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Patrimoine.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await _clearCorruptedData();
      return [];
    }
  }

  /// Vérifie si un site est déjà présent dans les favoris par son identifiant [siteId].
  Future<bool> isFavorite(int siteId) async {
    final all = await loadAll();
    return all.any((p) => p.id == siteId);
  }

  /// Ajoute un site touristique aux favoris.
  /// Évite les doublons : si le site est déjà présent (même id), il est mis à jour.
  /// Retourne true si l'opération a réussi, false sinon.
  Future<bool> addFavorite(Patrimoine site) async {
    try {
      final List<Patrimoine> all = await loadAll();

      final int existingIndex = all.indexWhere((p) => p.id == site.id);
      if (existingIndex >= 0) {
        all[existingIndex] = site; // Mise à jour sans doublon
      } else {
        all.add(site); // Ajout d'un nouveau favori
      }

      return await _persist(all);
    } catch (e) {
      return false;
    }
  }

  /// Retire un site des favoris à partir de son identifiant [siteId].
  /// Retourne true si le retrait a réussi, false sinon.
  Future<bool> removeFavorite(int siteId) async {
    try {
      final List<Patrimoine> all = await loadAll();
      final int countBefore = all.length;

      all.removeWhere((p) => p.id == siteId);

      if (all.length == countBefore) return false;

      return await _persist(all);
    } catch (e) {
      return false;
    }
  }

  /// Bascule l'état d'un favori : le retire s'il est présent, l'ajoute sinon.
  /// Retourne true si le site est maintenant dans les favoris, false s'il en a été retiré.
  Future<bool> toggleFavorite(Patrimoine site) async {
    final bool favori = await isFavorite(site.id);
    if (favori) {
      await removeFavorite(site.id);
      return false;
    } else {
      await addFavorite(site);
      return true;
    }
  }

  /// Supprime tous les favoris (pour tests et réinitialisation).
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getStorageKey();
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }

  // ─── UTILITAIRES PRIVÉS ───────────────────────────────────────────────────

  Future<bool> _persist(List<Patrimoine> sites) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getStorageKey();
    final String encoded = jsonEncode(sites.map((s) => s.toJson()).toList());
    return await prefs.setString(key, encoded);
  }

  Future<void> _clearCorruptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getStorageKey();
      await prefs.remove(key);
    } catch (_) {
      // Ignorer
    }
  }
}
