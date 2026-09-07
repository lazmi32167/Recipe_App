import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_image.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late final TextEditingController titleController;
  late final TextEditingController timeController;
  late final TextEditingController descriptionController;
  late final TextEditingController ingredientsController;
  late final TextEditingController instructionsController;
  final recipeService = RecipeService();
  final imagePicker = ImagePicker();
  late String? category;
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  bool isSaving = false;

  List<String> get categories {
    final values = ['Breakfast', 'Lunch', 'Dinner', 'Dessert'];
    if (category != null && !values.contains(category)) {
      values.add(category!);
    }
    return values;
  }

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    titleController = TextEditingController(text: recipe.title);
    timeController = TextEditingController(text: recipe.time);
    descriptionController = TextEditingController(text: recipe.description);
    ingredientsController = TextEditingController(
      text: recipe.ingredients.join('\n'),
    );
    instructionsController = TextEditingController(
      text: recipe.instructions.join('\n'),
    );
    category = recipe.category;
  }

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

    setState(() => isSaving = true);
    try {
      final imagePath = selectedImage == null
          ? null
          : await recipeService.uploadRecipeImage(selectedImage!);
      await recipeService.updateRecipe(
        recipe: widget.recipe,
        title: titleController.text,
        category: category!,
        time: timeController.text,
        description: descriptionController.text,
        ingredients: ingredients,
        instructions: instructions,
        imagePath: imagePath,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe updated successfully.')),
      );
      Navigator.pop(context);
    } catch (error) {
      debugPrint('Recipe update error: $error');
      if (mounted) _showMessage('Unable to update recipe. Please try again.');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> pickImage() async {
    try {
      final image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        if (bytes.isEmpty) {
          _showMessage('The selected image is empty or invalid.');
          return;
        }
        setState(() {
          selectedImage = image;
          selectedImageBytes = bytes;
        });
      }
    } catch (error) {
      debugPrint('Image selection error: $error');
      if (mounted) _showMessage('Unable to select image. Please try again.');
    }
  }

  List<String> _lines(String value) => value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: isSaving ? null : pickImage,
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3EE),
                  borderRadius: BorderRadius.circular(13),
                ),
                clipBehavior: Clip.hardEdge,
                child: selectedImage == null
                    ? RecipeImage(imagePath: widget.recipe.imagePath)
                    : Image.memory(
                        selectedImageBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            _field(titleController, 'Recipe Title'),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: isSaving ? null : (value) => setState(() => category = value),
            ),
            const SizedBox(height: 14),
            _field(timeController, 'Cooking Time'),
            const SizedBox(height: 14),
            _field(descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 14),
            _field(ingredientsController, 'Ingredients (one per line)', maxLines: 5),
            const SizedBox(height: 14),
            _field(instructionsController, 'Instructions (one step per line)', maxLines: 7),
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
                    : const Text('Update Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}