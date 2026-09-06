import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final Set<String> favoriteRecipes;
  final Set<String> savedRecipes;
  final Function(Recipe, bool) onFavoriteTap;
  final Function(Recipe, bool) onSavedTap;
  final Function(Recipe) onRecipeTap;

  const HomeScreen({
    super.key,
    required this.recipes,
    required this.favoriteRecipes,
    required this.savedRecipes,
    required this.onFavoriteTap,
    required this.onSavedTap,
    required this.onRecipeTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;
  String searchText = '';

  final List<String> categories = [
    'All',
    'Dinner',
    'Lunch',
    'Breakfast',
    'Dessert',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategoryName = categories[selectedCategory];
    final filteredRecipes = widget.recipes.where((recipe) {
      final matchesCategory =
          selectedCategoryName == 'All' ||
          recipe.category == selectedCategoryName;
      final matchesSearch = recipe.title.toLowerCase().contains(
        searchText.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'What are you\ncooking today?',
                    style: TextStyle(
                      fontSize: 29,
                      height: 1.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_none, size: 25),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search any recipes',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA58C),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 18, 110, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cook the best\nrecipes at home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: ElevatedButton(
                        onPressed: widget.recipes.isEmpty
                            ? null
                            : () => widget.onRecipeTap(widget.recipes.first),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(92, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Explore',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: Container(
                        height: 95,
                        width: 95,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedCategory == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4FA58C)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick & Easy',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'View all',
                    style: const TextStyle(
                      color: Color(0xFF4FA58C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            if (filteredRecipes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 70, color: Colors.grey),
                      SizedBox(height: 15),
                      Text(
                        'No recipes found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 245,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: RecipeCard(
                        recipe: recipe,
                        isFavorite: widget.favoriteRecipes.any(
                          recipe.matchesIdentifier,
                        ),
                        isSaved: widget.savedRecipes.any(
                          recipe.matchesIdentifier,
                        ),
                        onFavoriteTap: (shouldBeFavorite) {
                          widget.onFavoriteTap(recipe, shouldBeFavorite);
                        },
                        onSavedTap: (shouldBeSaved) {
                          widget.onSavedTap(recipe, shouldBeSaved);
                        },
                        onTap: () {
                          widget.onRecipeTap(recipe);
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
