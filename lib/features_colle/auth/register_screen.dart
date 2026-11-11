import 'package:flutter/material.dart';
import '../../core/models/utilisateur.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import 'auth_service.dart';

/// Écran d'Inscription d'un Touriste — DA Casamance Tourisme
/// Responsable : Collé SYLL (Pôle 1 - Module Auth)
class RegisterScreen extends StatefulWidget {
  final ValueChanged<Utilisateur> onRegistered;

  const RegisterScreen({super.key, required this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController(text: '+221 77 ');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _languesController = TextEditingController(text: 'Français');

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.register(
        nomComplet: _nomController.text,
        email: _emailController.text,
        password: _passwordController.text,
        telephone: _telController.text,
        role: 'TOURISTE',
        languesParlees: _languesController.text,
        tarifGuideJournalier: null,
      );
      if (!mounted) return;
      widget.onRegistered(user);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: Column(
        children: [
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
                    'Inscription Touriste',
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: AppTheme.maxFormWidth),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.softShadow,
                    ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Créer votre compte',
                        style: AppTheme.editorialTitle(
                          fontSize: 21,
                          color: AppTheme.deepForest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enregistré directement dans MySQL pour réserver vos visites en Casamance.',
                        style: AppTheme.bodyStyle(
                          fontSize: 12.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.lateriteRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: AppTheme.lateriteRed, fontSize: 13),
                          ),
                        ),

                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.deepForest),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse Email',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.deepForest),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Email valide requis'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _telController,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: Icon(Icons.phone_outlined,
                              color: AppTheme.deepForest),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.deepForest),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Afficher le mot de passe'
                                : 'Masquer le mot de passe',
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 4)
                            ? 'Minimum 4 caractères'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_reset_outlined,
                              color: AppTheme.deepForest),
                          suffixIcon: IconButton(
                            tooltip: _obscureConfirmPassword
                                ? 'Afficher la confirmation'
                                : 'Masquer la confirmation',
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Veuillez confirmer le mot de passe';
                          }
                          if (v != _passwordController.text) {
                            return 'Les deux mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _languesController,
                        decoration: const InputDecoration(
                          labelText: 'Langue préférée pour la visite',
                          prefixIcon:
                              Icon(Icons.language, color: AppTheme.deepForest),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(_isLoading
                            ? 'Création en cours...'
                            : 'Valider mon inscription →'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
