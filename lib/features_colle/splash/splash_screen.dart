import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';

/// Écran de lancement immersif (Splash Screen) — Casamance Tourisme
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
          // Fond bas : photographie authentique de pirogue sur le fleuve Casamance
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.36,
            child: const CasamanceAssetPhoto(
              assetPath: SiteMediaHelper.splashRiverAsset,
              fit: BoxFit.cover,
            ),
          ),

          // Voile doux du haut (Ivoire sable vers transparent pour fondre la photo)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.34, 0.56, 0.85, 1.0],
                colors: [
                  AppTheme.ivorySand,
                  AppTheme.ivorySand,
                  AppTheme.ivorySand.withValues(alpha: 0.15),
                  AppTheme.deepForest.withValues(alpha: 0.65),
                  AppTheme.deepForest.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),

          // Touches décoratives subtiles en bas (courbe latérite + forêt)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 155,
            child: CustomPaint(
              painter: _SplashBottomCurvePainter(),
            ),
          ),

          // Contenu principal animé
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      const CasamanceEmblemMark(size: 102),
                      const SizedBox(height: 18),
                      Text(
                        'Casamance',
                        textAlign: TextAlign.center,
                        style: AppTheme.editorialTitle(
                          fontSize: 40,
                          color: AppTheme.deepForest,
                        ),
                      ),
                      Text(
                        'Tourisme & Visites',
                        textAlign: TextAlign.center,
                        style: AppTheme.editorialTitle(
                          fontSize: 22,
                          color: AppTheme.solarGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.deepForest.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Découvrez. Explorez. Réservez.',
                          style: AppTheme.bodyStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.deepForest,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Sous-titre d'accroche sur la photo
                      Text(
                        'Patrimoine culturel, îles historiques\net bolongs du sud du Sénégal',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyStyle(
                          fontSize: 13.5,
                          color: AppTheme.ivorySand.withValues(alpha: 0.95),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Bouton principal Or Solaire
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.solarGold,
                            foregroundColor: AppTheme.deepForest,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black38,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Commencer l\'exploration',
                                style: AppTheme.bodyStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.deepForest,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: AppTheme.deepForest),
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
    // Accent rouge latérite discret sur le côté gauche
    final redPath = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.05,
        size.width * 0.65,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height * 0.35)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      redPath,
      Paint()..color = AppTheme.lateriteRed.withValues(alpha: 0.72),
    );

    // Vague dominante vert forêt profonde
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
    canvas.drawPath(
      greenPath,
      Paint()..color = AppTheme.deepForest,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
