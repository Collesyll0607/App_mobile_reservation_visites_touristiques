import 'package:flutter/material.dart';

/// Écran d'Authentification & Profil Utilisateur
/// Responsable : Collé SYLL (Pôle 1)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'touriste@uasz.sn');
  final _passwordController = TextEditingController(text: '••••••••');
  String _selectedRole = 'TOURISTE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Compte & Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle, size: 76, color: Color(0xFF1B5E20)),
            const SizedBox(height: 16),
            const Text(
              'Bienvenue sur Ziguinchor Visites',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Profil de connexion',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'TOURISTE', child: Text('Touriste / Visiteur')),
                DropdownMenuItem(value: 'GUIDE', child: Text('Guide Touristique')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val ?? 'TOURISTE'),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Connecté en tant que $_selectedRole')),
                );
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
