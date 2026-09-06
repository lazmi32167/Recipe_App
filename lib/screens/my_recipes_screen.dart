import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/recipe_service.dart';
import '../services/user_recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'favorite_screen.dart';
import 'recipe_detail_page.dart';

class MyRecipesScreen extends StatelessWidget {
  MyRecipesScreen({super.key});

  final recipeService = RecipeService();
  final userRecipeService = UserRecipeService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Recipes')),
      backgroundColor: const Color(0xFFF6F7F9),
      body: StreamBuilder(
        stream: recipeService.getMyRecipes(user.uid),
        builder: (context, snapshot) {
          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return const EmptyState(
              icon: Icons.restaurant_menu,
              title: 'No recipes added yet',
              subtitle: 'Recipes you create will appear here.',
            );
          }

          return StreamBuilder<Set<String>>(
            stream: userRecipeService.recipeIdsStream('favorites'),
            builder: (context, favoriteSnapshot) {
              return StreamBuilder<Set<String>>(
                stream: userRecipeService.recipeIdsStream('savedRecipes'),
                builder: (context, savedSnapshot) {
                  final favorites = favoriteSnapshot.data ?? <String>{};
                  final saved = savedSnapshot.data ?? <String>{};
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: recipes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Stack(
                        children: [
                          RecipeCard(
                            recipe: recipe,
                            isFavorite: favorites.any(recipe.matchesIdentifier),
                            isSaved: saved.any(recipe.matchesIdentifier),
                            onFavoriteTap: (value) =>
                                userRecipeService.toggleFavorite(recipe, value),
                            onSavedTap: (value) =>
                                userRecipeService.toggleSaved(recipe, value),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailPage(
                                  recipe: recipe,
                                  isFavorite: favorites.any(
                                    recipe.matchesIdentifier,
                                  ),
                                  isSaved: saved.any(recipe.matchesIdentifier),
                                  onFavoriteTap: (value) => userRecipeService
                                      .toggleFavorite(recipe, value),
                                  onSavedTap: (value) => userRecipeService
                                      .toggleSaved(recipe, value),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                tooltip: 'Delete recipe',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _confirmDelete(context, recipe.id),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String recipeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: const Text('This recipe will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await recipeService.deleteRecipe(recipeId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Recipe deleted.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete recipe: $error')),
        );
      }
    }
  }
}
