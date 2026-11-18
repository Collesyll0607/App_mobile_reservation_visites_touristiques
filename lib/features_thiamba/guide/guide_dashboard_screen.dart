import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/models/reservation.dart';
import '../../core/models/utilisateur.dart';
import '../services/reservation_service.dart';

/// Modèle pour le filtre de profil dans l'Espace Guide / Administration
class ProfilVueOption {
  final String code; // 'GLOBAL', 'LIBRE', ou email du guide
  final String nomAffichage;
  final String sousTitre;
  final IconData icone;
  final Utilisateur? guideAssocie;

  const ProfilVueOption({
    required this.code,
    required this.nomAffichage,
    required this.sousTitre,
    required this.icone,
    this.guideAssocie,
  });
}

/// Écran du Tableau de Bord de l'Espace Guide & Administration du Site
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)
class GuideDashboardScreen extends StatefulWidget {
  final Utilisateur? guideInitial;

  const GuideDashboardScreen({
    super.key,
    this.guideInitial,
  });

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  final ReservationService _reservationService = ReservationService();

  late List<ProfilVueOption> _optionsProfil;
  late ProfilVueOption _profilActif;

  List<Reservation> _toutesLesVisites = [];
  List<Reservation> _visitesAffichees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialiserOptionsProfil();
    _chargerVisites();
  }

  void _initialiserOptionsProfil() {
    _optionsProfil = [
      const ProfilVueOption(
        code: 'GLOBAL',
        nomAffichage: '🏛️ Administration du Site (Vue Globale)',
        sousTitre: 'Supervision de toutes les arrivées (guidées & libres)',
        icone: Icons.admin_panel_settings,
      ),
      const ProfilVueOption(
        code: 'LIBRE',
        nomAffichage: '🚶 Visites Libres (Guichet / Sans guide dédié)',
        sousTitre: 'Toutes les entrées prises sans accompagnateur',
        icone: Icons.directions_walk,
      ),
      ...ApiConfig.guidesDisponibles.map(
        (g) => ProfilVueOption(
          code: g.email,
          nomAffichage: '👤 ${g.nomComplet} (Guide officiel)',
          sousTitre: '${g.telephone} • ${(g.tarifGuideJournalier ?? 0).toInt()} FCFA/j',
          icone: Icons.person_pin,
          guideAssocie: g,
        ),
      ),
    ];

    // Par défaut : Vue Globale Administration pour tout voir sans restriction
    _profilActif = _optionsProfil.first;
  }

  Future<void> _chargerVisites() async {
    setState(() => _isLoading = true);

    final all = await _reservationService.loadAll();

    if (!mounted) return;

    setState(() {
      _toutesLesVisites = all;
      _filtrerVisites();
      _isLoading = false;
    });
  }

  void _filtrerVisites() {
    if (_profilActif.code == 'GLOBAL') {
      // Vue globale : absolument toutes les réservations
      _visitesAffichees = List.from(_toutesLesVisites);
    } else if (_profilActif.code == 'LIBRE') {
      // Visites libres uniquement (aucun guide dédié)
      _visitesAffichees = _toutesLesVisites.where((r) {
        final guide = (r.nomGuide ?? '').trim().toLowerCase();
        return guide.isEmpty ||
            guide == 'visite libre' ||
            guide.contains('sans guide') ||
            guide == 'null';
      }).toList();
    } else {
      // Guide individuel
      final guideNom = (_profilActif.guideAssocie?.nomComplet ?? '').trim().toLowerCase();
      _visitesAffichees = _toutesLesVisites.where((r) {
        final guide = (r.nomGuide ?? '').trim().toLowerCase();
        return guide == guideNom || guide.contains(guideNom) || guideNom.contains(guide);
      }).toList();
    }
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return const Color(0xFF145C42); // Vert émeraude
      case 'EN_ATTENTE':
        return const Color(0xFFC8754D); // Terracotta
      case 'ANNULEE':
        return Colors.red.shade700;
      case 'EFFECTUEE':
        return const Color(0xFF007A78); // Turquoise Casamance
      default:
        return Colors.blueGrey;
    }
  }

  String _nomStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return 'Confirmée';
      case 'EN_ATTENTE':
        return 'En attente';
      case 'ANNULEE':
        return 'Annulée';
      case 'EFFECTUEE':
        return 'Effectuée';
      default:
        return statut;
    }
  }

  String _libellePaiement(Reservation r) {
    if (r.modePaiement == 'PAYE_ESPECES_SUR_PLACE') {
      return 'Espèces (Encaissé sur place)';
    }
    if (r.modePaiement == 'SUR_PLACE') {
      return r.statut == 'EFFECTUEE'
          ? 'Espèces (Encaissé au guichet)'
          : 'Sur place (À encaisser)';
    }
    if (r.modePaiement == 'WAVE') return 'Wave (Payé en ligne)';
    if (r.modePaiement == 'ORANGE_MONEY') return 'Orange Money (Payé)';
    return r.modePaiement;
  }

  /// Dialogue pour valider un billet par saisie/scan de son QR Code
  Future<void> _ouvrirValidationBillet([String? codePreRempli]) async {
    final controller = TextEditingController(text: codePreRempli ?? '');
    String? messageErreur;
    Reservation? reservationTrouvee;
    bool enRecherche = false;

    if (codePreRempli != null && codePreRempli.isNotEmpty) {
      reservationTrouvee = await _reservationService.loadByCode(codePreRempli.trim());
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bool estSurPlace = reservationTrouvee?.modePaiement == 'SUR_PLACE';
          final bool dejaPayeEnLigne = reservationTrouvee?.modePaiement == 'WAVE' ||
              reservationTrouvee?.modePaiement == 'ORANGE_MONEY' ||
              reservationTrouvee?.modePaiement == 'PAYE_ESPECES_SUR_PLACE';
          final bool estDejaEffectuee = reservationTrouvee?.statut == 'EFFECTUEE';

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Color(0xFF145C42)),
                SizedBox(width: 10),
                Text(
                  'Contrôle de Billet QR',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entrez le code de réservation présent sur le pass du visiteur :',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Référence du billet',
                            hintText: 'Ex: ZIG-32005',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.confirmation_number_outlined),
                            isDense: true,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (val) async {
                            final code = val.trim();
                            if (code.isEmpty) return;
                            setDialogState(() => enRecherche = true);
                            final res = await _reservationService.loadByCode(code);
                            setDialogState(() {
                              enRecherche = false;
                              reservationTrouvee = res;
                              messageErreur = res == null
                                  ? 'Aucun billet trouvé pour "$code".'
                                  : null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF145C42),
                        ),
                        onPressed: () async {
                          final code = controller.text.trim();
                          if (code.isEmpty) {
                            setDialogState(() {
                              messageErreur = 'Veuillez saisir un code de réservation.';
                              reservationTrouvee = null;
                            });
                            return;
                          }
                          setDialogState(() => enRecherche = true);
                          final res = await _reservationService.loadByCode(code);
                          setDialogState(() {
                            enRecherche = false;
                            reservationTrouvee = res;
                            messageErreur = res == null
                                ? 'Aucun billet trouvé pour "$code".'
                                : null;
                          });
                        },
                        icon: enRecherche
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search, color: Colors.white),
                        tooltip: 'Vérifier ce billet',
                      ),
                    ],
                  ),

                  if (messageErreur != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              messageErreur!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (reservationTrouvee != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9DDC7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF145C42), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reservationTrouvee!.nomPatrimoine,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Text('👤 Touriste : ${reservationTrouvee!.nomTouriste}'),
                          Text('👥 Participants : ${reservationTrouvee!.nombrePersonnes} personne(s)'),
                          Text('📅 Date : ${reservationTrouvee!.dateVisite} (${reservationTrouvee!.creneauHoraire})'),
                          Text('💰 Montant : ${reservationTrouvee!.montantTotal.toInt()} FCFA'),
                          Text('🧭 Guide : ${reservationTrouvee!.nomGuide ?? "Visite libre (Guichet)"}'),
                          Text(
                            '📌 Statut actuel : ${_nomStatut(reservationTrouvee!.statut)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _couleurStatut(reservationTrouvee!.statut),
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (estDejaEffectuee) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFB2DFDB)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.task_alt, color: Color(0xFF007A78), size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Cette visite a déjà été effectuée et validée au guichet.',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF007A78), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (estSurPlace) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFEEBA)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.payments_outlined, color: Color(0xFF856404), size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'PAIEMENT EN ESPÈCES SUR PLACE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF856404),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Montant à encaisser : ${reservationTrouvee!.montantTotal.toInt()} FCFA',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF533F03),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Veuillez percevoir les espèces au guichet avant de valider l\'entrée.',
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF856404)),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (dejaPayeEnLigne) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFC8E6C9)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Paiement certifié : ${reservationTrouvee!.montantTotal.toInt()} FCFA réglés via ${_libellePaiement(reservationTrouvee!)}.',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Fermer'),
              ),
              if (reservationTrouvee != null && !estDejaEffectuee)
                ElevatedButton.icon(
                  onPressed: () async {
                    if (reservationTrouvee!.statut == 'ANNULEE') {
                      setDialogState(() {
                        messageErreur = 'Billet refusé : cette réservation a été ANNULÉE.';
                      });
                      return;
                    }

                    final String nouveauPaiement = (reservationTrouvee!.modePaiement == 'SUR_PLACE')
                        ? 'PAYE_ESPECES_SUR_PLACE'
                        : reservationTrouvee!.modePaiement;

                    // Nom du guide valideur
                    final String guideValideur = reservationTrouvee!.nomGuide ?? 'Guide Officiel (PIN 2026)';

                    final bool succes = await _reservationService.updateStatut(
                      reservationTrouvee!.codeReservation,
                      'EFFECTUEE',
                      nouveauModePaiement: nouveauPaiement,
                      nomGuideValideur: guideValideur,
                    );

                    if (succes) {
                      await _chargerVisites();
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);

                      final messageNotification = (reservationTrouvee!.modePaiement == 'SUR_PLACE')
                          ? '✅ Billet validé ! Paiement de ${reservationTrouvee!.montantTotal.toInt()} FCFA encaissé en espèces au guichet.'
                          : '✅ Billet ${reservationTrouvee!.codeReservation} validé avec succès ! Visite marquée EFFECTUÉE.';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF145C42),
                          duration: const Duration(seconds: 4),
                          content: Text(messageNotification),
                        ),
                      );
                    } else {
                      setDialogState(() {
                        messageErreur = 'Erreur lors de l\'enregistrement de la validation.';
                      });
                    }
                  },
                  icon: Icon(estSurPlace ? Icons.payments : Icons.check_circle),
                  label: Text(
                    estSurPlace
                        ? 'Encaisser ${reservationTrouvee!.montantTotal.toInt()} F & Valider'
                        : 'Valider l\'entrée',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: estSurPlace ? const Color(0xFFC8754D) : const Color(0xFF145C42),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              if (reservationTrouvee != null && estDejaEffectuee)
                OutlinedButton.icon(
                  onPressed: () async {
                    final String initPaiement = reservationTrouvee!.modePaiement.contains('ESPECES')
                        ? 'SUR_PLACE'
                        : reservationTrouvee!.modePaiement;

                    final bool succes = await _reservationService.updateStatut(
                      reservationTrouvee!.codeReservation,
                      'EN_ATTENTE',
                      nouveauModePaiement: initPaiement,
                    );

                    if (succes) {
                      await _chargerVisites();
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFC8754D),
                          content: Text('Billet ${reservationTrouvee!.codeReservation} remis "En attente" pour nouveau test.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Remettre en attente (Test)'),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Dialogue de détails complets d'une visite pour le guide
  void _afficherDetailsVisite(Reservation r) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(r.nomPatrimoine, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Code Billet', r.codeReservation),
              _detailRow('Touriste', r.nomTouriste),
              _detailRow('Date visite', r.dateVisite),
              _detailRow('Créneau', r.creneauHoraire),
              _detailRow('Participants', '${r.nombrePersonnes} personne(s)'),
              _detailRow('Montant Total', '${r.montantTotal.toInt()} FCFA'),
              _detailRow('Paiement', _libellePaiement(r)),
              _detailRow('Guide désigné', r.nomGuide ?? 'Visite libre (Guichet)'),
              _detailRow('Statut', _nomStatut(r.statut)),
            ],
          ),
        ),
        actions: [
          if (r.statut == 'CONFIRMEE' || (r.statut == 'EN_ATTENTE' && r.modePaiement == 'SUR_PLACE'))
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _ouvrirValidationBillet(r.codeReservation);
              },
              icon: Icon(r.modePaiement == 'SUR_PLACE' ? Icons.payments : Icons.check_circle),
              label: Text(
                r.modePaiement == 'SUR_PLACE'
                    ? 'Encaisser ${r.montantTotal.toInt()} F & Valider'
                    : 'Valider ce billet',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: r.modePaiement == 'SUR_PLACE'
                    ? const Color(0xFFC8754D)
                    : const Color(0xFF145C42),
                foregroundColor: Colors.white,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteVisite(Reservation r) {
    final couleur = _couleurStatut(r.statut);
    final bool peutEtreValidee = r.statut == 'CONFIRMEE' ||
        (r.statut == 'EN_ATTENTE' && r.modePaiement == 'SUR_PLACE');
    final bool estSurPlace = r.modePaiement == 'SUR_PLACE' && r.statut != 'EFFECTUEE';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    r.nomPatrimoine,
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: couleur.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _nomStatut(r.statut),
                    style: TextStyle(color: couleur, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Color(0xFF145C42)),
                const SizedBox(width: 6),
                Text('${r.dateVisite} (${r.creneauHoraire})', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Visiteur : ${r.nomTouriste} (${r.nombrePersonnes} pers.)', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Guide : ${r.nomGuide ?? "Visite libre (Guichet)"}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_libellePaiement(r)} • ${r.montantTotal.toInt()} FCFA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: estSurPlace ? FontWeight.bold : FontWeight.normal,
                      color: estSurPlace ? const Color(0xFFC8754D) : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Billet : ${r.codeReservation}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _afficherDetailsVisite(r),
                  child: const Text('Détails'),
                ),
                if (peutEtreValidee) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _ouvrirValidationBillet(r.codeReservation),
                    icon: Icon(estSurPlace ? Icons.payments : Icons.check, size: 18),
                    label: Text(estSurPlace ? 'Encaisser & Valider' : 'Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estSurPlace ? const Color(0xFFC8754D) : const Color(0xFF145C42),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcul des statistiques selon la vue sélectionnée
    final List<Reservation> sourceStats = _visitesAffichees;

    final int nbTotal = sourceStats.length;
    final int nbAvenir = sourceStats.where((r) => r.statut == 'CONFIRMEE' || r.statut == 'EN_ATTENTE').length;
    final int nbEffectuees = sourceStats.where((r) => r.statut == 'EFFECTUEE').length;

    // Calcul du total des espèces perçues au guichet sur ce périmètre
    final double totalEspeces = sourceStats
        .where((r) => r.modePaiement == 'PAYE_ESPECES_SUR_PLACE' || (r.modePaiement == 'SUR_PLACE' && r.statut == 'EFFECTUEE'))
        .fold(0.0, (somme, r) => somme + r.montantTotal);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F1),
      appBar: AppBar(
        title: const Text('Espace Guide & Administration'),
        backgroundColor: const Color(0xFF145C42),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualiser les données',
            icon: const Icon(Icons.refresh),
            onPressed: _chargerVisites,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. En-tête Espace Guide Officiel & Contrôle
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF145C42),
                      foregroundColor: Colors.white,
                      radius: 24,
                      child: Icon(Icons.verified_user_rounded, size: 28),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Poste de Contrôle & Validation',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF145C42),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Session Guide Officiel active • Code PIN 2026',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Bouton principal de scan / contrôle de billet QR
            ElevatedButton.icon(
              onPressed: () => _ouvrirValidationBillet(),
              icon: const Icon(Icons.qr_code_scanner, size: 26),
              label: const Text(
                'Contrôler & Valider un Billet QR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF145C42),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Compteurs de statistiques avec traçabilité des espèces
            Row(
              children: [
                Expanded(
                  child: _statCard('Total visites', '$nbTotal', Colors.blueGrey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard('À venir', '$nbAvenir', const Color(0xFFC8754D)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard('Effectuées', '$nbEffectuees', const Color(0xFF145C42)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Carte de traçabilité de caisse espèces
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Color(0xFF8D6E63)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Traçabilité Caisse Espèces (Toutes les arrivées)',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${totalEspeces.toInt()} FCFA encaissés',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Titre de la liste
            const Text(
              'Planning et Arrivées des Visiteurs',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 5. Liste des visites
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_visitesAffichees.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.event_available, size: 50, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Aucune réservation enregistrée pour le moment.\nUtilisez le bouton ci-dessus pour contrôler un billet QR.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _visitesAffichees.length,
                itemBuilder: (context, index) => _carteVisite(_visitesAffichees[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String titre, String valeur, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: couleur.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text(
            valeur,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titre,
            style: TextStyle(fontSize: 12, color: couleur, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
