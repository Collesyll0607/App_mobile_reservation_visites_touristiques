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
    return Patrimoine(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      historique: json['historique'] ?? '',
      categorie: json['categorie'] ?? 'PATRIMOINE',
      localisation: json['localisation'] ?? 'Ziguinchor',
      latitude: (json['latitude'] ?? 12.5833).toDouble(),
      longitude: (json['longitude'] ?? -16.2719).toDouble(),
      tarifEntree: (json['tarifEntree'] ?? 2000).toDouble(),
      horairesOuverture: json['horairesOuverture'] ?? '08h00 - 18h00',
      imageUrl: json['imageUrl'] ?? '',
      noteMoyenne: (json['noteMoyenne'] ?? 4.7).toDouble(),
    );
  }
}
