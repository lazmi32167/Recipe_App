import 'package:flutter/material.dart';

import '../models/recipe.dart';

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
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        color: const Color(0xFF4FA58C),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
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
                            color: isFavorite ? Colors.red : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3EE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: Color(0xFF4FA58C),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...recipe.ingredients.map(
                      (ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4FA58C),
                              size: 20,
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
                    const SizedBox(height: 25),
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...List.generate(
                      recipe.instructions.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(bottom: 15),
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
                              backgroundColor: const Color(0xFFE8F3EE),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF4FA58C),
                                  fontWeight: FontWeight.bold,
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