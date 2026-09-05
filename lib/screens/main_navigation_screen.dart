import 'package:flutter/material.dart';

import '../models/recipe.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';
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
  final Set<String> favoriteRecipes = {};
  final Set<String> savedRecipes = {};

  final List<Recipe> recipes = [
    const Recipe(
      title: 'Creamy Pasta', category: 'Dinner', time: '20 min', rating: '4.8',
      icon: Icons.ramen_dining,
      description: 'A delicious creamy pasta recipe that is quick and easy to prepare at home.',
      ingredients: ['Pasta', 'Fresh cream', 'Garlic', 'Cheese', 'Salt and pepper'],
      instructions: ['Boil the pasta until soft.', 'Heat a pan and add garlic.', 'Add cream and mix well.', 'Add cheese and spices.', 'Mix the pasta with the sauce and serve hot.'],
    ),
    const Recipe(
      title: 'Chicken Burger', category: 'Lunch', time: '25 min', rating: '4.7',
      icon: Icons.lunch_dining,
      description: 'A juicy homemade chicken burger with fresh vegetables and delicious sauce.',
      ingredients: ['Chicken patty', 'Burger bun', 'Lettuce', 'Tomato', 'Mayonnaise'],
      instructions: ['Prepare the chicken patty.', 'Cook the patty properly.', 'Toast the burger bun.', 'Add lettuce and tomato.', 'Add the patty and sauce, then serve.'],
    ),
    const Recipe(
      title: 'Fresh Salad', category: 'Breakfast', time: '10 min', rating: '4.9',
      icon: Icons.eco,
      description: 'A healthy and refreshing salad made with fresh vegetables.',
      ingredients: ['Lettuce', 'Tomato', 'Cucumber', 'Olive oil', 'Salt and pepper'],
      instructions: ['Wash all vegetables.', 'Cut the vegetables into pieces.', 'Put everything in a bowl.', 'Add olive oil and seasoning.', 'Mix well and serve fresh.'],
    ),
    const Recipe(
      title: 'Chocolate Cake', category: 'Dessert', time: '40 min', rating: '4.8',
      icon: Icons.cake,
      description: 'A soft and delicious chocolate cake perfect for dessert lovers.',
      ingredients: ['Flour', 'Chocolate powder', 'Sugar', 'Eggs', 'Butter'],
      instructions: ['Prepare the cake mixture.', 'Add flour and chocolate powder.', 'Mix all ingredients properly.', 'Pour into a baking pan.', 'Bake until fully cooked.'],
    ),
    const Recipe(
      title: 'Healthy Breakfast', category: 'Breakfast', time: '15 min', rating: '4.6',
      icon: Icons.breakfast_dining,
      description: 'A simple and healthy breakfast to start your day with energy.',
      ingredients: ['Eggs', 'Bread', 'Avocado', 'Vegetables', 'Salt'],
      instructions: ['Prepare the ingredients.', 'Cook the eggs.', 'Toast the bread.', 'Add vegetables.', 'Serve the breakfast warm.'],
    ),
    const Recipe(
      title: 'Grilled Chicken', category: 'Dinner', time: '30 min', rating: '4.9',
      icon: Icons.outdoor_grill,
      description: 'Flavorful grilled chicken with spices and fresh herbs.',
      ingredients: ['Chicken', 'Cooking oil', 'Garlic', 'Spices', 'Fresh herbs'],
      instructions: ['Clean the chicken.', 'Add spices and herbs.', 'Marinate for a few minutes.', 'Grill until fully cooked.', 'Serve hot.'],
    ),
  ];

  void toggleFavorite(String title) {
    setState(() {
      if (favoriteRecipes.contains(title)) {
        favoriteRecipes.remove(title);
      } else {
        favoriteRecipes.add(title);
      }
    });
  }

  void toggleSaved(String title) {
    setState(() {
      if (savedRecipes.contains(title)) {
        savedRecipes.remove(title);
      } else {
        savedRecipes.add(title);
      }
    });
  }

  void openRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(
          recipe: recipe,
          isFavorite: favoriteRecipes.contains(recipe.title),
          isSaved: savedRecipes.contains(recipe.title),
          onFavoriteTap: () => toggleFavorite(recipe.title),
          onSavedTap: () => toggleSaved(recipe.title),
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        recipes: recipes,
        favoriteRecipes: favoriteRecipes,
        savedRecipes: savedRecipes,
        onFavoriteTap: toggleFavorite,
        onSavedTap: toggleSaved,
        onRecipeTap: openRecipe,
      ),
      FavoriteScreen(
        recipes: recipes.where((recipe) => favoriteRecipes.contains(recipe.title)).toList(),
        favoriteRecipes: favoriteRecipes,
        onFavoriteTap: toggleFavorite,
        onRecipeTap: openRecipe,
      ),
      SavedScreen(
        recipes: recipes.where((recipe) => savedRecipes.contains(recipe.title)).toList(),
        savedRecipes: savedRecipes,
        onSavedTap: toggleSaved,
        onRecipeTap: openRecipe,
      ),
      ProfileScreen(
        favoriteCount: favoriteRecipes.length,
        savedCount: savedRecipes.length,
      ),
    ];

    return Scaffold(
      body: pages[selectedNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedNavIndex,
        selectedItemColor: const Color(0xFF4FA58C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            selectedNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), activeIcon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}