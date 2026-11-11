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
      id: (json['id'] as num?)?.toInt() ?? 0,
      patrimoineId: (json['patrimoineId'] as num?)?.toInt() ?? 0,
      nomPatrimoine: (json['nomPatrimoine'] ?? '').toString(),
      nomTouriste: (json['nomTouriste'] ?? '').toString(),
      dateVisite: (json['dateVisite'] ?? '').toString(),
      creneauHoraire: (json['creneauHoraire'] ?? '09h00 - 11h00').toString(),
      nombrePersonnes: (json['nombrePersonnes'] as num?)?.toInt() ?? 1,
      nomGuide: json['nomGuide']?.toString(),
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      modePaiement: (json['modePaiement'] ?? 'WAVE').toString(),
      statut: (json['statut'] ?? 'CONFIRMEE').toString(),
      codeReservation: (json['codeReservation'] ?? 'ZIG-2026-001').toString(),
    );
  }

  /// Sérialise la réservation en Map JSON pour la persistance locale (SharedPreferences).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrimoineId': patrimoineId,
      'nomPatrimoine': nomPatrimoine,
      'nomTouriste': nomTouriste,
      'dateVisite': dateVisite,
      'creneauHoraire': creneauHoraire,
      'nombrePersonnes': nombrePersonnes,
      'nomGuide': nomGuide,
      'montantTotal': montantTotal,
      'modePaiement': modePaiement,
      'statut': statut,
      'codeReservation': codeReservation,
    };
  }

  /// Retourne une copie de la réservation avec les champs modifiés.
  /// Utile pour changer le statut (ex : EN_ATTENTE → ANNULEE) sans recréer l'objet.
  Reservation copyWith({
    int? id,
    int? patrimoineId,
    String? nomPatrimoine,
    String? nomTouriste,
    String? dateVisite,
    String? creneauHoraire,
    int? nombrePersonnes,
    String? nomGuide,
    double? montantTotal,
    String? modePaiement,
    String? statut,
    String? codeReservation,
  }) {
    return Reservation(
      id: id ?? this.id,
      patrimoineId: patrimoineId ?? this.patrimoineId,
      nomPatrimoine: nomPatrimoine ?? this.nomPatrimoine,
      nomTouriste: nomTouriste ?? this.nomTouriste,
      dateVisite: dateVisite ?? this.dateVisite,
      creneauHoraire: creneauHoraire ?? this.creneauHoraire,
      nombrePersonnes: nombrePersonnes ?? this.nombrePersonnes,
      nomGuide: nomGuide ?? this.nomGuide,
      montantTotal: montantTotal ?? this.montantTotal,
      modePaiement: modePaiement ?? this.modePaiement,
      statut: statut ?? this.statut,
      codeReservation: codeReservation ?? this.codeReservation,
    );
  }
}
