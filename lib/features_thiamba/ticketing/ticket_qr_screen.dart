import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/models/reservation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../my_bookings/my_bookings_screen.dart';

/// Écran du billet électronique numérique avec véritable QR Code
/// Responsable : Ndeye Thiamba FAYE (Pôle 2) — DA Casamance Tourisme
class TicketQrScreen extends StatelessWidget {
  final Reservation reservation;

  const TicketQrScreen({
    super.key,
    required this.reservation,
  });

  String _formaterDateFrancaise(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final jour = int.parse(parts[0]);
          final mois = int.parse(parts[1]);
          final annee = int.parse(parts[2]);
          return _dateEnFrancais(DateTime(annee, mois, jour));
        }
      }
      if (dateStr.contains('-')) {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) return _dateEnFrancais(dt);
      }
    } catch (_) {}
    return dateStr;
  }

  String _dateEnFrancais(DateTime dt) {
    const mois = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    final jour = dt.day.toString().padLeft(2, '0');
    return '$jour ${mois[dt.month - 1]} ${dt.year}';
  }

  String _titreStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return 'BILLET CONFIRMÉ';
      case 'EN_ATTENTE':
        return 'EN ATTENTE (GUICHET)';
      case 'EFFECTUEE':
        return 'VISITE EFFECTUÉE';
      case 'ANNULEE':
        return 'BILLET ANNULÉ';
      default:
        return 'PASS DE VISITE';
    }
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return AppTheme.deepForest;
      case 'EN_ATTENTE':
        return AppTheme.solarGold;
      case 'EFFECTUEE':
        return AppTheme.bolongTurquoise;
      case 'ANNULEE':
        return AppTheme.lateriteRed;
      default:
        return AppTheme.deepForest;
    }
  }

  String _genererTextePartage() {
    final dateLisible = _formaterDateFrancaise(reservation.dateVisite);
    return '''
🎫 PASS DE VISITE TOURISTIQUE - SÉNÉGAL (ZIGUINCHOR & CASAMANCE)
🏛️ Site : ${reservation.nomPatrimoine}
👤 Bénéficiaire : ${reservation.nomTouriste}
📅 Date : $dateLisible
⏰ Créneau : ${reservation.creneauHoraire}
👥 Visiteurs : ${reservation.nombrePersonnes} personne(s)
👤 Guide : ${reservation.nomGuide ?? "Visite libre"}
💰 Montant : ${reservation.montantTotal.toInt()} FCFA (${reservation.modePaiement})
🔑 Référence : ${reservation.codeReservation}
📌 Statut : ${reservation.statut}
---------------------------------------------
Présentez ce pass numérique ou ce code à votre arrivée au guichet du site touristique.
''';
  }

  void _partagerBillet(BuildContext context) {
    final textePartage = _genererTextePartage();
    Clipboard.setData(ClipboardData(text: textePartage));

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.share, color: AppTheme.deepForest),
            const SizedBox(width: 8),
            Text(
              'Partager mon Billet',
              style: AppTheme.editorialTitle(
                  fontSize: 19, color: AppTheme.deepForest),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Les détails de votre billet ont été copiés dans le presse-papier !',
                style: AppTheme.bodyStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepForest,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.ivorySand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  textePartage,
                  style: AppTheme.bodyStyle(fontSize: 11.5, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Billet copié dans le presse-papier !'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _allerAMesReservations(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurStatut(reservation.statut);
    final dateAffichee = _formaterDateFrancaise(reservation.dateVisite);

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          CasamanceCurvedHeader(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 26),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    'Pass Numérique',
                    textAlign: TextAlign.center,
                    style: AppTheme.editorialTitle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Partager le billet',
                  icon: const Icon(Icons.share_rounded,
                      color: AppTheme.solarGold),
                  onPressed: () => _partagerBillet(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              child: Column(
                children: [
                  // Vrai billet type Boarding Pass
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        // En-tête du billet
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppTheme.deepForest,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: couleur == AppTheme.deepForest
                                      ? AppTheme.solarGold
                                      : couleur,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _titreStatut(reservation.statut),
                                  style: AppTheme.bodyStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: couleur == AppTheme.deepForest ||
                                            couleur == AppTheme.solarGold
                                        ? AppTheme.deepForest
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                reservation.nomPatrimoine,
                                textAlign: TextAlign.center,
                                style: AppTheme.editorialTitle(
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Casamance Tourisme • Ziguinchor',
                                style: AppTheme.bodyStyle(
                                  fontSize: 12,
                                  color:
                                      AppTheme.ivorySand.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Informations du billet
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Column(
                            children: [
                              _buildRow('Bénéficiaire', reservation.nomTouriste),
                              _buildRow('Date de visite', dateAffichee),
                              _buildRow(
                                  'Créneau horaire', reservation.creneauHoraire),
                              _buildRow('Participants',
                                  '${reservation.nombrePersonnes} personne(s)'),
                              _buildRow('Guide',
                                  reservation.nomGuide ?? 'Visite libre'),
                              _buildRow('Paiement', reservation.modePaiement),
                              _buildRow('Montant total',
                                  '${reservation.montantTotal.toInt()} FCFA'),
                            ],
                          ),
                        ),

                        // Séparateur découpé de billet
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppTheme.ivorySand,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(16),
                                ),
                              ),
                            ),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final count =
                                      (constraints.maxWidth / 12).floor();
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      count,
                                      (_) => Container(
                                        width: 6,
                                        height: 1.5,
                                        color: AppTheme.deepForest
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: 16,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppTheme.ivorySand,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Zone QR Code réel
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                          child: Column(
                            children: [
                              Text(
                                'Présentez ce QR Code à l\'accueil du site',
                                textAlign: TextAlign.center,
                                style: AppTheme.bodyStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppTheme.solarGold
                                        .withValues(alpha: 0.65),
                                    width: 2,
                                  ),
                                ),
                                child: QrImageView(
                                  data: reservation.codeReservation,
                                  version: QrVersions.auto,
                                  size: 175,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.ivorySand,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  reservation.codeReservation,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.deepForest,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Boutons d'action
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _partagerBillet(context),
                      icon: const Icon(Icons.share_rounded, size: 19),
                      label: const Text('Partager mon billet'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _allerAMesReservations(context),
                      icon: const Icon(Icons.confirmation_number_outlined,
                          size: 19),
                      label: const Text('Accéder à Mes Réservations'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    icon: const Icon(Icons.home_outlined,
                        color: AppTheme.deepForest),
                    label: Text(
                      'Retour à l’accueil',
                      style: AppTheme.bodyStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepForest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyStyle(
              fontSize: 12.5,
              color: AppTheme.textMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTheme.bodyStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
