import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'notifications_screen.dart';

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
  String selectedCategory = 'All';
  String searchText = '';
  String selectedSort = 'Newest';

  final TextEditingController searchController = TextEditingController();

  static const List<String> sortOptions = [
    'Newest',
    'Highest Rated',
    'A-Z',
  ];

  List<String> get categories {
    final values = <String>['All'];

    for (final recipe in widget.recipes) {
      final category = recipe.category.trim();

      if (category.isNotEmpty &&
          !values.any(
            (value) => value.toLowerCase() == category.toLowerCase(),
          )) {
        values.add(category);
      }
    }

    return values;
  }

  String get activeCategory {
    return categories.contains(selectedCategory) ? selectedCategory : 'All';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Recipe> get visibleRecipes {
    final query = searchText.trim().toLowerCase();

    final filteredRecipes = widget.recipes.where((recipe) {
      final recipeCategory = recipe.category.trim();

      final matchesCategory =
          activeCategory == 'All' ||
          recipeCategory.toLowerCase() == activeCategory.toLowerCase();

      final searchableIngredients = recipe.ingredients.join(' ');

      final matchesSearch =
          query.isEmpty ||
          recipe.title.toLowerCase().contains(query) ||
          recipeCategory.toLowerCase().contains(query) ||
          searchableIngredients.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    filteredRecipes.sort(_compareRecipes);

    return filteredRecipes;
  }

  int _compareRecipes(Recipe first, Recipe second) {
    switch (selectedSort) {
      case 'Highest Rated':
        final ratingComparison =
            _ratingValue(second.rating).compareTo(_ratingValue(first.rating));

        if (ratingComparison != 0) {
          return ratingComparison;
        }

        return _compareTitles(first, second);

      case 'A-Z':
        return _compareTitles(first, second);

      case 'Newest':
      default:
        final firstDate = first.createdAt;
        final secondDate = second.createdAt;

        if (firstDate == null && secondDate == null) {
          return _compareTitles(first, second);
        }

        if (firstDate == null) {
          return 1;
        }

        if (secondDate == null) {
          return -1;
        }

        final dateComparison = secondDate.compareTo(firstDate);

        return dateComparison == 0
            ? _compareTitles(first, second)
            : dateComparison;
    }
  }

  int _compareTitles(Recipe first, Recipe second) {
    return first.title
        .trim()
        .toLowerCase()
        .compareTo(second.title.trim().toLowerCase());
  }

  double _ratingValue(String rating) {
    return double.tryParse(rating.trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = visibleRecipes;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================

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
                      color:
                          Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      tooltip: 'Notifications',
                      icon:
                          const Icon(Icons.notifications_none, size: 25),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ================= SEARCH =================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,

                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText: 'Search any recipes',

                    prefixIcon: Icon(
                      Icons.search,
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),

                    suffixIcon: searchText.trim().isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                searchText = '';
                              });
                            },
                          ),

                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ================= BANNER =================

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

                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          'assets/images/creamy_pasta.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF185F50)
                              .withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 18, 110, 0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                            : () {
                                widget.onRecipeTap(
                                  widget.recipes.first,
                                );
                              },

                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(92, 36),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        child: const Text(
                          'Explore',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
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
                          color:
                              Colors.white.withValues(alpha: 0.15),
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

            const Center(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,

                itemBuilder: (context, index) {
                  final isSelected =
                      activeCategory == categories[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },

                    child: Container(
                      margin: const EdgeInsets.only(right: 12),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),

                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4FA58C)
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,

                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      alignment: Alignment.center,

                      child: Text(
                        categories[index],

                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // ================= RECIPES HEADER =================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    'Recipes',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSort,

                      icon: const Icon(
                        Icons.unfold_more,
                        size: 18,
                      ),

                      style: const TextStyle(
                        color: Color(0xFF4FA58C),
                        fontWeight: FontWeight.w600,
                      ),

                      items: sortOptions
                          .map(
                            (sort) => DropdownMenuItem<String>(
                              value: sort,
                              child: Text(sort),
                            ),
                          )
                          .toList(),

                      onChanged: (sort) {
                        if (sort == null) return;

                        setState(() {
                          selectedSort = sort;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ================= RECIPES LIST =================

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

                      SizedBox(height: 6),

                      Text(
                        'Try another search or category.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )

            else
              SizedBox(
                height: 330,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),

                  itemCount: filteredRecipes.length,

                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];

                    return Padding(
                      padding:
                          const EdgeInsets.only(right: 14),

                      child: SizedBox(
                        width: 180,

                        child: RecipeCard(
                          recipe: recipe,

                          isFavorite:
                              widget.favoriteRecipes.any(
                            recipe.matchesIdentifier,
                          ),

                          isSaved:
                              widget.savedRecipes.any(
                            recipe.matchesIdentifier,
                          ),

                          onFavoriteTap:
                              (shouldBeFavorite) {
                            widget.onFavoriteTap(
                              recipe,
                              shouldBeFavorite,
                            );
                          },

                          onSavedTap:
                              (shouldBeSaved) {
                            widget.onSavedTap(
                              recipe,
                              shouldBeSaved,
                            );
                          },

                          onTap: () {
                            widget.onRecipeTap(recipe);
                          },
                        ),
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