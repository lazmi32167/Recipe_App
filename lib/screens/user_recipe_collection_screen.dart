import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/user_recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'favorite_screen.dart';

class UserRecipeCollectionScreen extends StatelessWidget {
  final String collectionName;
  final String title;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onRecipeTap;
  final UserRecipeService service;

  const UserRecipeCollectionScreen({
    super.key,
    required this.collectionName,
    required this.title,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.recipes,
    required this.onRecipeTap,
    required this.service,
  });

  bool get isFavorites => collectionName == 'favorites';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.recipesStream(collectionName),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load $title.'));
          }

          final storedRecipes =
              snapshot.data?.docs
                .map((doc) {
                final storedId = doc.data()['recipeId'] ?? doc.id;
                return recipes
                  .where((recipe) => recipe.matchesIdentifier(storedId))
                  .firstOrNull;
                })
                  .whereType<Recipe>()
                  .toList() ??
              <Recipe>[];

          if (storedRecipes.isEmpty) {
            return EmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              subtitle: emptySubtitle,
            );
          }

          final otherCollection = isFavorites ? 'savedRecipes' : 'favorites';
          return StreamBuilder<Set<String>>(
            stream: service.recipeIdsStream(otherCollection),
            builder: (context, otherSnapshot) {
              final otherRecipeIds = otherSnapshot.data ?? <String>{};

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${storedRecipes.length} recipes',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 25),
                    GridView.builder(
                      itemCount: storedRecipes.length,
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
                        final recipe = storedRecipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          isFavorite: isFavorites ||
                            otherRecipeIds.any(recipe.matchesIdentifier),
                          isSaved: !isFavorites ||
                            otherRecipeIds.any(recipe.matchesIdentifier),
                          onFavoriteTap: (shouldBeFavorite) async {
                            try {
                              await service.toggleFavorite(
                                recipe,
                                shouldBeFavorite,
                              );
                            } catch (error) {
                              if (!context.mounted) {
                                return;
                              }
                              _showError(context, error);
                            }
                          },
                          onSavedTap: (shouldBeSaved) async {
                            try {
                              await service.toggleSaved(recipe, shouldBeSaved);
                            } catch (error) {
                              if (!context.mounted) {
                                return;
                              }
                              _showError(context, error);
                            }
                          },
                          onTap: () => onRecipeTap(recipe),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not update recipe: $error')));
  }
}
