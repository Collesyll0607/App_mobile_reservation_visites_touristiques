import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../guide/guide_dashboard_screen.dart';
import '../services/reservation_service.dart';
import '../ticketing/ticket_qr_screen.dart';

/// Écran Historique et Gestion des Réservations
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
    {'code': 'EN_ATTENTE', 'label': 'EN_ATTENTE'},
    {'code': 'CONFIRMEE', 'label': 'CONFIRMEE'},
    {'code': 'ANNULEE', 'label': 'ANNULEE'},
    {'code': 'EFFECTUEE', 'label': 'EFFECTUEE'},
  ];

  @override
  void initState() {
    super.initState();
    _chargerReservations();
  }

  Future<void> _chargerReservations() async {
    setState(() {
      _isLoading = true;
    });

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
    if (_filtreStatut == 'TOUTES') {
      return _reservations;
    }
    return _reservations
        .where((r) => r.statut == _filtreStatut)
        .toList();
  }

  bool _estAnnulable(Reservation reservation) {
    return reservation.statut == 'EN_ATTENTE';
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

  String _libelleModePaiement(String mode) {
    switch (mode) {
      case 'WAVE':
        return 'Wave (WAVE)';
      case 'ORANGE_MONEY':
        return 'Orange Money (ORANGE_MONEY)';
      case 'SUR_PLACE':
        return 'Sur place / Guichet (SUR_PLACE)';
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
      // Si la réservation venait uniquement du constructeur en mémoire, on la sauvegarde annulée
      final annulee = reservation.copyWith(statut: 'ANNULEE');
      await _reservationService.save(annulee);
    }

    await _chargerReservations();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation annulée et enregistrée.'),
      ),
    );
  }

  Future<void> _confirmerAnnulation(Reservation reservation) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: Text(
          'Voulez-vous vraiment annuler la réservation '
          '${reservation.codeReservation} pour "${reservation.nomPatrimoine}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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

  Widget _barreFiltres() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _filtres.map((filtre) {
          final String code = filtre['code']!;
          final String label = filtre['label']!;
          final bool estSelectionne = _filtreStatut == code;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: estSelectionne,
              selectedColor: const Color(0xFF1B5E20),
              labelStyle: TextStyle(
                color: estSelectionne ? Colors.white : Colors.black87,
                fontWeight: estSelectionne
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              onSelected: (_) {
                setState(() {
                  _filtreStatut = code;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _carteReservation(Reservation reservation) {
    final couleur = _couleurStatut(reservation.statut);
    final bool annulable = _estAnnulable(reservation);
    final bool billetDisponible =
        reservation.statut == 'CONFIRMEE' ||
        reservation.statut == 'EFFECTUEE';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reservation.nomPatrimoine,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reservation.codeReservation,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text('Date : ${reservation.dateVisite}'),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Touriste : ${reservation.nomTouriste}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text('Horaire : ${reservation.creneauHoraire}'),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.people, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${reservation.nombrePersonnes} participant(s)',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Guide : ${reservation.nomGuide ?? "Sans guide (Visite libre)"}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Paiement : ${_libelleModePaiement(reservation.modePaiement)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '${reservation.montantTotal.toInt()} FCFA',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: couleur.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_nomStatut(reservation.statut)} (${reservation.statut})',
                    style: TextStyle(
                      color: couleur,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),

                if (annulable)
                  TextButton.icon(
                    onPressed: () => _confirmerAnnulation(reservation),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: const Text(
                      'Annuler',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                if (billetDisponible)
                  IconButton(
                    tooltip: 'Voir mon billet QR',
                    icon: const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF1B5E20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketQrScreen(
                            reservation: reservation,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _affichageVide() {
    final bool aucunDansBase = _reservations.isEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              aucunDansBase
                  ? 'Aucune réservation pour le moment.'
                  : 'Aucune réservation avec le statut $_filtreStatut.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
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
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Espace Guide',
            icon: const Icon(Icons.badge_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuideDashboardScreen()),
              );
              _chargerReservations();
            },
          ),
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: _chargerReservations,
          ),
        ],
      ),
      body: Column(
        children: [
          _barreFiltres(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : listeAffichee.isEmpty
                    ? _affichageVide()
                    : RefreshIndicator(
                        onRefresh: _chargerReservations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: listeAffichee.length,
                          itemBuilder: (context, index) {
                            return _carteReservation(
                              listeAffichee[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
