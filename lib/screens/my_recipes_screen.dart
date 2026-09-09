import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/user_recipe_service.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading.dart';
import '../widgets/recipe_card.dart';
import 'edit_recipe_screen.dart';
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
      return Scaffold(
        appBar: AppBar(title: const Text('My Recipes')),
        body: const AppErrorState(
          title: 'Not Logged In',
          subtitle: 'Please log in to view your recipes.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Recipes')),
      backgroundColor: const Color(0xFFF6F7F9),
      body: StreamBuilder<List<Recipe>>(
        stream: recipeService.getMyRecipes(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(message: 'Loading your recipes...');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Unable to Load Recipes',
              subtitle: 'Please check your connection and try again.',
              onRetry: () => setState(() {}),
            );
          }

          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return const AppEmptyState(
              icon: Icons.restaurant_menu,
              title: 'No Recipes Yet',
              subtitle: 'Create your first recipe and share it with others.',
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
                          mainAxisExtent: 330,
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
    final confirmed = await AppConfirmDialog.showDelete(
      context,
      title: 'Delete Recipe?',
      subtitle: 'This action cannot be undone.',
      itemName: recipe.title,
    );
    if (!confirmed) return;
    if (!mounted) return;
    setState(() => deletingRecipeIds.add(recipe.id));
    try {
      await recipeService.deleteRecipe(recipe);
      if (!mounted) return;
      // Safe to use context here because we checked mounted
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      // Safe to use context here because we checked mounted
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete recipe: $error')),
      );
    } finally {
      if (mounted) setState(() => deletingRecipeIds.remove(recipe.id));
    }
  }
}
