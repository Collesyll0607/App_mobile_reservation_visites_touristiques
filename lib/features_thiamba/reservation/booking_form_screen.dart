import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../core/models/reservation.dart';
import '../../core/models/utilisateur.dart';
import '../../features_colle/auth/auth_service.dart';
import '../payment/payment_screen.dart';
import '../services/favorites_service.dart';

/// Écran du Formulaire de Réservation d'une Visite Touristique
/// Responsable : Pôle 2 (Ndeye Thiamba FAYE)
class BookingFormScreen extends StatefulWidget {
  final Patrimoine site;

  const BookingFormScreen({super.key, required this.site});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FavoritesService _favoritesService = FavoritesService();

  late final TextEditingController _nomTouristeController;
  late final TextEditingController _dateController;
  late final TextEditingController _nbPersonnesController;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  String _selectedSlot = '09h00 - 11h00';
  int _nombrePersonnes = 2;
  Utilisateur? _selectedGuide;
  String _modePaiement = 'WAVE';
  bool _estFavori = false;
  String? _compteConnecteEmail;

  @override
  void initState() {
    super.initState();
    _nomTouristeController = TextEditingController();
    _nbPersonnesController = TextEditingController(text: '$_nombrePersonnes');
    _dateController = TextEditingController(
      text:
          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
    );
    _verifierFavori();
    _preremplirTouristeConnecte();
  }

