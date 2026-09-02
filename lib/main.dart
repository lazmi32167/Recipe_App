import 'package:flutter/material.dart';

void main() {
  runApp(const RecipeApp());
}

// ================= APP =================

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const MainScreen(),
    );
  }
}

// ================= MAIN SCREEN =================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    SearchScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),

          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ================= HOME SCREEN =================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            const _HomeHeader(),

            const SizedBox(height: 24),

            const _RecipeSearchField(),

            const SizedBox(height: 24),

            const _FeaturedBanner(),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 110,

              child: ListView(
                scrollDirection: Axis.horizontal,

                children: const [
                  CategoryItem(
                    icon: Icons.restaurant,
                    title: 'Breakfast',
                  ),

                  CategoryItem(
                    icon: Icons.lunch_dining,
                    title: 'Lunch',
                  ),

                  CategoryItem(
                    icon: Icons.dinner_dining,
                    title: 'Dinner',
                  ),

                  CategoryItem(
                    icon: Icons.cake,
                    title: 'Dessert',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Quick & Easy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.68,

              children: [
                RecipeCard(
                  title: 'Creamy Pasta',
                  time: '20 min',
                  icon: Icons.ramen_dining,
                  ingredients: const [
                    'Pasta',
                    'Cream',
                    'Cheese',
                    'Garlic',
                    'Salt',
                  ],
                  instructions: const [
                    'Boil the pasta in hot water.',
                    'Prepare creamy sauce.',
                    'Add cheese and garlic.',
                    'Mix pasta with sauce.',
                    'Serve hot.',
                  ],
                ),

                RecipeCard(
                  title: 'Chicken Burger',
                  time: '25 min',
                  icon: Icons.lunch_dining,
                  ingredients: const [
                    'Burger Bun',
                    'Chicken Patty',
                    'Cheese',
                    'Lettuce',
                    'Sauce',
                  ],
                  instructions: const [
                    'Cook the chicken patty.',
                    'Toast the burger bun.',
                    'Add lettuce and cheese.',
                    'Place chicken patty inside.',
                    'Add sauce and serve.',
                  ],
                ),

                RecipeCard(
                  title: 'Fresh Salad',
                  time: '10 min',
                  icon: Icons.eco,
                  ingredients: const [
                    'Lettuce',
                    'Tomato',
                    'Cucumber',
                    'Olive Oil',
                  ],
                  instructions: const [
                    'Wash all vegetables.',
                    'Cut vegetables into pieces.',
                    'Mix everything together.',
                    'Add olive oil.',
                    'Serve fresh.',
                  ],
                ),

                RecipeCard(
                  title: 'Chocolate Cake',
                  time: '40 min',
                  icon: Icons.cake,
                  ingredients: const [
                    'Flour',
                    'Chocolate',
                    'Egg',
                    'Sugar',
                    'Butter',
                  ],
                  instructions: const [
                    'Prepare the cake mixture.',
                    'Preheat the oven.',
                    'Pour mixture into baking pan.',
                    'Bake for 30 minutes.',
                    'Cool and serve.',
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ================= HEADER =================

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        const Text(
          'What are you\ncooking today?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            height: 1.05,
          ),
        ),

        Container(
          height: 48,
          width: 48,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),

          child: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

// ================= SEARCH FIELD =================

class _RecipeSearchField extends StatelessWidget {
  const _RecipeSearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search any recipes',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ================= FEATURED BANNER =================

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF4FA58C),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          const Text(
            'Cook the best\nrecipes at home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {},

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),

            child: const Text('Explore'),
          ),
        ],
      ),
    );
  }
}

// ================= CATEGORY ITEM =================

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 15),

      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,

            decoration: BoxDecoration(
              color: const Color(0xFFE8F3EE),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF4FA58C),
              size: 30,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= RECIPE CARD =================

class RecipeCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final List<String> ingredients;
  final List<String> instructions;

  const RecipeCard({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.ingredients,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              title: title,
              time: time,
              icon: icon,
              ingredients: ingredients,
              instructions: instructions,
            ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              flex: 5,

              child: Container(
                width: double.infinity,

                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3EE),

                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),

                child: Center(
                  child: Icon(
                    icon,
                    size: 60,
                    color: const Color(0xFF4FA58C),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 3,

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.grey,
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

// ================= RECIPE DETAIL SCREEN =================

class RecipeDetailScreen extends StatefulWidget {
  final String title;
  final String time;
  final IconData icon;
  final List<String> ingredients;
  final List<String> instructions;

  const RecipeDetailScreen({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.ingredients,
    required this.instructions,
  });

  @override
  State<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

        actions: [
          IconButton(
            icon: Icon(
              isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),

            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // IMAGE PLACEHOLDER

            Container(
              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F3EE),
                borderRadius: BorderRadius.circular(25),
              ),

              child: Center(
                child: Icon(
                  widget.icon,
                  size: 100,
                  color: const Color(0xFF4FA58C),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),

                const SizedBox(width: 8),

                Text(
                  widget.time,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 25),

                const Icon(
                  Icons.bar_chart,
                  color: Colors.grey,
                ),

                const SizedBox(width: 8),

                const Text(
                  'Easy',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...widget.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),

                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4FA58C),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      ingredient,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...List.generate(
              widget.instructions.length,

              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFF4FA58C),

                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        widget.instructions[index],
                        style: const TextStyle(
                          fontSize: 16,
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
    );
  }
}

// ================= SEARCH SCREEN =================

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Search Recipes',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ================= FAVORITE SCREEN =================

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Your Favorite Recipes',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ================= PROFILE SCREEN =================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'My Profile',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}