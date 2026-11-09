import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/avis.dart';

/// Service de Gestion des Avis et Évaluations des Sites Touristiques
/// Responsable : Collé SYLL (Pôle 1 - Module Avis & Notes)
class ReviewsService {
  static const String _storageKey = 'colle_reviews_data';

  static final List<Avis> _initialReviews = [
    const Avis(
      id: 1,
      patrimoineId: 1,
      auteur: 'Awa Diop',
      note: 5,
      commentaire:
          'Magnifique traversée en pirogue vers Carabane, un lieu chargé d\'histoire !',
      datePublication: '02/11/2026',
    ),
    const Avis(
      id: 2,
      patrimoineId: 1,
      auteur: 'Jean-Marc Faye',
      note: 5,
      commentaire:
          'L\'église bretonne et l\'accueil sur l\'île sont exceptionnels.',
      datePublication: '05/11/2026',
    ),
    const Avis(
      id: 3,
      patrimoineId: 2,
      auteur: 'Fatou Sagna',
      note: 5,
      commentaire:
          'Les cases à impluvium d\'Enampore montrent tout le génie architectural Diola.',
      datePublication: '04/11/2026',
    ),
    const Avis(
      id: 4,
      patrimoineId: 3,
      auteur: 'Ibrahima Badiane',
      note: 5,
      commentaire:
          'Un lieu de recueillement très émouvant et très bien entretenu sur le quai de Ziguinchor.',
      datePublication: '06/11/2026',
    ),
  ];

  /// Récupère les avis associés à un site touristique donné
  static Future<List<Avis>> getReviewsForSite(int patrimoineId) async {
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

  /// Ajoute un nouvel avis sur un site touristique
  static Future<Avis> addReview({
    required int patrimoineId,
    required String auteur,
    required int note,
    required String commentaire,
  }) async {
    final all = await _loadAllReviews();
    final now = DateTime.now();
    final newReview = Avis(
      id: now.millisecondsSinceEpoch % 100000,
      patrimoineId: patrimoineId,
      auteur: auteur.trim().isEmpty ? 'Visiteur Anonyme' : auteur.trim(),
      note: note.clamp(1, 5),
      commentaire: commentaire.trim(),
      datePublication:
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
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
