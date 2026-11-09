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
  final _emailController = TextEditingController(text: 'touriste@uasz.sn');
  final _passwordController = TextEditingController(text: '123456');

  Utilisateur? _currentUser;
  bool _isLoading = true;
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
                        'Espace Authentification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Comptes démo : touriste@uasz.sn ou guide@uasz.sn (Mdp : 123456)',
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
                          labelText: 'Adresse Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
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
