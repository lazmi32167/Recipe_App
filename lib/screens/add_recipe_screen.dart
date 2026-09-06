import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/recipe_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final descriptionController = TextEditingController();
  final ingredientsController = TextEditingController();
  final instructionsController = TextEditingController();
  final recipeService = RecipeService();
  String? category;
  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    ingredientsController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  Future<void> saveRecipe() async {
    final ingredients = _lines(ingredientsController.text);
    final instructions = _lines(instructionsController.text);
    if (titleController.text.trim().isEmpty ||
        category == null ||
        timeController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        ingredients.isEmpty ||
        instructions.isEmpty) {
      _showMessage('Please complete every recipe field.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('You must be signed in to add a recipe.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final profileName = profile.data()?['name'] as String?;
      await recipeService.addRecipe(
        title: titleController.text,
        category: category!,
        time: timeController.text,
        description: descriptionController.text,
        ingredients: ingredients,
        instructions: instructions,
        createdByName: profileName ?? user.displayName ?? 'Anonymous User',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added successfully.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) _showMessage('Could not add recipe: $error');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  List<String> _lines(String value) => value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field(titleController, 'Recipe Title'),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ['Breakfast', 'Lunch', 'Dinner', 'Dessert']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => category = value),
            ),
            const SizedBox(height: 14),
            _field(timeController, 'Cooking Time'),
            const SizedBox(height: 14),
            _field(descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 14),
            _field(
              ingredientsController,
              'Ingredients (one per line)',
              maxLines: 5,
            ),
            const SizedBox(height: 14),
            _field(
              instructionsController,
              'Instructions (one step per line)',
              maxLines: 7,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FA58C),
                  foregroundColor: Colors.white,
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
