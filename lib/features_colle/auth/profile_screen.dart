import 'package:flutter/material.dart';
import '../../core/models/utilisateur.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';
import '../../features_thiamba/my_bookings/my_bookings_screen.dart';
import '../../main.dart';
import 'auth_service.dart';

/// Écran de Profil Utilisateur — Design System v2
/// Typographie Fraunces/Plus Jakarta Sans, header noble avec avatar soigné,
/// tuiles de paramètres modernes, formulaires avec styles DS et dark-aware.
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
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        backgroundColor: AppTheme.forestGreen,
        content: const Text('Profil mis à jour avec succès'),
      ),
    );
  }

  void _openNotificationsDialog() {
    final surface = AppTheme.surfaceOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius16),
          ),
          title: Text(
            'Préférences de notifications',
            style: AppTheme.headingStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile.adaptive(
                activeThumbColor: AppTheme.forestGreen,
                title: Text(
                  'Rappels de visite',
                  style: AppTheme.bodyStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textCol,
                  ),
                ),
                subtitle: Text(
                  'Alerte 24h avant votre visite guidée ou traversée',
                  style: AppTheme.bodyStyle(fontSize: 12, color: mutedCol),
                ),
                value: _notifRappels,
                onChanged: (v) {
                  setDlgState(() => _notifRappels = v);
                  setState(() => _notifRappels = v);
                },
              ),
              SwitchListTile.adaptive(
                activeThumbColor: AppTheme.forestGreen,
                title: Text(
                  'Nouveaux sites & circuits',
                  style: AppTheme.bodyStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textCol,
                  ),
                ),
                subtitle: Text(
                  'Actualités culturelles et événements à Ziguinchor',
                  style: AppTheme.bodyStyle(fontSize: 12, color: mutedCol),
                ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _openHelpDialog() {
    final surface = AppTheme.surfaceOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.support_agent_rounded,
              color: AppTheme.forestGreen,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aide & Assistance',
                style: AppTheme.headingStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
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
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Adresse : Quartier Escale, Avenue du Général de Gaulle, Ziguinchor\n'
              '• Assistance voyageurs : +221 33 991 10 20\n'
              '• Vos billets QR restent consultables hors-ligne dans "Mes Réservations".\n'
              '• Annulation possible depuis votre espace si le statut est "En attente".',
              style: AppTheme.bodyStyle(
                fontSize: 12.5,
                color: mutedCol,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surfaceOf(context);
    final background = AppTheme.backgroundOf(context);
    final border = AppTheme.borderOf(context);
    final textCol = AppTheme.textOf(context);
    final mutedCol = AppTheme.mutedOf(context);
    final initials = widget.user.nomComplet.trim().isNotEmpty
        ? widget.user.nomComplet.trim()[0].toUpperCase()
        : 'T';

    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── EN-TÊTE NOBLE AVEC AVATAR ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.forestGreen,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.ocreGold.withValues(alpha: 0.25),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radius24),
                                ),
                                child: Text(
                                  widget.user.role,
                                  style: AppTheme.bodyStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.ocreGold,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Modifier mes informations',
                                onPressed: () => setState(() {
                                  _showPersonalInfo = true;
                                  _isEditing = true;
                                }),
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.warmSand,
                              border: Border.all(
                                color: AppTheme.ocreGold,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: AppTheme.headingStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.user.nomComplet,
                            textAlign: TextAlign.center,
                            style: AppTheme.headingStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.user.email,
                            style: AppTheme.bodyStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── MENU ET OPTIONS DU COMPTE ──
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(AppTheme.radius16),
                          border: Border.all(color: border),
                          boxShadow: AppTheme.shadowFor(context),
                        ),
                        child: Column(
                          children: [
                            _menuItem(
                              icon: Icons.confirmation_number_outlined,
                              title: 'Mes réservations',
                              subtitle: 'Consulter mes visites et billets QR',
                              textCol: textCol,
                              mutedCol: mutedCol,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyBookingsScreen(),
                                  ),
                                );
                              },
                            ),
                            _divider(border),
                            _menuItem(
                              icon: Icons.favorite_border_rounded,
                              title: 'Mes favoris',
                              subtitle: 'Sites enregistrés hors-ligne',
                              textCol: textCol,
                              mutedCol: mutedCol,
                              onTap: () => MainNavigationShell.switchTab(
                                context,
                                MainNavigationShell.tabFavoris,
                              ),
                            ),
                            _divider(border),
                            _menuItem(
                              icon: Icons.person_outline_rounded,
                              title: 'Mes informations personnelles',
                              subtitle: _showPersonalInfo
                                  ? 'Masquer le formulaire'
                                  : '${widget.user.telephone} • ${widget.user.languesParlees ?? "Français"}',
                              textCol: textCol,
                              mutedCol: mutedCol,
                              trailingIcon: _showPersonalInfo
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.chevron_right_rounded,
                              onTap: () => setState(
                                () => _showPersonalInfo = !_showPersonalInfo,
                              ),
                            ),
                            if (_showPersonalInfo)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _nomController,
                                      enabled: _isEditing,
                                      style: AppTheme.bodyStyle(color: textCol),
                                      decoration: InputDecoration(
                                        labelText: 'Nom complet',
                                        prefixIcon: const Icon(Icons.badge_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radius12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _telController,
                                      enabled: _isEditing,
                                      style: AppTheme.bodyStyle(color: textCol),
                                      decoration: InputDecoration(
                                        labelText: 'Téléphone',
                                        prefixIcon: const Icon(Icons.phone_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radius12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _languesController,
                                      enabled: _isEditing,
                                      style: AppTheme.bodyStyle(color: textCol),
                                      decoration: InputDecoration(
                                        labelText: 'Langues préférées',
                                        prefixIcon: const Icon(Icons.language),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radius12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    if (_isEditing)
                                      ElevatedButton.icon(
                                        onPressed: _saveChanges,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.forestGreen,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radius12,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.save_rounded),
                                        label: const Text(
                                          'Enregistrer les modifications',
                                        ),
                                      )
                                    else
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            setState(() => _isEditing = true),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.forestGreen,
                                          side: const BorderSide(
                                            color: AppTheme.forestGreen,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radius12,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                        label: const Text(
                                          'Modifier mes informations',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            _divider(border),
                            _menuItem(
                              icon: Icons.tune_rounded,
                              title: 'Paramètres',
                              subtitle: _notifRappels
                                  ? 'Notifications & rappels activés'
                                  : 'Préférences de notifications',
                              textCol: textCol,
                              mutedCol: mutedCol,
                              onTap: _openNotificationsDialog,
                            ),
                            _divider(border),
                            _menuItem(
                              icon: Icons.help_outline_rounded,
                              title: 'Aide et assistance',
                              subtitle: 'Office du Tourisme de Ziguinchor',
                              textCol: textCol,
                              mutedCol: mutedCol,
                              onTap: _openHelpDialog,
                            ),
                            _divider(border),
                            _menuItem(
                              icon: Icons.logout_rounded,
                              title: 'Déconnexion',
                              subtitle: 'Fermer votre session en toute sécurité',
                              textCol: textCol,
                              mutedCol: mutedCol,
                              isDanger: true,
                              onTap: () async {
                                await AuthService.logout();
                                widget.onLogout();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bandeau visuel patrimoine Casamance
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                        child: SizedBox(
                          height: 92,
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
                                      AppTheme.forestGreen.withValues(alpha: 0.8),
                                      AppTheme.forestGreen.withValues(alpha: 0.3),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Explorez le patrimoine\nde la Casamance',
                                  style: AppTheme.headingStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(Color border) {
    return Divider(
      height: 1,
      indent: 56,
      color: border,
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textCol,
    required Color mutedCol,
    IconData trailingIcon = Icons.chevron_right_rounded,
    bool isDanger = false,
  }) {
    final color = isDanger ? AppTheme.errorRed : AppTheme.forestGreen;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: AppTheme.bodyStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: isDanger ? AppTheme.errorRed : textCol,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.bodyStyle(
          fontSize: 12,
          color: mutedCol,
        ),
      ),
      trailing: Icon(trailingIcon, color: color, size: 20),
      onTap: onTap,
    );
  }
}
