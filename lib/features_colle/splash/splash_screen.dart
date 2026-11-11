import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';

/// Écran de bienvenue / Splash immersif — Casamance Tourisme & Visites
class SplashScreen extends StatefulWidget {
  final VoidCallback onStart;

  const SplashScreen({super.key, required this.onStart});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.forestGreen,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Grande photographie authentique de la Casamance
          const CasamanceAssetPhoto(
            assetPath: SiteMediaHelper.splashRiverAsset,
            fit: BoxFit.cover,
          ),

          // Dégradé vert forêt profond pour une lisibilité irréprochable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.68, 1.0],
                colors: [
                  AppTheme.forestGreen.withValues(alpha: 0.72),
                  AppTheme.forestGreen.withValues(alpha: 0.28),
                  AppTheme.forestGreen.withValues(alpha: 0.78),
                  AppTheme.forestGreen.withValues(alpha: 0.96),
                ],
              ),
            ),
          ),

          // Contenu animé
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const CasamanceEmblemMark(
                        size: 92,
                        darkBackground: true,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Text(
                          'Ziguinchor • Sud du Sénégal',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Casamance\nTourisme & Visites',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explorez. Réservez. Profitez.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warmOrange,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),

                      // Présentation visuelle de la destination
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Découvrez la perle verte du Sénégal',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bolongs paisibles, architecture diola, patrimoine historique et accueil chaleureux à portée de main.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.90),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                _DestinationTag(
                                  icon: Icons.eco_outlined,
                                  label: 'Bolongs',
                                ),
                                _DestinationTag(
                                  icon: Icons.account_balance_outlined,
                                  label: 'Patrimoine',
                                ),
                                _DestinationTag(
                                  icon: Icons.confirmation_number_outlined,
                                  label: 'Billets QR',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bouton Commencer
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warmOrange,
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Commencer',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
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

class _DestinationTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DestinationTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.forestGreen.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.5, color: AppTheme.warmOrange),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
