import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';

/// Écran de lancement artistique — Casamance Tourisme & Visites
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
      duration: const Duration(milliseconds: 950),
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
      backgroundColor: AppTheme.ivorySand,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.34,
            child: const CasamanceAssetPhoto(
              assetPath: SiteMediaHelper.splashRiverAsset,
              fit: BoxFit.cover,
            ),
          ),

          // Voile Ivoire Sable vers Vert Forêt Profond
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.32, 0.56, 0.84, 1.0],
                colors: [
                  AppTheme.ivorySand,
                  AppTheme.ivorySand,
                  AppTheme.ivorySand.withValues(alpha: 0.14),
                  AppTheme.deepForest.withValues(alpha: 0.68),
                  AppTheme.deepForest.withValues(alpha: 0.96),
                ],
              ),
            ),
          ),

          // Courbe organique hibiscus + forêt profonde
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 150,
            child: CustomPaint(painter: _SplashBottomCurvePainter()),
          ),

          const Positioned(
            left: 16,
            bottom: 108,
            child: CasamanceHibiscusBlossom(size: 56, opacity: 0.90),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const CasamanceEmblemMark(size: 98),
                      const SizedBox(height: 16),
                      Text(
                        'Casamance',
                        textAlign: TextAlign.center,
                        style: AppTheme.editorialTitle(
                          fontSize: 42,
                          color: AppTheme.deepForest,
                        ),
                      ),
                      Text(
                        'Tourisme & Visites',
                        textAlign: TextAlign.center,
                        style: AppTheme.editorialTitle(
                          fontSize: 22,
                          color: AppTheme.earthBrown,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.terracottaSoft,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.earthBrown.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          'Explorez. Réservez. Profitez.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepForest,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Bolongs émeraude, plages sauvages de Cap Skirring,\ncases à impluvium et traditions diola',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.ivorySand,
                          height: 1.48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.champagneGold,
                            foregroundColor: AppTheme.deepForest,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Commencer',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.deepForest,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppTheme.deepForest,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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

class _SplashBottomCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hibiscusPath = Path()
      ..moveTo(0, size.height * 0.26)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.06,
        size.width * 0.65,
        size.height * 0.44,
      )
      ..lineTo(size.width, size.height * 0.34)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      hibiscusPath,
      Paint()..color = AppTheme.hibiscusRed.withValues(alpha: 0.72),
    );

    final greenPath = Path()
      ..moveTo(0, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.68,
        size.width * 0.72,
        size.height * 0.30,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.14,
        size.width,
        size.height * 0.26,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = AppTheme.deepForest);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
