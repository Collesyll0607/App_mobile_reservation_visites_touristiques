import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/avis.dart';

/// Service de Gestion des Avis et Évaluations connecté à MySQL (ms-patrimoine)
/// Responsable : Collé SYLL (Pôle 1 - Module Avis & Notes)
class ReviewsService {
  static const String _storageKey = 'colle_reviews_data';
  static const String _apiAvisBase = 'http://127.0.0.1:8081/api/avis';

  static final List<Avis> _initialReviews = [
    const Avis(
      id: 1,
      patrimoineId: 1,
      auteur: 'Awa Diop',
      note: 5,
      commentaire:
          'Magnifique découverte au cœur de Ziguinchor, un lieu chargé d\'histoire !',
      datePublication: '02/11/2026',
    ),
    const Avis(
      id: 2,
      patrimoineId: 4,
      auteur: 'Jean-Marc Faye',
      note: 5,
      commentaire:
          'L\'église bretonne de Carabane et l\'accueil sur l\'île sont exceptionnels.',
      datePublication: '05/11/2026',
    ),
  ];

  /// Récupère les avis associés à un site touristique donné (depuis MySQL puis Fallback local)
  static Future<List<Avis>> getReviewsForSite(int patrimoineId) async {
    try {
      final resp = await http
          .get(Uri.parse('$_apiAvisBase/site/$patrimoineId'))
          .timeout(const Duration(seconds: 2));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>;
        return decoded.map((m) {
          final map = m as Map<String, dynamic>;
          return Avis(
            id: (map['id'] ?? 0) as int,
            patrimoineId: (map['patrimoineId'] ?? 0) as int,
            auteur: (map['auteur'] ?? 'Visiteur').toString(),
            note: (map['note'] ?? 5) as int,
            commentaire: (map['commentaire'] ?? '').toString(),
            datePublication: (map['datePublication'] ?? '').toString(),
          );
        }).toList();
      }
    } catch (_) {}

    final all = await _loadAllReviews();
    return all.where((r) => r.patrimoineId == patrimoineId).toList();
  }

  /// Calcule la moyenne dynamique des notes pour un site
  static Future<double> getAverageRating(
      int patrimoineId, double defaultRating) async {
    final siteReviews = await getReviewsForSite(patrimoineId);
    if (siteReviews.isEmpty) return defaultRating;
    final sum = siteReviews.fold<int>(0, (acc, item) => acc + item.note);
    return double.parse((sum / siteReviews.length).toStringAsFixed(1));
  }

  /// Ajoute un nouvel avis sur un site touristique (Enregistre dans MySQL table avis_mobile)
  static Future<Avis> addReview({
    required int patrimoineId,
    required String auteur,
    required int note,
    required String commentaire,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final payload = {
      'patrimoineId': patrimoineId,
      'auteur': auteur.trim().isEmpty ? 'Visiteur Anonyme' : auteur.trim(),
      'note': note.clamp(1, 5),
      'commentaire': commentaire.trim(),
      'datePublication': dateStr,
    };

    try {
      final resp = await http
          .post(
            Uri.parse(_apiAvisBase),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 2));
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final saved =
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        return Avis(
          id: (saved['id'] ?? 1) as int,
          patrimoineId: (saved['patrimoineId'] ?? patrimoineId) as int,
          auteur: (saved['auteur'] ?? payload['auteur']).toString(),
          note: (saved['note'] ?? note) as int,
          commentaire: (saved['commentaire'] ?? commentaire).toString(),
          datePublication: (saved['datePublication'] ?? dateStr).toString(),
        );
      }
    } catch (_) {}

    final all = await _loadAllReviews();
    final newReview = Avis(
      id: now.millisecondsSinceEpoch % 100000,
      patrimoineId: patrimoineId,
      auteur: payload['auteur'] as String,
      note: payload['note'] as int,
      commentaire: payload['commentaire'] as String,
      datePublication: dateStr,
    );

    all.insert(0, newReview);
    final prefs = await SharedPreferences.getInstance();
    final encoded = all
        .map((a) => {
              'id': a.id,
              'patrimoineId': a.patrimoineId,
              'auteur': a.auteur,
              'note': a.note,
              'commentaire': a.commentaire,
              'datePublication': a.datePublication,
            })
        .toList();
    await prefs.setString(_storageKey, jsonEncode(encoded));
    return newReview;
  }

  static Future<List<Avis>> _loadAllReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return List<Avis>.from(_initialReviews);
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((m) {
      final map = m as Map<String, dynamic>;
      return Avis(
        id: map['id'] ?? 0,
        patrimoineId: map['patrimoineId'] ?? 0,
        auteur: map['auteur'] ?? 'Visiteur',
        note: map['note'] ?? 5,
        commentaire: map['commentaire'] ?? '',
        datePublication: map['datePublication'] ?? '',
      );
    }).toList();
  }
}
