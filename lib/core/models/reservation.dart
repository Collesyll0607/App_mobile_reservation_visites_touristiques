/// Modèle représentant une Réservation de visite touristique
class Reservation {
  final int id;
  final int patrimoineId;
  final String nomPatrimoine;
  final String nomTouriste;
  final String dateVisite;
  final String creneauHoraire;
  final int nombrePersonnes;
  final String? nomGuide;
  final double montantTotal;
  final String modePaiement; // WAVE, ORANGE_MONEY, SUR_PLACE
  final String statut;       // EN_ATTENTE, CONFIRMEE, ANNULEE, EFFECTUEE
  final String codeReservation;

  const Reservation({
    required this.id,
    required this.patrimoineId,
    required this.nomPatrimoine,
    required this.nomTouriste,
    required this.dateVisite,
    required this.creneauHoraire,
    required this.nombrePersonnes,
    this.nomGuide,
    required this.montantTotal,
    required this.modePaiement,
    required this.statut,
    required this.codeReservation,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      patrimoineId: json['patrimoineId'] ?? 0,
      nomPatrimoine: json['nomPatrimoine'] ?? '',
      nomTouriste: json['nomTouriste'] ?? '',
      dateVisite: json['dateVisite'] ?? '',
      creneauHoraire: json['creneauHoraire'] ?? '09h00 - 11h00',
      nombrePersonnes: json['nombrePersonnes'] ?? 1,
      nomGuide: json['nomGuide'],
      montantTotal: (json['montantTotal'] ?? 0).toDouble(),
      modePaiement: json['modePaiement'] ?? 'WAVE',
      statut: json['statut'] ?? 'CONFIRMEE',
      codeReservation: json['codeReservation'] ?? 'ZIG-2026-001',
    );
  }
}
