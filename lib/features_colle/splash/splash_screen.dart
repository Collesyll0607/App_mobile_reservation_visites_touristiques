import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/site_media_helper.dart';
import '../../core/widgets/casamance_widgets.dart';

/// Écran d'accueil / bienvenue moderne et responsive (Mobile & Ordinateur)
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 860;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 36 : 20,
                  vertical: 20,
                ),
                child: isWide ? _buildDesktopLayout() : _buildMobileLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: _buildTextContent(alignCenter: false),
          ),
        ),
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: const AspectRatio(
              aspectRatio: 4 / 3,
              child: CasamanceAssetPhoto(
                assetPath: SiteMediaHelper.splashRiverAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: const SizedBox(
              width: double.infinity,
              child: CasamanceAssetPhoto(
                assetPath: SiteMediaHelper.splashRiverAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextContent(alignCenter: true),
      ],
    );
  }

  Widget _buildTextContent({required bool alignCenter}) {
    final align =
        alignCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = alignCenter ? TextAlign.center : TextAlign.left;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.paleGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppTheme.forestGreen,
              ),
              const SizedBox(width: 6),
              Text(
                'Ziguinchor • Casamance, Sénégal',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Casamance\nTourisme & Visites',
          textAlign: textAlign,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Explorez. Réservez. Profitez.',
          textAlign: textAlign,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.naturalGreen,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Découvrez les sites emblématiques de la Casamance, consultez leur localisation GPS, réservez votre guide et recevez votre billet QR en toute simplicité.',
          textAlign: textAlign,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: AppTheme.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: alignCenter ? double.infinity : 260,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: widget.onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Text(
              'Commencer',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            label: const Icon(Icons.arrow_forward_rounded, size: 19),
          ),
        ),
      ],
    );
  }
}
