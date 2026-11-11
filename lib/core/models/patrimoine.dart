/// Modèle représentant un site touristique / patrimonial de Ziguinchor & Casamance
class Patrimoine {
  final int id;
  final String nom;
  final String description;
  final String historique;
  final String categorie; // MONUMENT, NATURE, MUSEE, ARCHITECTURE
  final String localisation;
  final double latitude;
  final double longitude;
  final double tarifEntree;
  final String horairesOuverture;
  final String imageUrl;
  final double noteMoyenne;

  const Patrimoine({
    required this.id,
    required this.nom,
    required this.description,
    required this.historique,
    required this.categorie,
    required this.localisation,
    required this.latitude,
    required this.longitude,
    required this.tarifEntree,
    required this.horairesOuverture,
    required this.imageUrl,
    this.noteMoyenne = 4.7,
  });

  factory Patrimoine.fromJson(Map<String, dynamic> json) {
    final nom = (json['nom'] ?? json['nomPatrimoine'] ?? '').toString();
    String categorie = (json['categorie'] ?? '').toString();
    if (categorie.isEmpty) {
      final lower = nom.toLowerCase();
      if (lower.contains('artisan')) {
        categorie = 'ARTISANAT';
      } else if (lower.contains('alliance') || lower.contains('culture')) {
        categorie = 'CULTURE';
      } else if (lower.contains('impluvium') || lower.contains('case')) {
        categorie = 'ARCHITECTURE';
      } else if (lower.contains('mémorial') ||
          lower.contains('memorial') ||
          lower.contains('musée') ||
          lower.contains('musee')) {
        categorie = 'MUSEE';
      } else if (lower.contains('plage') || lower.contains('cap skirring')) {
        categorie = 'PLAGES';
      } else if (lower.contains('port') ||
          lower.contains('bolong') ||
          lower.contains('mangrove') ||
          lower.contains('forêt') ||
          lower.contains('foret') ||
          lower.contains('réserve') ||
          lower.contains('reserve')) {
        categorie = 'NATURE';
      } else {
        categorie = 'MONUMENT';
      }
    }

    return Patrimoine(
      id: (json['id'] ?? 0) as int,
      nom: nom,
      description:
          (json['description'] ?? json['descriptionPatrimoine'] ?? '').toString(),
      historique:
          (json['historique'] ?? json['historiquePatrimoine'] ?? '').toString(),
      categorie: categorie,
      localisation: (json['localisation'] ??
              json['adressePatrimoine'] ??
              'Ziguinchor')
          .toString(),
      latitude:
          ((json['latitude'] ?? json['latitudePatrimoine'] ?? 12.5833) as num)
              .toDouble(),
      longitude:
          ((json['longitude'] ?? json['longitudePatrimoine'] ?? -16.2719) as num)
              .toDouble(),
      tarifEntree: ((json['tarifEntree'] ?? 2000) as num).toDouble(),
      horairesOuverture:
          (json['horairesOuverture'] ?? '08h00 - 18h00').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      noteMoyenne: ((json['noteMoyenne'] ?? 4.8) as num).toDouble(),
    );
  }

  /// Sérialise le patrimoine en JSON pour la persistance locale des favoris (SharedPreferences).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'historique': historique,
      'categorie': categorie,
      'localisation': localisation,
      'latitude': latitude,
      'longitude': longitude,
      'tarifEntree': tarifEntree,
      'horairesOuverture': horairesOuverture,
      'imageUrl': imageUrl,
      'noteMoyenne': noteMoyenne,
    };
  }
}
