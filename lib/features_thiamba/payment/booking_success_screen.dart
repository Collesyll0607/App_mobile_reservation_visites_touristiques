import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../my_bookings/my_bookings_screen.dart';
import '../ticketing/ticket_qr_screen.dart';

/// Écran de Confirmation de Réservation spectaculaire
/// Responsable : Pôle 2 — DA Casamance Tourisme
class BookingSuccessScreen extends StatefulWidget {
  final Reservation reservation;
  final bool isSurPlace;

  const BookingSuccessScreen({
    super.key,
    required this.reservation,
    required this.isSurPlace,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;

    return Scaffold(
      backgroundColor: AppTheme.deepForest,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Paysage Casamance subtil en pied d'écran
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 230,
            child: Opacity(
              opacity: 0.42,
              child: CasamanceAssetPhoto(
                assetPath: SiteMediaHelper.splashRiverAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dégradé forêt profonde pour la lisibilité parfaite
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.55, 0.85, 1.0],
                colors: [
                  AppTheme.deepForest,
                  AppTheme.deepForest.withValues(alpha: 0.94),
                  AppTheme.deepForest.withValues(alpha: 0.65),
                  AppTheme.deepForest.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    // Badge animé de succès
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSurPlace
                              ? AppTheme.solarGold.withValues(alpha: 0.2)
                              : const Color(0xFF22C55E).withValues(alpha: 0.22),
                          boxShadow: [
                            BoxShadow(
                              color: (widget.isSurPlace
                                      ? AppTheme.solarGold
                                      : const Color(0xFF4ADE80))
                                  .withValues(alpha: 0.45),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isSurPlace
                                  ? AppTheme.solarGold
                                  : const Color(0xFF22C55E),
                            ),
                            child: Icon(
                              widget.isSurPlace
                                  ? Icons.schedule_rounded
                                  : Icons.check_rounded,
                              size: 46,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      widget.isSurPlace
                          ? 'Réservation enregistrée !'
                          : 'Réservation réussie !',
                      textAlign: TextAlign.center,
                      style: AppTheme.editorialTitle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.isSurPlace
                          ? 'Votre réservation est enregistrée avec le statut EN ATTENTE. Vous réglerez au guichet le jour de votre visite.'
                          : 'Votre pass numérique est prêt et sauvegardé dans votre espace et dans MySQL.',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyStyle(
                        fontSize: 13.5,
                        color: AppTheme.ivorySand.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Carte récapitulative élégante
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.solarGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            r.nomPatrimoine,
                            textAlign: TextAlign.center,
                            style: AppTheme.editorialTitle(
                              fontSize: 18,
                              color: AppTheme.solarGold,
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 22),
                          _summaryLine('Référence', r.codeReservation),
                          _summaryLine('Date & Heure',
                              '${r.dateVisite} • ${r.creneauHoraire}'),
                          _summaryLine('Participants',
                              '${r.nombrePersonnes} personne(s)'),
                          _summaryLine(
                              'Montant', '${r.montantTotal.toInt()} FCFA'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Bouton principal : Voir mon billet QR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TicketQrScreen(reservation: r),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.solarGold,
                          foregroundColor: AppTheme.deepForest,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        icon: const Icon(Icons.qr_code_2_rounded),
                        label: const Text('Accéder à mon Billet QR'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyBookingsScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.ivorySand,
                          side: BorderSide(
                            color: AppTheme.ivorySand.withValues(alpha: 0.55),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        icon: const Icon(Icons.confirmation_number_outlined),
                        label: const Text('Voir mes réservations'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Text(
                        'Retour à l\'accueil',
                        style: AppTheme.bodyStyle(
                          fontSize: 13.5,
                          color: AppTheme.ivorySand.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
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

  Widget _summaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyStyle(
              fontSize: 12.5,
              color: AppTheme.ivorySand.withValues(alpha: 0.78),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTheme.bodyStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
