import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
import '../services/reservation_service.dart';
import '../ticketing/ticket_qr_screen.dart';

/// Écran de paiement simulé
/// Responsable : Pôle 2
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
  final TextEditingController _telephoneController =
      TextEditingController();
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

    if (_modePaiement != 'SUR_PLACE' &&
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool estSurPlace = _modePaiement == 'SUR_PLACE';
    final String statutFinal = estSurPlace ? 'EN_ATTENTE' : 'CONFIRMEE';

    final reservationFinale = widget.reservation.copyWith(
      modePaiement: _modePaiement,
      statut: statutFinal,
    );

    final bool sauvegardeReussie =
        await _reservationService.save(reservationFinale);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (!sauvegardeReussie) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erreur lors de la sauvegarde de la réservation. Veuillez réessayer.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            estSurPlace ? Icons.schedule : Icons.check_circle,
            color: estSurPlace ? Colors.orange : Colors.green,
            size: 55,
          ),
          title: Text(
            estSurPlace
                ? 'Réservation enregistrée !'
                : 'Paiement réussi !',
          ),
          content: Text(
            estSurPlace
                ? 'Votre réservation de ${widget.reservation.montantTotal.toInt()} FCFA '
                    'est enregistrée avec le statut EN ATTENTE.\n'
                    'Le règlement se fera directement au guichet.'
                : 'Votre paiement de '
                    '${widget.reservation.montantTotal.toInt()} FCFA '
                    'a été simulé et sauvegardé avec succès.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketQrScreen(
                      reservation: reservationFinale,
                    ),
                  ),
                );
              },
              child: const Text('Voir mon billet QR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool estSurPlace = _modePaiement == 'SUR_PLACE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement de la réservation'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 65,
                color: Color(0xFF1B5E20),
              ),
              const SizedBox(height: 15),
              const Text(
                'Finaliser votre paiement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        widget.reservation.nomPatrimoine,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Montant à payer'),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.reservation.montantTotal.toInt()} FCFA',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Choisissez votre moyen de paiement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              RadioGroup<String>(
                groupValue: _modePaiement,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _modePaiement = value;
                    });
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('Wave'),
                      subtitle: Text('Paiement mobile immédiat avec Wave'),
                      value: 'WAVE',
                    ),
                    RadioListTile<String>(
                      title: Text('Orange Money'),
                      subtitle: Text('Paiement mobile immédiat avec Orange Money'),
                      value: 'ORANGE_MONEY',
                    ),
                    RadioListTile<String>(
                      title: Text('Paiement sur place (Guichet)'),
                      subtitle: Text(
                        'Réservation en attente — règlement au guichet le jour de la visite',
                      ),
                      value: 'SUR_PLACE',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              if (!estSurPlace)
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: 'Exemple : 77 123 45 67',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_modePaiement == 'SUR_PLACE') {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre numéro.';
                    }

                    final numero = value.replaceAll(
                      RegExp(r'[\s+]'),
                      '',
                    );

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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Votre réservation sera sauvegardée avec le statut EN ATTENTE. Vous présenterez votre QR Code au guichet pour régler sur place.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _simulerPaiement,
                icon: Icon(
                  estSurPlace ? Icons.bookmark_added : Icons.lock,
                ),
                label: Text(
                  _isSaving
                      ? 'Enregistrement en cours...'
                      : (estSurPlace
                          ? 'Confirmer la réservation (Sur place)'
                          : 'Simuler le paiement'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ceci est une démonstration. Aucun paiement réel '
                'ne sera effectué.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
