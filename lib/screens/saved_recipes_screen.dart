import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/user_recipe_service.dart';
import 'user_recipe_collection_screen.dart';

class SavedRecipesScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onRecipeTap;
  final UserRecipeService service;

  SavedRecipesScreen({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
    UserRecipeService? service,
  }) : service = service ?? UserRecipeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(title: const Text('Saved Recipes')),
      body: UserRecipeCollectionScreen(
        collectionName: 'savedRecipes',
        title: 'Saved Recipes',
        emptyTitle: 'No saved recipes yet',
        emptySubtitle: 'Save recipes to find them easily later.',
        emptyIcon: Icons.bookmark_border,
        recipes: recipes,
        onRecipeTap: onRecipeTap,
        service: service,
      ),
    );
  }
}
