import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../services/reservation_service.dart';
import 'booking_success_screen.dart';

/// Écran de paiement simulé — DA Casamance Tourisme
/// Responsable : Pôle 2 (Ndeye Thiamba FAYE)
class PaymentScreen extends StatefulWidget {
  final Reservation reservation;

  const PaymentScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _telephoneController = TextEditingController();
  final ReservationService _reservationService = ReservationService();

  String _modePaiement = 'WAVE';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.reservation.modePaiement == 'ORANGE_MONEY' ||
        widget.reservation.modePaiement == 'SUR_PLACE') {
      _modePaiement = widget.reservation.modePaiement;
    }
  }

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _simulerPaiement() async {
    if (_isSaving) return;

    if (_modePaiement != 'SUR_PLACE' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final bool estSurPlace = _modePaiement == 'SUR_PLACE';
    final String statutFinal = estSurPlace ? 'EN_ATTENTE' : 'CONFIRMEE';

    final reservationFinale = widget.reservation.copyWith(
      modePaiement: _modePaiement,
      statut: statutFinal,
    );

    final bool sauvegardeReussie =
        await _reservationService.save(reservationFinale);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!sauvegardeReussie) {
      final errDetail = _reservationService.lastError ??
          'Le serveur n\'a pas confirmé la réservation. Vérifiez votre connexion et le backend.';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppTheme.errorRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Réservation non confirmée',
                  style: AppTheme.headingStyle(
                    fontSize: 16.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            errDetail,
            style: AppTheme.bodyStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warmOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _simulerPaiement();
              },
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(
          reservation: reservationFinale,
          isSurPlace: estSurPlace,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool estSurPlace = _modePaiement == 'SUR_PLACE';

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          // En-tête vert forêt courbé
          CasamanceCurvedHeader(
            padding: const EdgeInsets.fromLTRB(10, 8, 16, 26),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    'Paiement',
                    textAlign: TextAlign.center,
                    style: AppTheme.editorialTitle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carte montant à régler
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.reservation.nomPatrimoine,
                            textAlign: TextAlign.center,
                            style: AppTheme.editorialTitle(
                              fontSize: 18,
                              color: AppTheme.deepForest,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.reservation.dateVisite} • ${widget.reservation.nombrePersonnes} personne(s)',
                            style: AppTheme.bodyStyle(
                              fontSize: 12.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${widget.reservation.montantTotal.toInt()} FCFA',
                            style: AppTheme.editorialTitle(
                              fontSize: 28,
                              color: AppTheme.deepForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    Text(
                      'Choisissez votre méthode',
                      textAlign: TextAlign.center,
                      style: AppTheme.editorialTitle(
                        fontSize: 20,
                        color: AppTheme.deepForest,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Deux belles cartes côte à côte pour Wave et Orange Money
                    Row(
                      children: [
                        Expanded(
                          child: _methodCard(
                            code: 'WAVE',
                            label: 'Wave',
                            tint: const Color(0xFFE0F7FF),
                            badge: const WaveBrandBadge(size: 56),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _methodCard(
                            code: 'ORANGE_MONEY',
                            label: 'Orange\nMoney',
                            tint: const Color(0xFFFFF2E5),
                            badge: const OrangeMoneyBrandBadge(size: 56),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Option Sur Place (Guichet)
                    InkWell(
                      onTap: () => setState(() => _modePaiement = 'SUR_PLACE'),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: estSurPlace
                              ? Colors.white
                              : AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: estSurPlace
                                ? AppTheme.deepForest
                                : AppTheme.deepForest.withValues(alpha: 0.14),
                            width: estSurPlace ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              estSurPlace
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: estSurPlace
                                  ? AppTheme.deepForest
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.storefront_rounded,
                                color: AppTheme.deepForest),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Paiement sur place (Guichet)',
                                    style: AppTheme.bodyStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Statut EN ATTENTE — règlement le jour J',
                                    style: AppTheme.bodyStyle(
                                      fontSize: 11.5,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (!estSurPlace)
                      TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Numéro Mobile Money (Sénégal)',
                          hintText: 'Exemple : 77 123 45 67',
                          prefixIcon: Icon(Icons.phone_android_rounded,
                              color: AppTheme.deepForest),
                        ),
                        validator: (value) {
                          if (_modePaiement == 'SUR_PLACE') return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir votre numéro.';
                          }
                          final numero =
                              value.replaceAll(RegExp(r'[\s+]'), '');
                          if (!RegExp(r'^(70|75|76|77|78)\d{7}$')
                              .hasMatch(numero)) {
                            return 'Veuillez saisir un numéro sénégalais valide.';
                          }
                          return null;
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.solarGold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.solarGold.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppTheme.deepForest),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Votre réservation sera enregistrée en attente. Présentez votre référence ou QR Code au guichet.',
                                style: AppTheme.bodyStyle(fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Mention rassurante de démonstration
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.sageSurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded,
                              color: AppTheme.bolongTurquoise, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Mode démonstration sécurisé : aucun paiement réel ne sera débité de votre compte.',
                              style: AppTheme.bodyStyle(
                                fontSize: 12,
                                color: AppTheme.deepForest,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _simulerPaiement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepForest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      icon: Icon(estSurPlace
                          ? Icons.bookmark_added_rounded
                          : Icons.lock_rounded),
                      label: Text(
                        _isSaving
                            ? 'Enregistrement en cours...'
                            : (estSurPlace
                                ? 'Confirmer la réservation →'
                                : 'Confirmer le paiement →'),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Touche visuelle Casamance en pied de page
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 84,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const CasamanceAssetPhoto(
                              assetPath: SiteMediaHelper.heritageFooterAsset,
                            ),
                            Container(
                              color:
                                  AppTheme.deepForest.withValues(alpha: 0.35),
                              alignment: Alignment.center,
                              child: Text(
                                'Casamance Tourisme — Billetterie Officielle',
                                style: AppTheme.editorialTitle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodCard({
    required String code,
    required String label,
    required Color tint,
    required Widget badge,
  }) {
    final selected = _modePaiement == code;
    return InkWell(
      onTap: () => setState(() => _modePaiement = code),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : tint.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.deepForest
                : AppTheme.deepForest.withValues(alpha: 0.14),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected ? AppTheme.softShadow : [],
        ),
        child: Column(
          children: [
            badge,
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepForest,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: selected ? AppTheme.bolongTurquoise : AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
