import 'package:flutter/material.dart';
import '../../core/models/utilisateur.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../main.dart';
import 'auth_service.dart';

/// Écran de Profil Utilisateur — DA Casamance Tourisme
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
  bool _showPersonalInfo = false;
  bool _isEditing = false;
  bool _notifRappels = true;
  bool _notifPromos = true;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.user.nomComplet);
    _telController = TextEditingController(text: widget.user.telephone);
    _languesController =
        TextEditingController(text: widget.user.languesParlees ?? 'Français');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telController.dispose();
    _languesController.dispose();
    super.dispose();
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

  void _openNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Préférences de notifications',
            style: AppTheme.editorialTitle(
                fontSize: 19, color: AppTheme.deepForest),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                activeThumbColor: AppTheme.deepForest,
                title: const Text('Rappels de visite'),
                subtitle: const Text(
                    'Alerte 24h avant votre visite guidée ou traversée'),
                value: _notifRappels,
                onChanged: (v) {
                  setDlgState(() => _notifRappels = v);
                  setState(() => _notifRappels = v);
                },
              ),
              SwitchListTile(
                activeThumbColor: AppTheme.deepForest,
                title: const Text('Nouveaux sites & circuits'),
                subtitle: const Text(
                    'Actualités culturelles et événements à Ziguinchor'),
                value: _notifPromos,
                onChanged: (v) {
                  setDlgState(() => _notifPromos = v);
                  setState(() => _notifPromos = v);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _openHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.support_agent_rounded,
                color: AppTheme.deepForest),
            const SizedBox(width: 8),
            Text(
              'Aide & Assistance',
              style: AppTheme.editorialTitle(
                  fontSize: 19, color: AppTheme.deepForest),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Office Régional du Tourisme — Ziguinchor',
              style: AppTheme.bodyStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepForest,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '• Adresse : Quartier Escale, Avenue du Général de Gaulle, Ziguinchor\n'
              '• Assistance voyageurs : +221 33 991 10 20\n'
              '• Vos billets QR restent consultables hors-ligne dans "Mes Réservations".\n'
              '• Annulation possible depuis votre espace si le statut est "En attente".',
              style: AppTheme.bodyStyle(fontSize: 12.5, height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.user.nomComplet.trim().isNotEmpty
        ? widget.user.nomComplet.trim()[0].toUpperCase()
        : 'T';

    return SingleChildScrollView(
      child: Column(
        children: [
          // En-tête vert forêt courbé avec Avatar centré
          CasamanceCurvedHeader(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.solarGold.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.user.role,
                        style: AppTheme.bodyStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.solarGold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Modifier mes informations',
                      onPressed: () => setState(() {
                        _showPersonalInfo = true;
                        _isEditing = true;
                      }),
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.ivorySand,
                    border: Border.all(color: AppTheme.solarGold, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTheme.editorialTitle(
                        fontSize: 36,
                        color: AppTheme.deepForest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.user.nomComplet,
                  textAlign: TextAlign.center,
                  style: AppTheme.editorialTitle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.email,
                  style: AppTheme.bodyStyle(
                    fontSize: 13,
                    color: AppTheme.ivorySand.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
            child: Column(
              children: [
                // Menu structuré conforme au cahier des charges
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    children: [
                      _menuItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Mes réservations',
                        subtitle: 'Consulter mes visites et billets QR',
                        onTap: () => MainNavigationShell.switchTab(context, 2),
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'Mes favoris',
                        subtitle: 'Sites enregistrés hors-ligne',
                        onTap: () => MainNavigationShell.switchTab(context, 3),
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Mes informations personnelles',
                        subtitle: _showPersonalInfo
                            ? 'Masquer le formulaire'
                            : '${widget.user.telephone} • ${widget.user.languesParlees ?? "Français"}',
                        trailingIcon: _showPersonalInfo
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.chevron_right_rounded,
                        onTap: () => setState(
                            () => _showPersonalInfo = !_showPersonalInfo),
                      ),
                      if (_showPersonalInfo)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _nomController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Nom complet',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _telController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Téléphone',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _languesController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Langues préférées',
                                  prefixIcon: Icon(Icons.language),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_isEditing)
                                ElevatedButton.icon(
                                  onPressed: _saveChanges,
                                  icon: const Icon(Icons.save_rounded),
                                  label: const Text(
                                      'Enregistrer les modifications'),
                                )
                              else
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      setState(() => _isEditing = true),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Modifier mes informations'),
                                ),
                            ],
                          ),
                        ),
                      _divider(),
                      _menuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: _notifRappels
                            ? 'Rappels de visites activés'
                            : 'Notifications désactivées',
                        onTap: _openNotificationsDialog,
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Aide & Support',
                        subtitle: 'Assistance Office du Tourisme Ziguinchor',
                        onTap: _openHelpDialog,
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.logout_rounded,
                        title: 'Déconnexion',
                        subtitle: 'Fermer votre session en toute sécurité',
                        isDanger: true,
                        onTap: () async {
                          await AuthService.logout();
                          widget.onLogout();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Bandeau visuel patrimoine Casamance
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 86,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const CasamanceAssetPhoto(
                          assetPath: SiteMediaHelper.heritageFooterAsset,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.deepForest.withValues(alpha: 0.72),
                                AppTheme.deepForest.withValues(alpha: 0.25),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Explorez le patrimoine\nde la Casamance',
                            style: AppTheme.editorialTitle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 54,
      color: AppTheme.deepForest.withValues(alpha: 0.08),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    IconData trailingIcon = Icons.chevron_right_rounded,
    bool isDanger = false,
  }) {
    final color = isDanger ? AppTheme.lateriteRed : AppTheme.deepForest;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      title: Text(
        title,
        style: AppTheme.bodyStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDanger ? AppTheme.lateriteRed : AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.bodyStyle(
          fontSize: 11.5,
          color: AppTheme.textMuted,
        ),
      ),
      trailing: Icon(trailingIcon, color: color),
      onTap: onTap,
    );
  }
}
