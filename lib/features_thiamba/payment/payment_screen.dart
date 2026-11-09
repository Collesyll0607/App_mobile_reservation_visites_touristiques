
import 'package:flutter/material.dart';
import '../../core/models/reservation.dart';
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

  String _modePaiement = 'WAVE';

  @override
  void initState() {
    super.initState();

    if (widget.reservation.modePaiement == 'ORANGE_MONEY') {
      _modePaiement = 'ORANGE_MONEY';
    }
  }

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  void _simulerPaiement() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reservationPayee = Reservation(
      id: widget.reservation.id,
      patrimoineId: widget.reservation.patrimoineId,
      nomPatrimoine: widget.reservation.nomPatrimoine,
      nomTouriste: widget.reservation.nomTouriste,
      dateVisite: widget.reservation.dateVisite,
      creneauHoraire: widget.reservation.creneauHoraire,
      nombrePersonnes: widget.reservation.nombrePersonnes,
      nomGuide: widget.reservation.nomGuide,
      montantTotal: widget.reservation.montantTotal,
      modePaiement: _modePaiement,
      statut: 'CONFIRMEE',
      codeReservation: widget.reservation.codeReservation,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 55,
          ),
          title: const Text('Paiement réussi !'),
          content: Text(
            'Votre paiement de '
            '${widget.reservation.montantTotal.toInt()} FCFA '
            'a été simulé avec succès.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketQrScreen(
                      reservation: reservationPayee,
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
              RadioListTile<String>(
                title: const Text('Wave'),
                subtitle: const Text('Paiement avec Wave'),
                value: 'WAVE',
                groupValue: _modePaiement,
                onChanged: (value) {
                  setState(() {
                    _modePaiement = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Orange Money'),
                subtitle: const Text('Paiement avec Orange Money'),
                value: 'ORANGE_MONEY',
                groupValue: _modePaiement,
                onChanged: (value) {
                  setState(() {
                    _modePaiement = value!;
                  });
                },
              ),
              const SizedBox(height: 15),
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
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _simulerPaiement,
                icon: const Icon(Icons.lock),
                label: const Text('Simuler le paiement'),
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
