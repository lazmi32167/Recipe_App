import 'package:flutter/material.dart';

void main() {
  runApp(const RecipeApp());
}

// =====================================================
// APP
// =====================================================

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FA58C),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// =====================================================
// RECIPE MODEL
// =====================================================

class Recipe {
  final String title;
  final String category;
  final String time;
  final String rating;
  final IconData icon;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;

  const Recipe({
    required this.title,
    required this.category,
    required this.time,
    required this.rating,
    required this.icon,
    required this.description,
    required this.ingredients,
    required this.instructions,
  });
}

// =====================================================
// MAIN NAVIGATION SCREEN
// =====================================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int selectedNavIndex = 0;

  final Set<String> favoriteRecipes = {};
  final Set<String> savedRecipes = {};

  final List<Recipe> recipes = [
    const Recipe(
      title: 'Creamy Pasta',
      category: 'Dinner',
      time: '20 min',
      rating: '4.8',
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
      title: 'Chicken Burger',
      category: 'Lunch',
      time: '25 min',
      rating: '4.7',
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
      title: 'Fresh Salad',
      category: 'Breakfast',
      time: '10 min',
      rating: '4.9',
      icon: Icons.eco,
      description:
          'A healthy and refreshing salad made with fresh vegetables.',
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
      title: 'Chocolate Cake',
      category: 'Dessert',
      time: '40 min',
      rating: '4.8',
      icon: Icons.cake,
      description:
          'A soft and delicious chocolate cake perfect for dessert lovers.',
      ingredients: [
        'Flour',
        'Chocolate powder',
        'Sugar',
        'Eggs',
        'Butter',
      ],
      instructions: [
        'Prepare the cake mixture.',
        'Add flour and chocolate powder.',
        'Mix all ingredients properly.',
        'Pour into a baking pan.',
        'Bake until fully cooked.',
      ],
    ),
    const Recipe(
      title: 'Healthy Breakfast',
      category: 'Breakfast',
      time: '15 min',
      rating: '4.6',
      icon: Icons.breakfast_dining,
      description:
          'A simple and healthy breakfast to start your day with energy.',
      ingredients: [
        'Eggs',
        'Bread',
        'Avocado',
        'Vegetables',
        'Salt',
      ],
      instructions: [
        'Prepare the ingredients.',
        'Cook the eggs.',
        'Toast the bread.',
        'Add vegetables.',
        'Serve the breakfast warm.',
      ],
    ),
    const Recipe(
      title: 'Grilled Chicken',
      category: 'Dinner',
      time: '30 min',
      rating: '4.9',
      icon: Icons.outdoor_grill,
      description:
          'Flavorful grilled chicken with spices and fresh herbs.',
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
          onFavoriteTap: () {
            toggleFavorite(recipe.title);
          },
          onSavedTap: () {
            toggleSaved(recipe.title);
          },
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
        recipes: recipes
            .where(
              (recipe) =>
                  favoriteRecipes.contains(recipe.title),
            )
            .toList(),
        favoriteRecipes: favoriteRecipes,
        onFavoriteTap: toggleFavorite,
        onRecipeTap: openRecipe,
      ),

      SavedScreen(
        recipes: recipes
            .where(
              (recipe) =>
                  savedRecipes.contains(recipe.title),
            )
            .toList(),
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
  }
}

// =====================================================
// HOME SCREEN
// =====================================================

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
    final selectedCategoryName =
        categories[selectedCategory];

    final filteredRecipes = widget.recipes.where((recipe) {
      final matchesCategory =
          selectedCategoryName == 'All' ||
              recipe.category == selectedCategoryName;

      final matchesSearch =
          recipe.title
              .toLowerCase()
              .contains(searchText.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor:
                            Color(0xFFE8F3EE),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF4FA58C),
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                              fontWeight:
                                  FontWeight.bold,
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
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),

            // ================= SEARCH =================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
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

            // ================= FEATURED =================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA58C),
                  borderRadius:
                      BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          ElevatedButton(
                            onPressed: () {
                              widget.onRecipeTap(
                                widget.recipes.first,
                              );
                            },
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white,
                              foregroundColor:
                                  const Color(0xFF4FA58C),
                            ),
                            child:
                                const Text('Explore'),
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
                          color: Colors.white
                              .withOpacity(0.15),
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

            // ================= CATEGORIES =================

            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected =
                      selectedCategory == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = index;
                      });
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 12),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4FA58C)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // ================= POPULAR RECIPES =================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
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

            // ================= RECIPE GRID =================

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  itemCount: filteredRecipes.length,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final recipe =
                        filteredRecipes[index];

                    return RecipeCard(
                      recipe: recipe,
                      isFavorite: widget.favoriteRecipes
                          .contains(recipe.title),
                      isSaved: widget.savedRecipes
                          .contains(recipe.title),

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

// =====================================================
// RECIPE CARD
// =====================================================

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onSavedTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.isSaved,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onSavedTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3EE),
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Stack(
                  children: [

                    Center(
                      child: Icon(
                        recipe.icon,
                        size: 65,
                        color:
                            const Color(0xFF4FA58C),
                      ),
                    ),

                    // FAVORITE

                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : Colors.black87,
                            size: 19,
                          ),
                        ),
                      ),
                    ),

                    // SAVE

                    Positioned(
                      top: 50,
                      right: 8,
                      child: GestureDetector(
                        onTap: onSavedTap,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isSaved
                                ? const Color(0xFF4FA58C)
                                : Colors.black87,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      recipe.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 15,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          recipe.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 17,
                          color: Colors.orange,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          recipe.rating,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// RECIPE DETAIL PAGE
// =====================================================

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final bool isFavorite;
  final bool isSaved;
  final VoidCallback onFavoriteTap;
  final VoidCallback onSavedTap;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.isSaved,
    required this.onFavoriteTap,
    required this.onSavedTap,
  });

  @override
  State<RecipeDetailPage> createState() =>
      _RecipeDetailPageState();
}

