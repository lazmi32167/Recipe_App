import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final imagePicker = ImagePicker();
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
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
      _showMessage('Please log in first.');
      return;
    }

    setState(() => isSaving = true);
    var currentStep = 'authentication';
    try {
      debugPrint('ADD RECIPE STEP 1: User authenticated, UID=${user.uid}');
      String? profileName;
      try {
        final profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        profileName = profile.data()?['name'] as String?;
        debugPrint('ADD RECIPE: profile lookup completed');
      } on FirebaseException catch (error, stackTrace) {
        debugPrint('ADD RECIPE PROFILE LOOKUP ERROR');
        debugPrint('Code: ${error.code}');
        debugPrint('Message: ${error.message}');
        debugPrint('$stackTrace');
        debugPrint('ADD RECIPE: continuing with Auth profile fallback');
      } catch (error, stackTrace) {
        debugPrint('ADD RECIPE PROFILE LOOKUP ERROR: $error');
        debugPrint('$stackTrace');
        debugPrint('ADD RECIPE: continuing with Auth profile fallback');
      }

      String? imagePath;
      if (selectedImage != null) {
        currentStep = 'image upload';
        debugPrint('ADD RECIPE STEP 2: Image selected');
        debugPrint('ADD RECIPE STEP 3: Image bytes loaded for upload');
        debugPrint('ADD RECIPE STEP 4: Firebase Storage upload starting');
        imagePath = await recipeService.uploadRecipeImage(selectedImage!);
        debugPrint('ADD RECIPE STEP 5: Firebase Storage upload completed');
        debugPrint('ADD RECIPE STEP 6: Download URL retrieved: $imagePath');
      } else {
        debugPrint('ADD RECIPE: No image selected; using default asset');
      }
      currentStep = 'Firestore recipe creation';
      await recipeService.addRecipe(
        title: titleController.text,
        category: category!,
        time: timeController.text,
        description: descriptionController.text,
        ingredients: ingredients,
        instructions: instructions,
        createdByName: profileName ?? user.displayName ?? 'Recipe User',
        imagePath: imagePath,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added successfully.')),
      );
      Navigator.pop(context);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('ADD RECIPE FIREBASE ERROR');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('$stackTrace');
      if (mounted) {
        final message = error.code == 'permission-denied' &&
            currentStep == 'Firestore recipe creation'
            ? 'Firestore permission denied: ${error.message ?? 'check Firebase rules.'}'
          : currentStep == 'image upload'
          ? 'Storage error: ${error.code}'
            : 'Firebase error while adding recipe: ${error.code}';
        _showMessage(message);
      }
    } catch (error, stackTrace) {
      debugPrint('ADD RECIPE ERROR: $error');
      debugPrint('$stackTrace');
      if (mounted) _showMessage('Could not add recipe: $error');
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
      if (mounted) _showMessage('Could not select image: $error');
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
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Color(0xFF4FA58C),
                          ),
                          SizedBox(height: 8),
                          Text('Add recipe image'),
                        ],
                      )
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
