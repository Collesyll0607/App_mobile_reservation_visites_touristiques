import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/models/reservation.dart';
import '../my_bookings/my_bookings_screen.dart';

/// Écran du billet numérique avec véritable QR Code
/// Responsable : Ndeye Thiamba FAYE (Pôle 2)
class TicketQrScreen extends StatelessWidget {
  final Reservation reservation;

  const TicketQrScreen({
    super.key,
    required this.reservation,
  });

  /// Formate une date (JJ/MM/AAAA ou ISO) en français lisible (ex: 09 novembre 2026)
  String _formaterDateFrancaise(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final jour = int.parse(parts[0]);
          final mois = int.parse(parts[1]);
          final annee = int.parse(parts[2]);
          final dt = DateTime(annee, mois, jour);
          return _dateEnFrancais(dt);
        }
      }
      if (dateStr.contains('-')) {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) {
          return _dateEnFrancais(dt);
        }
      }
    } catch (_) {
      // Fallback
    }
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
    final moisNom = mois[dt.month - 1];
    return '$jour $moisNom ${dt.year}';
  }

  String _titreStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return 'RÉSERVATION CONFIRMÉE';
      case 'EN_ATTENTE':
        return 'RÉSERVATION EN ATTENTE (GUICHET)';
      case 'EFFECTUEE':
        return 'VISITE EFFECTUÉE';
      case 'ANNULEE':
        return 'RÉSERVATION ANNULÉE';
      default:
        return 'PASS DE VISITE';
    }
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return const Color(0xFF1B5E20);
      case 'EN_ATTENTE':
        return Colors.orange.shade800;
      case 'EFFECTUEE':
        return Colors.blue.shade800;
      case 'ANNULEE':
        return Colors.red.shade800;
      default:
        return const Color(0xFF1B5E20);
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

    // Copie dans le presse-papier
    Clipboard.setData(ClipboardData(text: textePartage));

    // Affichage d'un dialogue de confirmation de partage
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Color(0xFF1B5E20)),
            SizedBox(width: 8),
            Text('Partager mon Billet'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Les détails de votre billet ont été copiés dans le presse-papier !',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  textePartage,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vous pouvez maintenant coller ce récapitulatif dans WhatsApp, SMS ou par Email pour l\'envoyer à vos proches.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            child: const Text('Compris'),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Billet copié dans le presse-papier ! Prêt à être partagé.'),
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
      appBar: AppBar(
        title: const Text('Pass de Visite Numérique'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Partager le billet',
            icon: const Icon(Icons.share),
            onPressed: () => _partagerBillet(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    reservation.statut == 'ANNULEE'
                        ? Icons.cancel
                        : (reservation.statut == 'EN_ATTENTE'
                            ? Icons.schedule
                            : Icons.verified),
                    color: couleur,
                    size: 48,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _titreStatut(reservation.statut),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: couleur,
                      letterSpacing: 1.1,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 28),

                  Text(
                    reservation.nomPatrimoine,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildRow('Code billet :', reservation.codeReservation),
                  _buildRow('Bénéficiaire :', reservation.nomTouriste),
                  _buildRow('Date de visite :', dateAffichee),
                  _buildRow('Créneau horaire :', reservation.creneauHoraire),
                  _buildRow('Visiteurs :', '${reservation.nombrePersonnes} participant(s)'),
                  _buildRow('Guide :', reservation.nomGuide ?? 'Visite libre'),
                  _buildRow('Mode de paiement :', reservation.modePaiement),
                  _buildRow('Montant total :', '${reservation.montantTotal.toInt()} FCFA'),

                  const SizedBox(height: 24),

                  const Text(
                    'Présentez ce QR Code à votre arrivée',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Véritable QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: reservation.codeReservation,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    reservation.codeReservation,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton 1 : Partager le billet numérique
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _partagerBillet(context),
                      icon: const Icon(Icons.share, size: 20),
                      label: const Text('Partager mon billet'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bouton 2 : Accès direct à Mes Réservations
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _allerAMesReservations(context),
                      icon: const Icon(Icons.confirmation_number_outlined, size: 20),
                      label: const Text('Accéder à Mes Réservations'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bouton 3 : Retour à l'accueil
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Retour à l’accueil'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
            style: const TextStyle(color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
