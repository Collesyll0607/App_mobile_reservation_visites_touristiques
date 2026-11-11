import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../guide/guide_dashboard_screen.dart';
import '../services/reservation_service.dart';
import '../ticketing/ticket_qr_screen.dart';

/// Écran Historique et Gestion des Réservations — DA Casamance Tourisme
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)
class MyBookingsScreen extends StatefulWidget {
  final List<Reservation> reservations;

  const MyBookingsScreen({
    super.key,
    this.reservations = const [],
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final ReservationService _reservationService = ReservationService();

  List<Reservation> _reservations = [];
  String _filtreStatut = 'TOUTES';
  bool _isLoading = true;

  static const List<Map<String, String>> _filtres = [
    {'code': 'TOUTES', 'label': 'Toutes'},
    {'code': 'EN_ATTENTE', 'label': 'En attente'},
    {'code': 'CONFIRMEE', 'label': 'Confirmées'},
    {'code': 'EFFECTUEE', 'label': 'Effectuées'},
    {'code': 'ANNULEE', 'label': 'Annulées'},
  ];

  @override
  void initState() {
    super.initState();
    _chargerReservations();
  }

  Future<void> _chargerReservations() async {
    setState(() => _isLoading = true);
    final sauvegardees = await _reservationService.loadAll();
    if (!mounted) return;

    setState(() {
      if (sauvegardees.isNotEmpty) {
        _reservations = sauvegardees;
      } else if (widget.reservations.isNotEmpty) {
        _reservations = List.from(widget.reservations);
      } else {
        _reservations = [];
      }
      _isLoading = false;
    });
  }

  List<Reservation> get _reservationsFiltrees {
    if (_filtreStatut == 'TOUTES') return _reservations;
    return _reservations.where((r) => r.statut == _filtreStatut).toList();
  }

  bool _estAnnulable(Reservation reservation) =>
      reservation.statut == 'EN_ATTENTE';

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return AppTheme.deepForest;
      case 'EN_ATTENTE':
        return AppTheme.solarGold;
      case 'ANNULEE':
        return AppTheme.lateriteRed;
      case 'EFFECTUEE':
        return AppTheme.bolongTurquoise;
      default:
        return AppTheme.textMuted;
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

  String _libelleModePaiement(String mode) {
    switch (mode) {
      case 'WAVE':
        return 'Wave Mobile Money';
      case 'ORANGE_MONEY':
        return 'Orange Money';
      case 'SUR_PLACE':
        return 'Sur place (Guichet)';
      default:
        return mode;
    }
  }

  Future<void> _annulerReservation(Reservation reservation) async {
    final bool ok = await _reservationService.updateStatut(
      reservation.codeReservation,
      'ANNULEE',
    );
    if (!ok) {
      await _reservationService.save(reservation.copyWith(statut: 'ANNULEE'));
    }
    await _chargerReservations();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réservation annulée et enregistrée.')),
    );
  }

  Future<void> _confirmerAnnulation(Reservation reservation) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Annuler la réservation ?',
          style: AppTheme.editorialTitle(
              fontSize: 19, color: AppTheme.deepForest),
        ),
        content: Text(
          'Voulez-vous vraiment annuler la réservation ${reservation.codeReservation} pour "${reservation.nomPatrimoine}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lateriteRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmation == true && mounted) {
      await _annulerReservation(reservation);
    }
  }

  Future<void> _ouvrirEspaceGuideSecurise() async {
    final pinController = TextEditingController();
    String? erreurPin;

    final bool? autorise = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardSurface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.lock_person_outlined,
                    color: AppTheme.deepForest),
                const SizedBox(width: 8),
                Text(
                  'Accès Guichet / Guide',
                  style: AppTheme.editorialTitle(
                      fontSize: 19, color: AppTheme.deepForest),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cet espace est réservé aux guides et agents d\'accueil pour contrôler et valider les billets QR.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Code PIN Agent / Guide',
                    hintText: 'Code démo : 2026',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                ),
                if (erreurPin != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    erreurPin!,
                    style: const TextStyle(
                        color: AppTheme.lateriteRed, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (pinController.text.trim() == '2026') {
                    Navigator.pop(ctx, true);
                  } else {
                    setDialogState(
                        () => erreurPin = 'Code PIN incorrect (indice : 2026).');
                  }
                },
                child: const Text('Déverrouiller'),
              ),
            ],
          );
        },
      ),
    );

    if (autorise == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GuideDashboardScreen()),
      );
      _chargerReservations();
    }
  }

  Widget _barreFiltres() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _filtres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filtre = _filtres[index];
          final code = filtre['code']!;
          final label = filtre['label']!;
          final estSelectionne = _filtreStatut == code;

          return ChoiceChip(
            label: Text(label),
            selected: estSelectionne,
            selectedColor: AppTheme.deepForest,
            backgroundColor: AppTheme.cardSurface,
            showCheckmark: false,
            labelStyle: AppTheme.bodyStyle(
              fontSize: 12.5,
              fontWeight: estSelectionne ? FontWeight.w600 : FontWeight.w500,
              color: estSelectionne ? AppTheme.solarGold : AppTheme.textDark,
            ),
            onSelected: (_) => setState(() => _filtreStatut = code),
          );
        },
      ),
    );
  }

  Widget _carteReservation(Reservation reservation) {
    final couleur = _couleurStatut(reservation.statut);
    final bool annulable = _estAnnulable(reservation);
    final bool billetDisponible = reservation.statut == 'CONFIRMEE' ||
        reservation.statut == 'EFFECTUEE' ||
        reservation.statut == 'EN_ATTENTE';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reservation.nomPatrimoine,
                    style: AppTheme.editorialTitle(
                      fontSize: 18,
                      color: AppTheme.deepForest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.ivorySand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    reservation.codeReservation,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: AppTheme.deepForest,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoLine(Icons.calendar_today_rounded,
                '${reservation.dateVisite} • ${reservation.creneauHoraire}'),
            const SizedBox(height: 5),
            _infoLine(Icons.person_outline_rounded,
                'Touriste : ${reservation.nomTouriste} (${reservation.nombrePersonnes} pers.)'),
            const SizedBox(height: 5),
            _infoLine(Icons.tour_outlined,
                'Guide : ${reservation.nomGuide ?? "Visite libre"}'),
            const SizedBox(height: 5),
            _infoLine(Icons.account_balance_wallet_outlined,
                'Paiement : ${_libelleModePaiement(reservation.modePaiement)}'),
            const Divider(height: 22),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _nomStatut(reservation.statut),
                    style: AppTheme.bodyStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: couleur == AppTheme.solarGold
                          ? AppTheme.deepForest
                          : couleur,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${reservation.montantTotal.toInt()} FCFA',
                  style: AppTheme.bodyStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepForest,
                  ),
                ),
                const Spacer(),
                if (annulable)
                  IconButton(
                    tooltip: 'Annuler cette réservation',
                    onPressed: () => _confirmerAnnulation(reservation),
                    icon: const Icon(Icons.cancel_outlined,
                        color: AppTheme.lateriteRed),
                  ),
                if (billetDisponible)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TicketQrScreen(reservation: reservation),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                    label: const Text('Billet'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.bolongTurquoise),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyStyle(fontSize: 12.5, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }

  Widget _affichageVide() {
    final bool aucunDansBase = _reservations.isEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppTheme.sageSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 54,
                color: AppTheme.deepForest,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              aucunDansBase
                  ? 'Aucune réservation pour le moment'
                  : 'Aucune réservation "$_filtreStatut"',
              textAlign: TextAlign.center,
              style: AppTheme.editorialTitle(
                fontSize: 20,
                color: AppTheme.deepForest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explorez les sites de Casamance depuis l\'accueil pour réserver votre première visite.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listeAffichee = _reservationsFiltrees;

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          CasamanceCurvedHeader(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 26),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Réservations',
                        style: AppTheme.editorialTitle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Vos pass numériques et visites planifiées',
                        style: AppTheme.bodyStyle(
                          fontSize: 12,
                          color: AppTheme.ivorySand.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Contrôle Guichet / Guide (PIN)',
                  icon: const Icon(Icons.qr_code_scanner_rounded,
                      color: AppTheme.solarGold),
                  onPressed: _ouvrirEspaceGuideSecurise,
                ),
                IconButton(
                  tooltip: 'Actualiser depuis MySQL',
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _chargerReservations,
                ),
              ],
            ),
          ),
          _barreFiltres(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : listeAffichee.isEmpty
                    ? _affichageVide()
                    : RefreshIndicator(
                        color: AppTheme.deepForest,
                        onRefresh: _chargerReservations,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          itemCount: listeAffichee.length,
                          itemBuilder: (context, index) =>
                              _carteReservation(listeAffichee[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
