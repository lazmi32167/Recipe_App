import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/user_recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'edit_recipe_screen.dart';
import 'favorite_screen.dart';
import 'recipe_detail_page.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final recipeService = RecipeService();
  final userRecipeService = UserRecipeService();
  final Set<String> deletingRecipeIds = <String>{};

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
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    tooltip: 'Edit recipe',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: deletingRecipeIds.contains(recipe.id)
                                        ? null
                                        : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditRecipeScreen(
                                                recipe: recipe,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                CircleAvatar(
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
                                    onPressed: deletingRecipeIds.contains(recipe.id)
                                        ? null
                                        : () => _confirmDelete(context, recipe),
                                  ),
                                ),
                              ],
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

  Future<void> _confirmDelete(BuildContext context, Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: const Text(
          'Are you sure you want to delete this recipe? This action cannot be undone.',
        ),
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
    setState(() => deletingRecipeIds.add(recipe.id));
    try {
      await recipeService.deleteRecipe(recipe);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text('Recipe deleted successfully.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete recipe.')),
        );
      }
    } finally {
      if (mounted) setState(() => deletingRecipeIds.remove(recipe.id));
    }
  }
}
