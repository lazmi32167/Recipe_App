import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/user_recipe_service.dart';
import 'user_recipe_collection_screen.dart';

class MyFavoritesScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onRecipeTap;
  final UserRecipeService service;

  MyFavoritesScreen({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
    UserRecipeService? service,
  }) : service = service ?? UserRecipeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(title: const Text('My Favorites')),
      body: UserRecipeCollectionScreen(
        collectionName: 'favorites',
        title: 'My Favorites',
        emptyTitle: 'No favorite recipes yet',
        emptySubtitle: 'Your favorite recipes will appear here.',
        emptyIcon: Icons.favorite_border,
        recipes: recipes,
        onRecipeTap: onRecipeTap,
        service: service,
      ),
    );
  }
}
