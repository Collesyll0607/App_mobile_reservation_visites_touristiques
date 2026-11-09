import 'package:flutter/material.dart';
import '../../core/models/utilisateur.dart';
import 'auth_service.dart';

/// Écran d'Inscription d'un nouveau Touriste ou Guide Touristique
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
  final _languesController =
      TextEditingController(text: 'Français, Wolof, Diola');
  final _tarifController = TextEditingController(text: '10000');

  String _selectedRole = 'TOURISTE';
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
        role: _selectedRole,
        languesParlees: _languesController.text,
        tarifGuideJournalier: _selectedRole == 'GUIDE'
            ? double.tryParse(_tarifController.text) ?? 10000
            : null,
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
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Inscription Touriste / Guide',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

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

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Type de compte',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'TOURISTE', child: Text('Touriste / Visiteur')),
                  DropdownMenuItem(
                      value: 'GUIDE',
                      child: Text('Guide Touristique Certifié')),
                ],
                onChanged: (val) =>
                    setState(() => _selectedRole = val ?? 'TOURISTE'),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Adresse Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
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
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.length < 4)
                    ? 'Minimum 4 caractères'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _languesController,
                decoration: const InputDecoration(
                  labelText: 'Langues parlées',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                ),
              ),

              if (_selectedRole == 'GUIDE') ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _tarifController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tarif d\'accompagnement (FCFA / visite)',
                    prefixIcon: Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRegister,
                child: Text(
                    _isLoading ? 'Création en cours...' : 'Valider l\'inscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
