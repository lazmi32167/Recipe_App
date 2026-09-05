import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final Set<String> favoriteRecipes;
  final Set<String> savedRecipes;
  final Function(String) onFavoriteTap;
  final Function(String) onSavedTap;
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
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategoryName = categories[selectedCategory];
    final filteredRecipes = widget.recipes.where((recipe) {
      final matchesCategory = selectedCategoryName == 'All' ||
          recipe.category == selectedCategoryName;
      final matchesSearch = recipe.title
          .toLowerCase()
          .contains(searchText.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE8F3EE),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF4FA58C),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello 👋',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'What are you cooking?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF4FA58C),
                    ),
                    suffixIcon: Icon(
                      Icons.tune,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA58C),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recipe of the Day',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Delicious food\nmade easy!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              widget.onRecipeTap(widget.recipes.first);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4FA58C),
                            ),
                            child: const Text('Explore'),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 25,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 45,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4FA58C)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
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
                    'Popular Recipes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredRecipes.length} recipes',
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
                      Icon(
                        Icons.search_off,
                        size: 70,
                        color: Colors.grey,
                      ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  itemCount: filteredRecipes.length,
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
                    final recipe = filteredRecipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      isFavorite:
                          widget.favoriteRecipes.contains(recipe.title),
                      isSaved: widget.savedRecipes.contains(recipe.title),
                      onFavoriteTap: () {
                        widget.onFavoriteTap(recipe.title);
                        setState(() {});
                      },
                      onSavedTap: () {
                        widget.onSavedTap(recipe.title);
                        setState(() {});
                      },
                      onTap: () {
                        widget.onRecipeTap(recipe);
                      },
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