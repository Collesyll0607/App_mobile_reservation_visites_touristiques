import 'package:flutter/material.dart';
import '../../core/models/utilisateur.dart';
import 'auth_service.dart';

/// Écran de Profil Utilisateur (Affichage, Modification & Déconnexion)
/// Responsable : Collé SYLL (Pôle 1 - Module Auth)
class ProfileScreen extends StatefulWidget {
  final Utilisateur user;
  final VoidCallback onLogout;
  final ValueChanged<Utilisateur> onUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nomController;
  late TextEditingController _telController;
  late TextEditingController _languesController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.user.nomComplet);
    _telController = TextEditingController(text: widget.user.telephone);
    _languesController =
        TextEditingController(text: widget.user.languesParlees ?? 'Français');
  }

  Future<void> _saveChanges() async {
    final updated = await AuthService.updateProfile(
      nomComplet: _nomController.text,
      telephone: _telController.text,
      languesParlees: _languesController.text,
    );
    if (!mounted) return;
    setState(() => _isEditing = false);
    widget.onUpdated(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFF1B5E20),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.nomComplet,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(widget.user.role),
                    backgroundColor: Colors.green.shade50,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.user.email,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nomController,
            enabled: _isEditing,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _telController,
            enabled: _isEditing,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _languesController,
            enabled: _isEditing,
            decoration: const InputDecoration(
              labelText: 'Langues parlées',
              prefixIcon: Icon(Icons.language),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          if (_isEditing)
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer les modifications'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              label: const Text('Modifier mon profil'),
            ),

          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await AuthService.logout();
              widget.onLogout();
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Se déconnecter',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
