/// Modèle représentant un utilisateur (Touriste ou Guide Touristique)
class Utilisateur {
  final int id;
  final String nomComplet;
  final String email;
  final String telephone;
  final String role; // TOURISTE, GUIDE, ADMIN
  final String? languesParlees;
  final double? tarifGuideJournalier;

  const Utilisateur({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.telephone,
    required this.role,
    this.languesParlees,
    this.tarifGuideJournalier,
  });
}