  Future<void> _preremplirTouristeConnecte() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted || user == null) return;
    setState(() {
      _compteConnecteEmail = user.email;
      if (_nomTouristeController.text.trim().isEmpty) {
        _nomTouristeController.text = user.nomComplet;
      }
    });
  }

  @override
  void dispose() {
    _nomTouristeController.dispose();
    _dateController.dispose();
    _nbPersonnesController.dispose();
    super.dispose();
  }

  Future<void> _verifierFavori() async {
    final bool favori = await _favoritesService.isFavorite(widget.site.id);
    if (!mounted) return;
    setState(() {
      _estFavori = favori;
    });
  }

  Future<void> _basculerFavori() async {
    final bool nouveauStatut =
        await _favoritesService.toggleFavorite(widget.site);
    if (!mounted) return;

    setState(() {
      _estFavori = nouveauStatut;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nouveauStatut
              ? '${widget.site.nom} ajouté aux favoris (accessible hors-ligne) !'
              : '${widget.site.nom} retiré des favoris.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _choisirDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  double get _montantTotal {
    final nb = int.tryParse(_nbPersonnesController.text) ?? _nombrePersonnes;
    final totalEntrees = widget.site.tarifEntree * nb;
    final tarifGuide = _selectedGuide?.tarifGuideJournalier ?? 0;
    return totalEntrees + tarifGuide;
  }

  void _soumettreFormulaire() {
    // 1. Validation rigoureuse avec FormState
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final nb = int.parse(_nbPersonnesController.text.trim());
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final nouvelleReservation = Reservation(
      id: timestamp % 100000,
      patrimoineId: widget.site.id,
      nomPatrimoine: widget.site.nom,
      nomTouriste: _nomTouristeController.text.trim(),
      dateVisite: _dateController.text.trim(),
      creneauHoraire: _selectedSlot,
      nombrePersonnes: nb,
      nomGuide: _selectedGuide?.nomComplet,
      montantTotal: _montantTotal,
      modePaiement: _modePaiement,
      statut: 'EN_ATTENTE',
      codeReservation: 'ZIG-${timestamp % 100000}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          reservation: nouvelleReservation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une Visite'),
        actions: [
          IconButton(
            tooltip: _estFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
            icon: Icon(
              _estFavori ? Icons.favorite : Icons.favorite_border,
              color: _estFavori ? Colors.red : null,
            ),
            onPressed: _basculerFavori,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.site.nom,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tarif unitaire : ${widget.site.tarifEntree.toInt()} FCFA / personne',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              if (_compteConnecteEmail != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user,
                          size: 16, color: Color(0xFF1B5E20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Compte connecté : $_compteConnecteEmail',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // 1. Nom et prénom du touriste (Personnalisation)
              TextFormField(
                controller: _nomTouristeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom et prénom du touriste *',
                  hintText: 'Ex: Awa Diop ou Jean Faye',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF1B5E20)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez saisir votre nom et prénom';
                  }
                  if (val.trim().length < 2) {
                    return 'Le nom doit comporter au moins 2 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // 2. Sélection de la date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _choisirDate,
                decoration: InputDecoration(
                  labelText: 'Date de la visite *',
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF1B5E20),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _choisirDate,
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez sélectionner une date de visite';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // 3. Créneau horaire
              DropdownButtonFormField<String>(
                initialValue: _selectedSlot,
                decoration: const InputDecoration(
                  labelText: 'Créneau horaire *',
                  prefixIcon: Icon(
                    Icons.access_time,
                    color: Color(0xFF1B5E20),
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(
                    value: '09h00 - 11h00',
                    child: Text('Matin (09h00 - 11h00)'),
                  ),
                  DropdownMenuItem(
                    value: '11h30 - 13h30',
                    child: Text('Midi (11h30 - 13h30)'),
                  ),
                  DropdownMenuItem(
                    value: '15h00 - 17h30',
                    child: Text('Après-midi (15h00 - 17h30)'),
                  ),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Veuillez choisir un horaire de visite';
                  }
                  return null;
                },
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSlot = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 14),

              // 4. Nombre de participants avec validation
              TextFormField(
                controller: _nbPersonnesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nombre de personnes (1 à 20) *',
                  prefixIcon: const Icon(
                    Icons.people,
                    color: Color(0xFF1B5E20),
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Diminuer',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          final cur =
                              int.tryParse(_nbPersonnesController.text) ?? 1;
                          if (cur > 1) {
                            final nouveau = cur - 1;
                            _nbPersonnesController.text = nouveau.toString();
                            setState(() {
                              _nombrePersonnes = nouveau;
                            });
                          }
                        },
                      ),
                      IconButton(
                        tooltip: 'Augmenter',
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          final cur =
                              int.tryParse(_nbPersonnesController.text) ?? 1;
                          if (cur < 20) {
                            final nouveau = cur + 1;
                            _nbPersonnesController.text = nouveau.toString();
                            setState(() {
                              _nombrePersonnes = nouveau;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed >= 1 && parsed <= 20) {
                    setState(() {
                      _nombrePersonnes = parsed;
                    });
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez indiquer le nombre de personnes';
                  }
                  final parsed = int.tryParse(val.trim());
                  if (parsed == null || parsed < 1 || parsed > 20) {
                    return 'Le nombre de personnes doit être compris entre 1 et 20';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // 5. Sélection du guide touristique
              DropdownButtonFormField<Utilisateur?>(
                initialValue: _selectedGuide,
                decoration: const InputDecoration(
                  labelText: 'Accompagnement par un Guide Touristique',
                  prefixIcon: Icon(
                    Icons.person_pin,
                    color: Color(0xFF1B5E20),
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  const DropdownMenuItem<Utilisateur?>(
                    value: null,
                    child: Text('Visite libre (Sans guide)'),
                  ),
                  ...ApiConfig.guidesDisponibles.map(
                    (g) => DropdownMenuItem<Utilisateur?>(
                      value: g,
                      child: Text(
                        '${g.nomComplet} (+${(g.tarifGuideJournalier ?? 0).toInt()} FCFA)',
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedGuide = val;
                  });
                },
              ),

              const SizedBox(height: 14),

              // 6. Mode de paiement
              DropdownButtonFormField<String>(
                initialValue: _modePaiement,
                decoration: const InputDecoration(
                  labelText: 'Moyen de paiement *',
                  prefixIcon: Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF1B5E20),
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'WAVE',
                    child: Text('Wave Mobile Money'),
                  ),
                  DropdownMenuItem(
                    value: 'ORANGE_MONEY',
                    child: Text('Orange Money'),
                  ),
                  DropdownMenuItem(
                    value: 'SUR_PLACE',
                    child: Text('Paiement au guichet'),
                  ),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Veuillez sélectionner un mode de paiement';
                  }
                  return null;
                },
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _modePaiement = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // 7. Récapitulatif du tarif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant Total :',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_montantTotal.toInt()} FCFA',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 8. Bouton de soumission avec validation
              ElevatedButton.icon(
                onPressed: _soumettreFormulaire,
                icon: const Icon(Icons.payment),
                label: const Text('Continuer vers le paiement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
