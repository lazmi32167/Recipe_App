import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'favorite_screen.dart';

class SavedScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> savedRecipes;
  final Function(String) onSavedTap;
  final Function(Recipe) onRecipeTap;

  const SavedScreen({
    super.key,
    required this.recipes,
    required this.savedRecipes,
    required this.onSavedTap,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: recipes.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No Saved Recipes',
              subtitle: 'Save recipes to find them easily later.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved Recipes 🔖',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${recipes.length} saved recipes',
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
                        isFavorite: false,
                        isSaved: true,
                        onFavoriteTap: () {},
                        onSavedTap: () {
                          onSavedTap(recipe.title);
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