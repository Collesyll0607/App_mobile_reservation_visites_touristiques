import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../guide/guide_dashboard_screen.dart';
import '../services/reservation_service.dart';
import '../ticketing/ticket_qr_screen.dart';

/// Écran Historique et Gestion des Réservations — Design System v2
/// Badges normalisés avec CasamanceStatusBadge, typographie Fraunces/PJS,
/// dashboard responsive, dark-aware et boîte de dialogue PIN sécurisée.
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
  String? _apiErrorMessage;

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
    setState(() {
      _isLoading = true;
      _apiErrorMessage = null;
    });
    final sauvegardees = await _reservationService.loadAll();
    if (!mounted) return;

    setState(() {
      _apiErrorMessage = _reservationService.lastError;
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
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        backgroundColor: AppTheme.forestGreen,
        content: const Text('Réservation annulée et enregistrée.'),
      ),
    );
  }

  Future<void> _confirmerAnnulation(Reservation reservation) async {
    final surface = AppTheme.surfaceOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius16),
        ),
        title: Text(
          'Annuler la réservation ?',
          style: AppTheme.headingStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
        ),
        content: Text(
          'Voulez-vous vraiment annuler la réservation ${reservation.codeReservation} pour "${reservation.nomPatrimoine}" ?',
          style: AppTheme.bodyStyle(fontSize: 13.5, color: mutedCol),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Non, conserver',
              style: AppTheme.bodyStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: mutedCol,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
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
    final surface = AppTheme.surfaceOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    final bool? autorise = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.lock_person_outlined,
                  color: AppTheme.forestGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Accès Guichet / Guide',
                    style: AppTheme.headingStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cet espace est réservé aux guides et agents d\'accueil pour contrôler et valider les billets QR.',
                  style: AppTheme.bodyStyle(fontSize: 13, color: mutedCol),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  style: AppTheme.bodyStyle(color: textCol),
                  decoration: InputDecoration(
                    labelText: 'Code PIN Agent / Guide',
                    hintText: 'Code démo : 2026',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                    ),
                  ),
                ),
                if (erreurPin != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    erreurPin!,
                    style: const TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Annuler', style: TextStyle(color: mutedCol)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radius12),
                  ),
                ),
                onPressed: () {
                  if (pinController.text.trim() == '2026') {
                    Navigator.pop(ctx, true);
                  } else {
                    setDialogState(
                      () => erreurPin = 'Code PIN incorrect (indice : 2026).',
                    );
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

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surfaceOf(context);
    final background = AppTheme.backgroundOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);
    final isWide = MediaQuery.sizeOf(context).width >= 640;
    final listeFiltree = _reservationsFiltrees;

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          // ── EN-TÊTE DASHBOARD ──
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: CasamanceResponsiveContainer(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  16,
                  isWide ? 24 : 16,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mes Réservations',
                                style: AppTheme.headingStyle(
                                  fontSize: isWide ? 26 : 22,
                                  fontWeight: FontWeight.w700,
                                  color: textCol,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_reservations.length} réservation${_reservations.length > 1 ? 's' : ''} au total',
                                style: AppTheme.bodyStyle(
                                  fontSize: 13,
                                  color: mutedCol,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Espace Agent / Guide',
                          onPressed: _ouvrirEspaceGuideSecurise,
                          icon: const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualiser',
                          onPressed: _chargerReservations,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barre de filtres de statut
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filtres.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final f = _filtres[index];
                          final code = f['code']!;
                          final label = f['label']!;
                          final sel = _filtreStatut == code;

                          return GestureDetector(
                            onTap: () => setState(() => _filtreStatut = code),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: sel ? AppTheme.forestGreen : surface,
                                borderRadius: BorderRadius.circular(AppTheme.radius24),
                                border: Border.all(
                                  color: sel ? AppTheme.forestGreen : border,
                                ),
                              ),
                              child: Text(
                                label,
                                style: AppTheme.bodyStyle(
                                  fontSize: 12.5,
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                  color: sel ? Colors.white : textCol,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_apiErrorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: CasamanceApiErrorBanner(
                message: _apiErrorMessage!,
                onRetry: _chargerReservations,
              ),
            ),

          // ── LISTE DES CARTES OU ÉTAT VIDE ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.forestGreen,
                    ),
                  )
                : listeFiltree.isEmpty
                    ? _buildEmptyState(surface, textCol, mutedCol)
                    : RefreshIndicator(
                        color: AppTheme.forestGreen,
                        backgroundColor: surface,
                        onRefresh: _chargerReservations,
                        child: CasamanceResponsiveContainer(
                          padding: EdgeInsets.fromLTRB(
                            isWide ? 24 : 16,
                            18,
                            isWide ? 24 : 16,
                            28,
                          ),
                          child: ListView.separated(
                            itemCount: listeFiltree.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return _buildBookingCard(
                                listeFiltree[index],
                                surface,
                                border,
                                textCol,
                                mutedCol,
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    Reservation reservation,
    Color surface,
    Color border,
    Color textCol,
    Color mutedCol,
  ) {
    final bool annulable = _estAnnulable(reservation);
    final bool billetDisponible = reservation.statut == 'CONFIRMEE' ||
        reservation.statut == 'EFFECTUEE' ||
        reservation.statut == 'EN_ATTENTE';

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: border),
        boxShadow: AppTheme.shadowFor(context),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reservation.nomPatrimoine,
                  style: AppTheme.headingStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textCol,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.paleGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
                child: Text(
                  reservation.codeReservation,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoLine(
            Icons.calendar_today_rounded,
            '${reservation.dateVisite} • ${reservation.creneauHoraire}',
            textCol,
          ),
          const SizedBox(height: 6),
          _infoLine(
            Icons.person_outline_rounded,
            'Touriste : ${reservation.nomTouriste} (${reservation.nombrePersonnes} pers.)',
            textCol,
          ),
          const SizedBox(height: 6),
          _infoLine(
            Icons.tour_outlined,
            'Guide : ${reservation.nomGuide ?? "Visite libre"}',
            textCol,
          ),
          const SizedBox(height: 6),
          _infoLine(
            Icons.account_balance_wallet_outlined,
            'Paiement : ${_libelleModePaiement(reservation.modePaiement)}',
            textCol,
          ),
          Divider(color: border, height: 24),
          Row(
            children: [
              CasamanceStatusBadge.fromStatus(reservation.statut),
              const SizedBox(width: 12),
              Text(
                '${reservation.montantTotal.toInt()} FCFA',
                style: AppTheme.bodyStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forestGreen,
                ),
              ),
              const Spacer(),
              if (annulable)
                IconButton(
                  tooltip: 'Annuler cette réservation',
                  onPressed: () => _confirmerAnnulation(reservation),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: AppTheme.errorRed,
                  ),
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
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 17),
                  label: Text(
                    'Billet QR',
                    style: AppTheme.bodyStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String text, Color textCol) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.oceanBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyStyle(fontSize: 13, color: textCol),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color surface, Color textCol, Color mutedCol) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppTheme.paleGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 52,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucune réservation trouvée',
              style: AppTheme.headingStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textCol,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Réservez vos visites de sites en Casamance pour obtenir vos billets numériques avec QR Code.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle(
                fontSize: 13.5,
                color: mutedCol,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
