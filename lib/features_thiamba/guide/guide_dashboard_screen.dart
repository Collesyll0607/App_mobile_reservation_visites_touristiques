import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/models/reservation.dart';
import '../../core/models/utilisateur.dart';
import '../services/reservation_service.dart';

/// Écran du Tableau de Bord de l'Espace Guide
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

  late Utilisateur _guideConnecte;
  List<Reservation> _visitesGuide = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _guideConnecte = widget.guideInitial ?? ApiConfig.guidesDisponibles.first;
    _chargerVisites();
  }

  Future<void> _chargerVisites() async {
    setState(() {
      _isLoading = true;
    });

    final all = await _reservationService.loadAll();

    if (!mounted) return;

    setState(() {
      // Filtrer les visites attribuées à ce guide (par nom ou toutes si non spécifié)
      _visitesGuide = all.where((r) => r.nomGuide == _guideConnecte.nomComplet).toList();
      _isLoading = false;
    });
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return Colors.green;
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ANNULEE':
        return Colors.red;
      case 'EFFECTUEE':
        return Colors.blue;
      default:
        return Colors.grey;
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

  /// Dialogue pour valider un billet par saisie/scan de son QR Code
  Future<void> _ouvrirValidationBillet([String? codePreRempli]) async {
    final controller = TextEditingController(text: codePreRempli ?? '');
    String? messageErreur;
    Reservation? reservationTrouvee;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Color(0xFF1B5E20)),
                SizedBox(width: 8),
                Text('Valider un Billet QR'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entrez ou collez le code de réservation présent sur le billet du touriste :',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Code de réservation (ex. ZIG-...)',
                      hintText: 'Ex: ZIG-2026-001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    textCapitalization: TextCapitalization.characters,
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
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservationTrouvee!.nomPatrimoine,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Touriste : ${reservationTrouvee!.nomTouriste}'),
                          Text('Participants : ${reservationTrouvee!.nombrePersonnes}'),
                          Text('Date : ${reservationTrouvee!.dateVisite} (${reservationTrouvee!.creneauHoraire})'),
                          Text('Statut actuel : ${reservationTrouvee!.statut}'),
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
              ElevatedButton.icon(
                onPressed: () async {
                  final code = controller.text.trim();
                  if (code.isEmpty) {
                    setDialogState(() {
                      messageErreur = 'Veuillez saisir un code de réservation.';
                      reservationTrouvee = null;
                    });
                    return;
                  }

                  // 1. Recherche du billet dans ReservationService
                  final reservation = await _reservationService.loadByCode(code);

                  if (reservation == null) {
                    setDialogState(() {
                      messageErreur = 'Billet invalide : aucune réservation ne correspond au code "$code".';
                      reservationTrouvee = null;
                    });
                    return;
                  }

                  // 2. Vérification du statut
                  if (reservation.statut == 'ANNULEE') {
                    setDialogState(() {
                      messageErreur = 'Billet refusé : cette réservation a été ANNULÉE.';
                      reservationTrouvee = reservation;
                    });
                    return;
                  }

                  if (reservation.statut == 'EFFECTUEE') {
                    setDialogState(() {
                      messageErreur = 'Billet déjà utilisé : cette visite a déjà été effectuée et validée.';
                      reservationTrouvee = reservation;
                    });
                    return;
                  }

                  // 3. Validation acceptée (CONFIRMEE ou EN_ATTENTE validée)
                  final bool succes = await _reservationService.updateStatut(
                    reservation.codeReservation,
                    'EFFECTUEE',
                  );

                  if (succes) {
                    await _chargerVisites();
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1B5E20),
                        content: Text(
                          'Billet ${reservation.codeReservation} validé avec succès ! Visite marquée EFFECTUEE.',
                        ),
                      ),
                    );
                  } else {
                    setDialogState(() {
                      messageErreur = 'Erreur lors de l\'enregistrement de la validation.';
                    });
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Valider le billet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
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
        title: Text(r.nomPatrimoine),
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
              _detailRow('Paiement', r.modePaiement),
              _detailRow('Statut', r.statut),
            ],
          ),
        ),
        actions: [
          if (r.statut == 'CONFIRMEE')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _ouvrirValidationBillet(r.codeReservation);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Valider ce billet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
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
            width: 100,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteVisite(Reservation r) {
    final couleur = _couleurStatut(r.statut);
    final bool peutEtreValidee = r.statut == 'CONFIRMEE';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: couleur.withAlpha(30),
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
                const Icon(Icons.calendar_month, size: 16, color: Color(0xFF1B5E20)),
                const SizedBox(width: 6),
                Text('${r.dateVisite} (${r.creneauHoraire})'),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Visiteur : ${r.nomTouriste} (${r.nombrePersonnes} pers.)'),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Code : ${r.codeReservation}', style: const TextStyle(fontFamily: 'monospace')),
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
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
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
    final int nbTotal = _visitesGuide.length;
    final int nbConfirmes = _visitesGuide.where((r) => r.statut == 'CONFIRMEE').length;
    final int nbEffectuees = _visitesGuide.where((r) => r.statut == 'EFFECTUEE').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Guide Touristique'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualiser le planning',
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
            // 1. Sélecteur de profil guide
            Card(
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          radius: 24,
                          child: Icon(Icons.person, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _guideConnecte.nomComplet,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_guideConnecte.telephone} • ${_guideConnecte.email}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Langues : ${_guideConnecte.languesParlees ?? "Français"}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Tarif journalier officiel : ${(_guideConnecte.tarifGuideJournalier ?? 0).toInt()} FCFA',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Divider(height: 20),
                    DropdownButtonFormField<Utilisateur>(
                      initialValue: _guideConnecte,
                      decoration: const InputDecoration(
                        labelText: 'Changer de profil Guide',
                        border: OutlineInputBorder(),
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: ApiConfig.guidesDisponibles.map((g) {
                        return DropdownMenuItem<Utilisateur>(
                          value: g,
                          child: Text(g.nomComplet),
                        );
                      }).toList(),
                      onChanged: (nouveauGuide) {
                        if (nouveauGuide != null) {
                          setState(() {
                            _guideConnecte = nouveauGuide;
                          });
                          _chargerVisites();
                        }
                      },
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
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Compteurs de statistiques
            Row(
              children: [
                Expanded(
                  child: _statCard('Assignées', '$nbTotal', Colors.blueGrey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard('À venir', '$nbConfirmes', Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard('Effectuées', '$nbEffectuees', Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Titre du planning
            const Text(
              'Planning de mes Visites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 5. Liste des visites assignées
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_visitesGuide.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.event_available, size: 50, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune visite assignée à ${_guideConnecte.nomComplet} pour le moment.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _visitesGuide.length,
                itemBuilder: (context, index) => _carteVisite(_visitesGuide[index]),
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
