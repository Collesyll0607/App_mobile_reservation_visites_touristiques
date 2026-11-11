import 'package:flutter/material.dart';
import '../../core/models/utilisateur.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/casamance_widgets.dart';
import 'auth_service.dart';
import 'profile_screen.dart';
import 'register_screen.dart';

/// Écran d'Authentification & Profil Utilisateur — DA Casamance Tourisme
/// Responsable : Collé SYLL (Pôle 1 - Module Auth)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController =
      TextEditingController(text: 'aissatou.fall@gmail.com');
  final _passwordController = TextEditingController(text: 'passer123');

  Utilisateur? _currentUser;
  bool _isLoading = true;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final user = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (user != null) {
        _currentUser = user;
      } else {
        _errorMessage = 'Email/identifiant ou mot de passe incorrect.';
      }
    });
  }

  Future<void> _openForgotPasswordDialog() async {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? dialogError;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Récupération de mot de passe',
                style: AppTheme.editorialTitle(
                    fontSize: 19, color: AppTheme.deepForest),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Saisissez l\'adresse email de votre compte et choisissez un nouveau mot de passe.',
                      style: AppTheme.bodyStyle(
                          fontSize: 12.5, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 14),
                    if (dialogError != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.lateriteRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          dialogError!,
                          style: const TextStyle(
                              color: AppTheme.lateriteRed, fontSize: 12.5),
                        ),
                      ),
                    TextField(
                      controller: resetEmailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Votre Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setDialogState(() => obscureNew = !obscureNew),
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassCtrl,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () => setDialogState(
                              () => obscureConfirm = !obscureConfirm),
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newPassCtrl.text.length < 4) {
                      setDialogState(() => dialogError =
                          'Le mot de passe doit contenir au moins 4 caractères.');
                      return;
                    }
                    if (newPassCtrl.text != confirmPassCtrl.text) {
                      setDialogState(() => dialogError =
                          'Les deux mots de passe ne correspondent pas.');
                      return;
                    }
                    try {
                      await AuthService.resetPassword(
                        email: resetEmailCtrl.text,
                        newPassword: newPassCtrl.text,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      setState(() {
                        _emailController.text = resetEmailCtrl.text;
                        _passwordController.text = newPassCtrl.text;
                        _errorMessage = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Mot de passe réinitialisé avec succès ! Vous pouvez vous connecter.'),
                        ),
                      );
                    } catch (e) {
                      setDialogState(() {
                        dialogError =
                            e.toString().replaceAll('Exception: ', '');
                      });
                    }
                  },
                  child: const Text('Réinitialiser'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.ivorySand,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser != null) {
      return Scaffold(
        backgroundColor: AppTheme.ivorySand,
        body: ProfileScreen(
          user: _currentUser!,
          onUpdated: (updated) => setState(() => _currentUser = updated),
          onLogout: () => setState(() => _currentUser = null),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.ivorySand,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CasamanceCurvedHeader(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
              child: Column(
                children: [
                  const CasamanceEmblemMark(size: 76, darkBackground: true),
                  const SizedBox(height: 12),
                  Text(
                    'Espace Touriste',
                    style: AppTheme.editorialTitle(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connectez-vous pour retrouver vos réservations',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyStyle(
                      fontSize: 12.5,
                      color: AppTheme.ivorySand.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.sageSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Compte démo MySQL : aissatou.fall@gmail.com (ou "touriste") • Mdp : passer123',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyStyle(
                          fontSize: 11.5,
                          color: AppTheme.deepForest,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
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

                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse Email ou Identifiant',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppTheme.deepForest),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
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
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _openForgotPasswordDialog,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: AppTheme.bodyStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.bolongTurquoise,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text('Se connecter →'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(
                              onRegistered: (newUser) {
                                setState(() => _currentUser = newUser);
                              },
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Créer un nouveau compte Touriste'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
