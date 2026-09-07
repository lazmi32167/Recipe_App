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
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              width: 170,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  color: const Color(0xFFE8F3EE),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RecipeImage(imagePath: recipe.imagePath),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onFavoriteTap(!isFavorite),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black87,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 44,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onSavedTap(!isSaved),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved
                                  ? const Color(0xFF4FA58C)
                                  : Colors.black87,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              recipe.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: Colors.grey),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    recipe.category,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('•', style: TextStyle(color: Colors.grey)),
                ),
                const Icon(Icons.access_time, size: 13, color: Colors.grey),
                const SizedBox(width: 2),
                Text(
                  recipe.time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
