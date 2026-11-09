/// Modèle représentant un avis laissé par un touriste après une visite
class Avis {
  final int id;
  final int patrimoineId;
  final String auteur;
  final int note; // 1 à 5 étoiles
  final String commentaire;
  final String datePublication;

  const Avis({
    required this.id,
    required this.patrimoineId,
    required this.auteur,
    required this.note,
    required this.commentaire,
    required this.datePublication,
  });
}
