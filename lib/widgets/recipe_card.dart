import 'package:flutter/material.dart';

import '../models/recipe.dart';
import 'recipe_image.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final bool isSaved;
  final VoidCallback onTap;
  final ValueChanged<bool> onFavoriteTap;
  final ValueChanged<bool> onSavedTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.isSaved,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onSavedTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================

            SizedBox(
              height: 180,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImage(
                      imagePath: recipe.imagePath,
                    ),

                    // FAVORITE BUTTON

                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: scheme.surface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              onFavoriteTap(!isFavorite),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : scheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // SAVED BUTTON

                    Positioned(
                      top: 48,
                      right: 8,
                      child: Material(
                        color: scheme.surface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              onSavedTap(!isSaved),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isSaved
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ================= TITLE =================

            Text(
              recipe.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
            ),

            const SizedBox(height: 6),

            // ================= CATEGORY =================

            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    recipe.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ================= TIME =================

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    recipe.time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ================= RATING =================

            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  recipe.rating,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}