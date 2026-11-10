import 'package:flutter/material.dart';
import '../../core/models/utilisateur.dart';
import 'auth_service.dart';
import 'profile_screen.dart';
import 'register_screen.dart';

/// Écran d'Authentification & Profil Utilisateur
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
        _errorMessage = 'Email ou mot de passe incorrect.';
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
              title: const Text('Récupération de mot de passe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Saisissez l\'adresse email de votre compte et choisissez un nouveau mot de passe.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 14),
                    if (dialogError != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dialogError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    TextField(
                      controller: resetEmailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Votre Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
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
                        border: const OutlineInputBorder(),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUser == null ? 'Connexion & Inscription' : 'Mon Profil',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser != null
              ? ProfileScreen(
                  user: _currentUser!,
                  onUpdated: (updated) =>
                      setState(() => _currentUser = updated),
                  onLogout: () => setState(() => _currentUser = null),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 72,
                        color: Color(0xFF1B5E20),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Espace Touriste — Connexion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Comptes de la table "utilisateurs" : aissatou.fall@gmail.com (ou "touriste") — Mdp : passer123',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse Email ou Identifiant (username)',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Champ Mot de passe avec icône œil pour afficher/masquer
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
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

                      // Lien "Mot de passe oublié ?"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openForgotPasswordDialog,
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Se connecter'),
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
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text('Créer un nouveau compte'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
