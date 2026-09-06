import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class FavoriteScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> favoriteRecipes;
  final Set<String> savedRecipes;
  final Function(Recipe, bool) onFavoriteTap;
  final Function(Recipe, bool) onSavedTap;
  final Function(Recipe) onRecipeTap;

  const FavoriteScreen({
    super.key,
    required this.recipes,
    required this.favoriteRecipes,
    required this.savedRecipes,
    required this.onFavoriteTap,
    required this.onSavedTap,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: recipes.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No Favorite Recipes Yet',
              subtitle: 'Your favorite recipes will appear here.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Favorites ❤️',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${recipes.length} favorite recipes',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 25),
                  GridView.builder(
                    itemCount: recipes.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        isFavorite: favoriteRecipes.any(
                          recipe.matchesIdentifier,
                        ),
                        isSaved: savedRecipes.any(recipe.matchesIdentifier),
                        onFavoriteTap: (shouldBeFavorite) {
                          onFavoriteTap(recipe, shouldBeFavorite);
                        },
                        onSavedTap: (shouldBeSaved) {
                          onSavedTap(recipe, shouldBeSaved);
                        },
                        onTap: () {
                          onRecipeTap(recipe);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color(0xFF4FA58C)),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
