import 'package:flutter/material.dart';
import '../../core/models/avis.dart';
import '../auth/auth_service.dart';
import 'reviews_service.dart';

/// Section Avis & Évaluations affichée dans la fiche détail d'un site
/// Responsable : Collé SYLL (Pôle 1 - Module Avis & Notes)
class ReviewsSection extends StatefulWidget {
  final int patrimoineId;
  final double initialAverage;

  const ReviewsSection({
    super.key,
    required this.patrimoineId,
    required this.initialAverage,
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
              title: const Text('Donner mon avis sur ce site'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Votre nom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final starIndex = i + 1;
                        return IconButton(
                          onPressed: () =>
                              setDialogState(() => selectedStars = starIndex),
                          icon: Icon(
                            starIndex <= selectedStars
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
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
                        hintText: 'Partagez votre expérience de visite...',
                        border: OutlineInputBorder(),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avis des visiteurs (${_reviews.length}) — ★ $_average/5',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _openAddReviewDialog,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Ajouter un avis'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Text(
            'Aucun avis pour le moment. Soyez le premier à partager votre expérience !',
            style: TextStyle(color: Colors.grey),
          )
        else
          ..._reviews.map(
            (r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    r.auteur.isNotEmpty ? r.auteur[0].toUpperCase() : 'V',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.auteur,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(
                        5,
                        (idx) => Icon(
                          idx < r.note ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(r.commentaire),
                    const SizedBox(height: 4),
                    Text(
                      'Publié le ${r.datePublication}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
