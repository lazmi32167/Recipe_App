import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/user_recipe_service.dart';
import 'add_recipe_screen.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';
import 'my_recipes_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_page.dart';
import 'saved_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedNavIndex = 0;
  final UserRecipeService recipeService = UserRecipeService();
  final RecipeService catalogService = RecipeService();

  final List<Recipe> recipes = [
    const Recipe(
      id: 'legacy_creamy_pasta',
      title: 'Creamy Pasta',
      category: 'Dinner',
      time: '20 min',
      rating: '4.8',
      imagePath: 'assets/images/creamy_pasta.jpg',
      icon: Icons.ramen_dining,
      description:
          'A delicious creamy pasta recipe that is quick and easy to prepare at home.',
      ingredients: [
        'Pasta',
        'Fresh cream',
        'Garlic',
        'Cheese',
        'Salt and pepper',
      ],
      instructions: [
        'Boil the pasta until soft.',
        'Heat a pan and add garlic.',
        'Add cream and mix well.',
        'Add cheese and spices.',
        'Mix the pasta with the sauce and serve hot.',
      ],
    ),
    const Recipe(
      id: 'legacy_chicken_burger',
      title: 'Chicken Burger',
      category: 'Lunch',
      time: '25 min',
      rating: '4.7',
      imagePath: 'assets/images/chicken_burger.jpg',
      icon: Icons.lunch_dining,
      description:
          'A juicy homemade chicken burger with fresh vegetables and delicious sauce.',
      ingredients: [
        'Chicken patty',
        'Burger bun',
        'Lettuce',
        'Tomato',
        'Mayonnaise',
      ],
      instructions: [
        'Prepare the chicken patty.',
        'Cook the patty properly.',
        'Toast the burger bun.',
        'Add lettuce and tomato.',
        'Add the patty and sauce, then serve.',
      ],
    ),
    const Recipe(
      id: 'legacy_fresh_salad',
      title: 'Fresh Salad',
      category: 'Breakfast',
      time: '10 min',
      rating: '4.9',
      imagePath: 'assets/images/fresh_salad.jpg',
      icon: Icons.eco,
      description: 'A healthy and refreshing salad made with fresh vegetables.',
      ingredients: [
        'Lettuce',
        'Tomato',
        'Cucumber',
        'Olive oil',
        'Salt and pepper',
      ],
      instructions: [
        'Wash all vegetables.',
        'Cut the vegetables into pieces.',
        'Put everything in a bowl.',
        'Add olive oil and seasoning.',
        'Mix well and serve fresh.',
      ],
    ),
    const Recipe(
      id: 'legacy_chocolate_cake',
      title: 'Chocolate Cake',
      category: 'Dessert',
      time: '40 min',
      rating: '4.8',
      imagePath: 'assets/images/chocolate_cake.jpg',
      icon: Icons.cake,
      description:
          'A soft and delicious chocolate cake perfect for dessert lovers.',
      ingredients: ['Flour', 'Chocolate powder', 'Sugar', 'Eggs', 'Butter'],
      instructions: [
        'Prepare the cake mixture.',
        'Add flour and chocolate powder.',
        'Mix all ingredients properly.',
        'Pour into a baking pan.',
        'Bake until fully cooked.',
      ],
    ),
    const Recipe(
      id: 'legacy_healthy_breakfast',
      title: 'Healthy Breakfast',
      category: 'Breakfast',
      time: '15 min',
      rating: '4.6',
      imagePath: 'assets/images/healthy_breakfast.jpg',
      icon: Icons.breakfast_dining,
      description:
          'A simple and healthy breakfast to start your day with energy.',
      ingredients: ['Eggs', 'Bread', 'Avocado', 'Vegetables', 'Salt'],
      instructions: [
        'Prepare the ingredients.',
        'Cook the eggs.',
        'Toast the bread.',
        'Add vegetables.',
        'Serve the breakfast warm.',
      ],
    ),
    const Recipe(
      id: 'legacy_grilled_chicken',
      title: 'Grilled Chicken',
      category: 'Dinner',
      time: '30 min',
      rating: '4.9',
      imagePath: 'assets/images/grilled_chicken.jpg',
      icon: Icons.outdoor_grill,
      description: 'Flavorful grilled chicken with spices and fresh herbs.',
      ingredients: [
        'Chicken',
        'Cooking oil',
        'Garlic',
        'Spices',
        'Fresh herbs',
      ],
      instructions: [
        'Clean the chicken.',
        'Add spices and herbs.',
        'Marinate for a few minutes.',
        'Grill until fully cooked.',
        'Serve hot.',
      ],
    ),
    const Recipe(
      id: 'legacy_french_fries',
      title: 'Crispy French Fries',
      category: 'Snacks',
      time: '15 min',
      rating: '4.7',
      imagePath: 'assets/images/french_fries.jpg',
      icon: Icons.fastfood,
      description: 'Golden, crispy fries seasoned with paprika and sea salt.',
      ingredients: ['Potatoes', 'Olive oil', 'Paprika', 'Salt', 'Black pepper'],
      instructions: [
        'Slice the potatoes into fries.',
        'Soak them briefly in cold water.',
        'Dry well and toss with oil and seasoning.',
        'Bake or fry until golden and crisp.',
        'Serve hot with your favorite dip.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    catalogService.ensureSeededRecipes(recipes);
  }

  Future<void> toggleFavorite(Recipe recipe, bool shouldBeFavorite) async {
    try {
      await recipeService.toggleFavorite(recipe, shouldBeFavorite);
    } catch (error) {
      _showError('Could not update favorite: $error');
    }
  }

  Future<void> toggleSaved(Recipe recipe, bool shouldBeSaved) async {
    try {
      await recipeService.toggleSaved(recipe, shouldBeSaved);
    } catch (error) {
      _showError('Could not update saved recipe: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void openRecipe(
    Recipe recipe,
    Set<String> favoriteRecipes,
    Set<String> savedRecipes,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(
          recipe: recipe,
          isFavorite: favoriteRecipes.any(recipe.matchesIdentifier),
          isSaved: savedRecipes.any(recipe.matchesIdentifier),
          onFavoriteTap: (shouldBeFavorite) =>
              toggleFavorite(recipe, shouldBeFavorite),
          onSavedTap: (shouldBeSaved) => toggleSaved(recipe, shouldBeSaved),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Recipe>>(
      stream: catalogService.getRecipes(),
      builder: (context, catalogSnapshot) {
        // Keep the built-in recipes as a permanent fallback. Firestore data is
        // additive; a loading/error/empty snapshot must never blank the Home feed.
        final firestoreRecipes = catalogSnapshot.hasData
            ? (catalogSnapshot.data ?? <Recipe>[])
            : <Recipe>[];
        final deduped = <String, Recipe>{};

        for (final recipe in recipes) {
          deduped[recipe.id] = recipe;
        }
        for (final recipe in firestoreRecipes) {
          deduped[recipe.id] = recipe;
        }

        final allRecipes = deduped.values.toList(growable: false);

        return StreamBuilder<Set<String>>(
          stream: recipeService.recipeIdsStream('favorites'),
          builder: (context, favoriteSnapshot) {
            final favoriteRecipes = favoriteSnapshot.data ?? <String>{};

            return StreamBuilder<Set<String>>(
              stream: recipeService.recipeIdsStream('savedRecipes'),
              builder: (context, savedSnapshot) {
                final savedRecipes = savedSnapshot.data ?? <String>{};
                final pages = [
                  HomeScreen(
                    recipes: allRecipes,
                    favoriteRecipes: favoriteRecipes,
                    savedRecipes: savedRecipes,
                    onFavoriteTap: toggleFavorite,
                    onSavedTap: toggleSaved,
                    onRecipeTap: (recipe) =>
                        openRecipe(recipe, favoriteRecipes, savedRecipes),
                  ),
                  FavoriteScreen(
                    recipes: allRecipes
                        .where(
                          (recipe) =>
                              favoriteRecipes.any(recipe.matchesIdentifier),
                        )
                        .toList(),
                    favoriteRecipes: favoriteRecipes,
                    savedRecipes: savedRecipes,
                    onFavoriteTap: toggleFavorite,
                    onSavedTap: toggleSaved,
                    onRecipeTap: (recipe) =>
                        openRecipe(recipe, favoriteRecipes, savedRecipes),
                  ),
                  SavedScreen(
                    recipes: allRecipes
                        .where(
                          (recipe) =>
                              savedRecipes.any(recipe.matchesIdentifier),
                        )
                        .toList(),
                    favoriteRecipes: favoriteRecipes,
                    savedRecipes: savedRecipes,
                    onFavoriteTap: toggleFavorite,
                    onSavedTap: toggleSaved,
                    onRecipeTap: (recipe) =>
                        openRecipe(recipe, favoriteRecipes, savedRecipes),
                  ),
                  ProfileScreen(
                    recipes: allRecipes,
                    onRecipeTap: (recipe) =>
                        openRecipe(recipe, favoriteRecipes, savedRecipes),
                    onAddRecipe: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddRecipeScreen(),
                        ),
                      );
                    },
                    onMyRecipes: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MyRecipesScreen()),
                      );
                    },
                  ),
                ];

                return Scaffold(
                  body: pages[selectedNavIndex],
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: selectedNavIndex,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    onTap: (index) {
                      setState(() {
                        selectedNavIndex = index;
                      });
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite_border),
                        activeIcon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.bookmark_border),
                        activeIcon: Icon(Icons.bookmark),
                        label: 'Saved',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
