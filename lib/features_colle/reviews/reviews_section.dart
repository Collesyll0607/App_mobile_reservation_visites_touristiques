import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/avis.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_service.dart';
import 'reviews_service.dart';

/// Section Avis & Évaluations affichée dans la fiche éditoriale d'un site
/// Responsable : Collé SYLL (Pôle 1 - Module Avis & Notes)
class ReviewsSection extends StatefulWidget {
  final int patrimoineId;
  final double initialAverage;
  final VoidCallback? onReviewsChanged;

  const ReviewsSection({
    super.key,
    required this.patrimoineId,
    required this.initialAverage,
    this.onReviewsChanged,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  List<Avis> _reviews = [];
  double _average = 4.7;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _average = widget.initialAverage;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final list = await ReviewsService.getReviewsForSite(widget.patrimoineId);
    final avg = await ReviewsService.getAverageRating(
      widget.patrimoineId,
      widget.initialAverage,
    );
    if (!mounted) return;
    setState(() {
      _reviews = list;
      _average = avg;
      _isLoading = false;
    });
  }

  Future<void> _openAddReviewDialog() async {
    final user = await AuthService.getCurrentUser();
    final nameCtrl =
        TextEditingController(text: user?.nomComplet ?? 'Visiteur');
    final commentCtrl = TextEditingController();
    int selectedStars = 5;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.ivorySand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'Partager votre avis',
                style: AppTheme.editorialTitle(
                  fontSize: 20,
                  color: AppTheme.deepForest,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Votre nom',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Note de la visite',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final starIndex = i + 1;
                        return IconButton(
                          onPressed: () =>
                              setDialogState(() => selectedStars = starIndex),
                          icon: Icon(
                            starIndex <= selectedStars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppTheme.champagneGold,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Votre commentaire',
                        hintText: 'Racontez votre expérience sur ce site...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepForest,
                    foregroundColor: AppTheme.ivorySand,
                  ),
                  onPressed: () async {
                    if (commentCtrl.text.trim().isEmpty) return;
                    await ReviewsService.addReview(
                      patrimoineId: widget.patrimoineId,
                      auteur: nameCtrl.text,
                      note: selectedStars,
                      commentaire: commentCtrl.text,
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    await _loadReviews();
                    widget.onReviewsChanged?.call();
                  },
                  child: const Text('Publier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avis des visiteurs',
                    style: AppTheme.editorialTitle(
                      fontSize: 20,
                      color: AppTheme.deepForest,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.champagneGold,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_average.toStringAsFixed(1)} / 5 • ${_reviews.length} avis',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.earthBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _openAddReviewDialog,
              icon: const Icon(Icons.rate_review_outlined, size: 17),
              label: const Text('Donner un avis'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.earthBrown,
                side: const BorderSide(color: AppTheme.earthBrown),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                textStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppTheme.deepForest),
            ),
          )
        else if (_reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warmCream,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.sandBorder),
            ),
            child: Text(
              'Aucun avis pour le moment. Soyez le premier à partager votre découverte !',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          )
        else
          ...List.generate(_reviews.length, (i) {
            final r = _reviews[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.deepForest,
                        child: Text(
                          r.auteur.isNotEmpty
                              ? r.auteur[0].toUpperCase()
                              : 'V',
                          style: GoogleFonts.playfairDisplay(
                            color: AppTheme.champagneGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.auteur,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepForest,
                              ),
                            ),
                            Text(
                              'Publié le ${r.datePublication}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (idx) => Icon(
                            idx < r.note
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: AppTheme.champagneGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    r.commentaire,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textDark,
                      height: 1.48,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
