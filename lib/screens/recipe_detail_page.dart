import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../models/recipe_review.dart';
import '../services/recipe_feedback_service.dart';
import '../widgets/recipe_image.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final bool isFavorite;
  final bool isSaved;
  final ValueChanged<bool> onFavoriteTap;
  final ValueChanged<bool> onSavedTap;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.isSaved,
    required this.onFavoriteTap,
    required this.onSavedTap,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late bool isFavorite;
  late bool isSaved;
  int servings = 2;
  final feedbackService = RecipeFeedbackService();
  final reviewController = TextEditingController();
  bool isSubmittingReview = false;
  bool isSubmittingRating = false;
  bool isEditingReview = false;
  int? selectedReviewRating;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    isSaved = widget.isSaved;
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  bool get supportsFeedback =>
      widget.recipe.id.isNotEmpty && !widget.recipe.id.startsWith('legacy_');

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _setRating(int rating) async {
    if (FirebaseAuth.instance.currentUser == null) {
      _showMessage('Please log in to rate recipes.');
      return;
    }
    if (isSubmittingRating) return;
    final wasRated = selectedReviewRating != null;
    setState(() {
      isSubmittingRating = true;
      selectedReviewRating = rating;
    });
    try {
      await feedbackService.setRating(widget.recipe.id, rating);
      _showMessage(wasRated ? 'Rating updated.' : 'Rating submitted.');
    } on FirebaseException catch (error) {
      _showMessage(_friendlyFirebaseError('rating', error));
    } catch (error) {
      _showMessage(_friendlyError('rating', error));
    } finally {
      if (mounted) setState(() => isSubmittingRating = false);
    }
  }

  Future<void> _saveReview(int? rating) async {
    if (reviewController.text.trim().isEmpty) {
      _showMessage('Please write a review first.');
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      _showMessage('Please log in to write a review.');
      return;
    }
    setState(() => isSubmittingReview = true);
    final wasEditing = isEditingReview;
    try {
      await feedbackService.saveReview(
        widget.recipe.id,
        reviewController.text,
        rating: rating,
      );
      reviewController.clear();
      setState(() => isEditingReview = false);
      _showMessage(wasEditing ? 'Review updated.' : 'Review saved.');
    } on FirebaseException catch (error) {
      _showMessage(_friendlyFirebaseError('review', error));
    } catch (error) {
      _showMessage(_friendlyError('review', error));
    } finally {
      if (mounted) setState(() => isSubmittingReview = false);
    }
  }

  String _friendlyFirebaseError(String action, FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Unable to save $action. Firebase permissions rejected the request.';
      case 'unavailable':
        return 'Unable to save $action while offline. Please try again.';
      case 'not-found':
        return 'This recipe is no longer available online.';
      default:
        return 'Unable to save $action (${error.code}). Please try again.';
    }
  }

  String _friendlyError(String action, Object error) {
    return 'Unable to save $action. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(color: Color(0xFFE8F3EE)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RecipeImage(imagePath: recipe.imagePath),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _DetailActionButton(
                        backgroundColor: Colors.white,
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          _DetailActionButton(
                            backgroundColor: Colors.white,
                            icon: isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            iconColor: isFavorite ? Colors.red : Colors.black87,
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                              widget.onFavoriteTap(isFavorite);
                            },
                          ),
                          const SizedBox(width: 10),
                          _DetailActionButton(
                            backgroundColor: Colors.white,
                            icon: isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            iconColor: isSaved
                                ? const Color(0xFF4FA58C)
                                : Colors.black87,
                            onPressed: () {
                              setState(() {
                                isSaved = !isSaved;
                              });
                              widget.onSavedTap(isSaved);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 5,
                          width: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9DDE2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 26,
                          height: 1.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _RecipeMeta(
                            icon: Icons.star,
                            iconColor: const Color(0xFFF2C94C),
                            label: recipe.rating,
                          ),
                          const SizedBox(width: 18),
                          _RecipeMeta(
                            icon: Icons.access_time,
                            iconColor: const Color(0xFF4FA58C),
                            label: recipe.time,
                          ),
                          const SizedBox(width: 18),
                          const _RecipeMeta(
                            icon: Icons.local_fire_department,
                            iconColor: Colors.deepOrangeAccent,
                            label: 'Calories unavailable',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recipe.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (supportsFeedback) ...[
                        const SizedBox(height: 26),
                        _FeedbackSection(
                          recipeId: recipe.id,
                          service: feedbackService,
                          reviewController: reviewController,
                          isSubmittingReview: isSubmittingReview,
                          isSubmittingRating: isSubmittingRating,
                          isEditingReview: isEditingReview,
                          selectedReviewRating: selectedReviewRating,
                          onRatingSelected: _setRating,
                          onSubmitReview: _saveReview,
                          onDeleteReview: (review) async {
                            try {
                              await feedbackService.deleteReview(
                                recipe.id,
                                review.id,
                              );
                              _showMessage('Review deleted.');
                            } catch (_) {
                              _showMessage('Unable to delete your review.');
                            }
                          },
                          onEditReview: (review) {
                            setState(() {
                              reviewController.text = review.comment;
                              selectedReviewRating = review.rating;
                              isEditingReview = true;
                            });
                            _showMessage('Review loaded for editing.');
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Community ratings are available for online recipes.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'How many servings?',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          _ServingsSelector(
                            servings: servings,
                            onDecrease: () {
                              if (servings > 1) {
                                setState(() {
                                  servings--;
                                });
                              }
                            },
                            onIncrease: () {
                              setState(() {
                                servings++;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(
                        recipe.ingredients.length,
                        (index) => _IngredientRow(
                          ingredient: recipe.ingredients[index],
                          icon:
                              _ingredientIcons[index % _ingredientIcons.length],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(
                        recipe.instructions.length,
                        (index) => _InstructionRow(
                          number: index + 1,
                          instruction: recipe.instructions[index],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cooking mode started!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.restaurant),
                          label: const Text('Start Cooking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FA58C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final String recipeId;
  final RecipeFeedbackService service;
  final TextEditingController reviewController;
  final bool isSubmittingReview;
  final bool isSubmittingRating;
  final bool isEditingReview;
  final int? selectedReviewRating;
  final ValueChanged<int> onRatingSelected;
  final ValueChanged<int?> onSubmitReview;
  final Future<void> Function(RecipeReview review) onDeleteReview;
  final ValueChanged<RecipeReview> onEditReview;

  const _FeedbackSection({
    required this.recipeId,
    required this.service,
    required this.reviewController,
    required this.isSubmittingReview,
    required this.isSubmittingRating,
    required this.isEditingReview,
    required this.selectedReviewRating,
    required this.onRatingSelected,
    required this.onSubmitReview,
    required this.onDeleteReview,
    required this.onEditReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ratings & Reviews',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<RecipeRatingSummary>(
          stream: service.ratingSummaryStream(recipeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            final summary =
                snapshot.data ??
                const RecipeRatingSummary(average: 0, count: 0);
            return Row(
              children: [
                Text(
                  summary.count == 0
                      ? 'No ratings yet'
                      : summary.average.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Color(0xFFF2C94C)),
                const SizedBox(width: 8),
                Text('${summary.count} rating${summary.count == 1 ? '' : 's'}'),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        StreamBuilder<int>(
          stream: service.currentUserRatingStream(recipeId),
          builder: (context, snapshot) => Row(
            children: [
              const Text('Your rating'),
              const SizedBox(width: 10),
              for (var rating = 1; rating <= 5; rating++)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  tooltip: '$rating star${rating == 1 ? '' : 's'}',
                  onPressed: isSubmittingRating
                      ? null
                      : () => onRatingSelected(rating),
                  icon: Icon(
                    rating <= (selectedReviewRating ?? snapshot.data ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    color: const Color(0xFFF2C94C),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reviewController,
          minLines: 2,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Write a review',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: isSubmittingReview
                ? null
                : () => onSubmitReview(selectedReviewRating),
            icon: isSubmittingReview
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(isEditingReview ? 'Update Review' : 'Submit Review'),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<RecipeReview>>(
          stream: service.reviewsStream(recipeId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Reviews are unavailable right now.');
            }
            final reviews = snapshot.data ?? const <RecipeReview>[];
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No reviews yet. Be the first to share your experience!',
                ),
              );
            }
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            return Column(
              children: reviews
                  .map(
                    (review) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      color: const Color(0xFFF6F7F9),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (review.rating != null)
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < review.rating!
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: const Color(0xFFF2C94C),
                                        ),
                                      ),
                                    ),
                                  Text(review.comment),
                                  if (review.updatedAt != null &&
                                      review.createdAt != null &&
                                      review.updatedAt != review.createdAt)
                                    const Text(
                                      'Edited',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (review.userId == currentUserId)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit review',
                                    onPressed: () => onEditReview(review),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete review',
                                    onPressed: () => onDeleteReview(review),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

const List<IconData> _ingredientIcons = [
  Icons.restaurant,
  Icons.eco,
  Icons.local_dining,
  Icons.circle,
];

class _DetailActionButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const _DetailActionButton({
    required this.backgroundColor,
    required this.icon,
    this.iconColor = Colors.black87,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          height: 46,
          width: 46,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _RecipeMeta extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _RecipeMeta({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServingsSelector extends StatelessWidget {
  final int servings;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ServingsSelector({
    required this.servings,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE1E5)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SelectorButton(icon: Icons.remove, onPressed: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(
              '$servings',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _SelectorButton(icon: Icons.add, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _SelectorButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SelectorButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox(
        height: 32,
        width: 28,
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String ingredient;
  final IconData icon;

  const _IngredientRow({required this.ingredient, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4FA58C), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(
            '1 serving',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final int number;
  final String instruction;

  const _InstructionRow({required this.number, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3EE),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Color(0xFF4FA58C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                instruction,
                style: const TextStyle(fontSize: 14, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
