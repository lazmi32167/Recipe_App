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
  int servings = 2;

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
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3EE),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        recipe.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _DetailActionButton(
                        backgroundColor: Colors.white,
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          _DetailActionButton(
                            backgroundColor: Colors.white,
                            icon: isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            iconColor: isFavorite ? Colors.red : Colors.black87,
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                              widget.onFavoriteTap();
                            },
                          ),
                          const SizedBox(width: 10),
                          _DetailActionButton(
                            backgroundColor: Colors.white,
                            icon: isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            iconColor: isSaved
                                ? const Color(0xFF4FA58C)
                                : Colors.black87,
                            onPressed: () {
                              setState(() {
                                isSaved = !isSaved;
                              });
                              widget.onSavedTap();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9DDE2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _RecipeMeta(
                          icon: Icons.star,
                          iconColor: const Color(0xFFF2C94C),
                          label: recipe.rating,
                        ),
                        const SizedBox(width: 18),
                        _RecipeMeta(
                          icon: Icons.access_time,
                          iconColor: const Color(0xFF4FA58C),
                          label: recipe.time,
                        ),
                        const SizedBox(width: 18),
                        const _RecipeMeta(
                          icon: Icons.local_fire_department,
                          iconColor: Colors.deepOrangeAccent,
                          label: 'Calories unavailable',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      recipe.description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'How many servings?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        _ServingsSelector(
                          servings: servings,
                          onDecrease: () {
                            if (servings > 1) {
                              setState(() {
                                servings--;
                              });
                            }
                          },
                          onIncrease: () {
                            setState(() {
                              servings++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(
                      recipe.ingredients.length,
                      (index) => _IngredientRow(
                        ingredient: recipe.ingredients[index],
                        icon: _ingredientIcons[index % _ingredientIcons.length],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(
                      recipe.instructions.length,
                      (index) => _InstructionRow(
                        number: index + 1,
                        instruction: recipe.instructions[index],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cooking mode started!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Start Cooking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FA58C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<IconData> _ingredientIcons = [
  Icons.restaurant,
  Icons.eco,
  Icons.local_dining,
  Icons.circle,
];

class _DetailActionButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const _DetailActionButton({
    required this.backgroundColor,
    required this.icon,
    this.iconColor = Colors.black87,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          height: 46,
          width: 46,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _RecipeMeta extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _RecipeMeta({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServingsSelector extends StatelessWidget {
  final int servings;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ServingsSelector({
    required this.servings,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE1E5)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SelectorButton(icon: Icons.remove, onPressed: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(
              '$servings',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _SelectorButton(icon: Icons.add, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _SelectorButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SelectorButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox(
        height: 32,
        width: 28,
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String ingredient;
  final IconData icon;

  const _IngredientRow({required this.ingredient, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4FA58C), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(
            '1 serving',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final int number;
  final String instruction;

  const _InstructionRow({required this.number, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3EE),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Color(0xFF4FA58C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                instruction,
                style: const TextStyle(fontSize: 14, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}