import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';
import '../../core/models/reservation.dart';
import '../../core/models/utilisateur.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_colle/auth/auth_service.dart';
import '../payment/payment_screen.dart';
import '../services/favorites_service.dart';

/// Écran du Formulaire de Réservation d'une Visite Touristique
/// Responsable : Pôle 2 (Ndeye Thiamba FAYE) — DA Casamance Tourisme
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepForest,
              onPrimary: Colors.white,
              surface: AppTheme.cardSurface,
            ),
          ),
          child: child!,
        );
      },
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire.'),
          backgroundColor: AppTheme.lateriteRed,
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
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
          // En-tête vert forêt courbé
          CasamanceCurvedHeader(
            padding: const EdgeInsets.fromLTRB(10, 8, 12, 26),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    'Réservation',
                    textAlign: TextAlign.center,
                    style: AppTheme.editorialTitle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _estFavori
                      ? 'Retirer des favoris'
                      : 'Ajouter aux favoris',
                  onPressed: _basculerFavori,
                  icon: Icon(
                    _estFavori
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _estFavori ? AppTheme.lateriteRed : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carte récapitulative du site sélectionné
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          SitePhotoView(
                            site: widget.site,
                            width: 78,
                            height: 74,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.site.nom,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.editorialTitle(
                                    fontSize: 17,
                                    color: AppTheme.deepForest,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: AppTheme.solarGold, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.site.noteMoyenne} • ${widget.site.tarifEntree.toInt()} FCFA / pers.',
                                      style: AppTheme.bodyStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_compteConnecteEmail != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.sageSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user,
                                size: 16, color: AppTheme.deepForest),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Compte connecté : $_compteConnecteEmail',
                                style: AppTheme.bodyStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepForest,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // 1. Nom du touriste
                    TextFormField(
                      controller: _nomTouristeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nom et prénom du touriste *',
                        hintText: 'Ex : Awa Diop ou Jean Faye',
                        prefixIcon:
                            Icon(Icons.person_outline, color: AppTheme.deepForest),
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

                    // 2. Date de visite
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _choisirDate,
                      decoration: InputDecoration(
                        labelText: 'Date de visite *',
                        prefixIcon: const Icon(Icons.calendar_today_rounded,
                            color: AppTheme.deepForest),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          onPressed: _choisirDate,
                        ),
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
                        labelText: 'Heure / Créneau horaire *',
                        prefixIcon: Icon(Icons.access_time_rounded,
                            color: AppTheme.deepForest),
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
                          setState(() => _selectedSlot = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // 4. Nombre de participants
                    TextFormField(
                      controller: _nbPersonnesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nombre de personnes (1 à 20) *',
                        prefixIcon: const Icon(Icons.people_outline_rounded,
                            color: AppTheme.deepForest),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Diminuer',
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppTheme.deepForest),
                              onPressed: () {
                                final cur = int.tryParse(
                                        _nbPersonnesController.text) ??
                                    1;
                                if (cur > 1) {
                                  final nouveau = cur - 1;
                                  _nbPersonnesController.text =
                                      nouveau.toString();
                                  setState(() => _nombrePersonnes = nouveau);
                                }
                              },
                            ),
                            IconButton(
                              tooltip: 'Augmenter',
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppTheme.deepForest),
                              onPressed: () {
                                final cur = int.tryParse(
                                        _nbPersonnesController.text) ??
                                    1;
                                if (cur < 20) {
                                  final nouveau = cur + 1;
                                  _nbPersonnesController.text =
                                      nouveau.toString();
                                  setState(() => _nombrePersonnes = nouveau);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed >= 1 && parsed <= 20) {
                          setState(() => _nombrePersonnes = parsed);
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Veuillez indiquer le nombre de personnes';
                        }
                        final parsed = int.tryParse(val.trim());
                        if (parsed == null || parsed < 1 || parsed > 20) {
                          return 'Le nombre doit être compris entre 1 et 20';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 5. Guide optionnel
                    DropdownButtonFormField<Utilisateur?>(
                      initialValue: _selectedGuide,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Accompagnement par un Guide (optionnel)',
                        prefixIcon: Icon(Icons.person_pin_outlined,
                            color: AppTheme.deepForest),
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
                              '${g.nomComplet} (+${(g.tarifGuideJournalier ?? 0).toInt()} F)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedGuide = val),
                    ),
                    const SizedBox(height: 20),

                    // 6. Sélection visuelle du moyen de paiement
                    Text(
                      'Moyen de paiement',
                      style: AppTheme.editorialTitle(
                        fontSize: 18,
                        color: AppTheme.deepForest,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _paymentRadioTile(
                      code: 'WAVE',
                      title: 'Wave Mobile Money',
                      subtitle: 'Paiement instantané sans frais',
                      badge: const WaveBrandBadge(size: 38),
                    ),
                    const SizedBox(height: 8),
                    _paymentRadioTile(
                      code: 'ORANGE_MONEY',
                      title: 'Orange Money',
                      subtitle: 'Paiement mobile rapide & sécurisé',
                      badge: const OrangeMoneyBrandBadge(size: 38),
                    ),
                    const SizedBox(height: 8),
                    _paymentRadioTile(
                      code: 'SUR_PLACE',
                      title: 'Paiement sur place (Guichet)',
                      subtitle: 'Réservation en attente le jour de la visite',
                      badge: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.sageSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_rounded,
                            color: AppTheme.deepForest),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // 7. Récapitulatif tarifaire élégant
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.deepForest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total à régler',
                                style: AppTheme.bodyStyle(
                                  fontSize: 12,
                                  color: AppTheme.ivorySand.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                '${_montantTotal.toInt()} FCFA',
                                style: AppTheme.editorialTitle(
                                  fontSize: 22,
                                  color: AppTheme.solarGold,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.receipt_long_rounded,
                              color: AppTheme.solarGold, size: 30),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 8. Bouton principal
                    ElevatedButton.icon(
                      onPressed: _soumettreFormulaire,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepForest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Payer et réserver →'),
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

  Widget _paymentRadioTile({
    required String code,
    required String title,
    required String subtitle,
    required Widget badge,
  }) {
    final selected = _modePaiement == code;
    return InkWell(
      onTap: () => setState(() => _modePaiement = code),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppTheme.deepForest
                : AppTheme.deepForest.withValues(alpha: 0.12),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? AppTheme.softShadow : [],
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppTheme.deepForest : AppTheme.textMuted,
            ),
            const SizedBox(width: 10),
            badge,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepForest,
                    ),
                  ),
                  Text(
                    subtitle,
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
    );
  }
}