class _RecipeDetailPageState
    extends State<RecipeDetailPage> {
  late bool isFavorite;
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ================= TOP AREA =================

              Container(
                height: 280,
                width: double.infinity,
                color: const Color(0xFFE8F3EE),
                child: Stack(
                  children: [

                    Center(
                      child: Icon(
                        recipe.icon,
                        size: 130,
                        color:
                            const Color(0xFF4FA58C),
                      ),
                    ),

                    Positioned(
                      top: 20,
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),

                    Positioned(
                      top: 20,
                      right: 70,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite =
                                  !isFavorite;
                            });
                            widget.onFavoriteTap();
                          },
                        ),
                      ),
                    ),

                    Positioned(
                      top: 20,
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isSaved
                                ? const Color(0xFF4FA58C)
                                : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              isSaved = !isSaved;
                            });
                            widget.onSavedTap();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      recipe.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFF3E0),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                recipe.rating,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE8F3EE),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color:
                                    Color(0xFF4FA58C),
                              ),
                              const SizedBox(width: 5),
                              Text(recipe.time),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...recipe.ingredients.map(
                      (ingredient) => Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color:
                                  Color(0xFF4FA58C),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...List.generate(
                      recipe.instructions.length,
                      (index) => Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 15,
                        ),
                        padding:
                            const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  const Color(0xFFE8F3EE),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color:
                                      Color(0xFF4FA58C),
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                recipe.instructions[index],
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// FAVORITE SCREEN
// =====================================================

class FavoriteScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> favoriteRecipes;
  final Function(String) onFavoriteTap;
  final Function(Recipe) onRecipeTap;

  const FavoriteScreen({
    super.key,
    required this.recipes,
    required this.favoriteRecipes,
    required this.onFavoriteTap,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: recipes.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No Favorite Recipes Yet',
              subtitle:
                  'Your favorite recipes will appear here.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    'My Favorites ❤️',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${recipes.length} favorite recipes',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  GridView.builder(
                    itemCount: recipes.length,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];

                      return RecipeCard(
                        recipe: recipe,
                        isFavorite: true,
                        isSaved: false,
                        onFavoriteTap: () {
                          onFavoriteTap(recipe.title);
                        },
                        onSavedTap: () {},
                        onTap: () {
                          onRecipeTap(recipe);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// =====================================================
// SAVED SCREEN
// =====================================================

class SavedScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> savedRecipes;
  final Function(String) onSavedTap;
  final Function(Recipe) onRecipeTap;

  const SavedScreen({
    super.key,
    required this.recipes,
    required this.savedRecipes,
    required this.onSavedTap,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: recipes.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No Saved Recipes',
              subtitle:
                  'Save recipes to find them easily later.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Saved Recipes 🔖',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${recipes.length} saved recipes',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  GridView.builder(
                    itemCount: recipes.length,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];

                      return RecipeCard(
                        recipe: recipe,
                        isFavorite: false,
                        isSaved: true,
                        onFavoriteTap: () {},
                        onSavedTap: () {
                          onSavedTap(recipe.title);
                        },
                        onTap: () {
                          onRecipeTap(recipe);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// =====================================================
// EMPTY STATE
// =====================================================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 80,
              color: const Color(0xFF4FA58C),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PROFILE SCREEN
// =====================================================

class ProfileScreen extends StatelessWidget {
  final int favoriteCount;
  final int savedCount;

  const ProfileScreen({
    super.key,
    required this.favoriteCount,
    required this.savedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 55,
              backgroundColor:
                  Color(0xFFE8F3EE),
              child: Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF4FA58C),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Recipe Lover',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'recipe@example.com',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 35),

            Row(
              children: [

                Expanded(
                  child: ProfileStat(
                    number: favoriteCount.toString(),
                    label: 'Favorites',
                    icon: Icons.favorite,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ProfileStat(
                    number: savedCount.toString(),
                    label: 'Saved',
                    icon: Icons.bookmark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            const ProfileOption(
              icon: Icons.favorite_border,
              title: 'My Favorites',
            ),

            const ProfileOption(
              icon: Icons.bookmark_border,
              title: 'Saved Recipes',
            ),

            const ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
            ),

            const ProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PROFILE STAT
// =====================================================

class ProfileStat extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const ProfileStat({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: const Color(0xFF4FA58C),
          ),

          const SizedBox(height: 8),

          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PROFILE OPTION
// =====================================================

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [

          Icon(
            icon,
            color: const Color(0xFF4FA58C),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}