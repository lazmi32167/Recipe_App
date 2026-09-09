import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/recipe.dart';
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

  final caloriesController = TextEditingController(text: '350');
  final servingsController = TextEditingController(text: '2');

  final recipeService = RecipeService();
  final imagePicker = ImagePicker();

  XFile? selectedImage;
  Uint8List? selectedImageBytes;

  String? selectedAssetImage;
  String? category;

  bool isSaving = false;

  // =========================================================
  // APP ASSET IMAGES
  // =========================================================

  static const List<String> assetImages = [
  
  'assets/images/Aloo_vorta.jpg',
  'assets/images/chicken_burger.jpg',
  'assets/images/chocolate_cake.jpg',
  'assets/images/creamy_pasta.jpg',
  'assets/images/french_fries.jpg',
  'assets/images/fresh_salad.jpg',
  'assets/images/grilled_chicken.jpg',
  'assets/images/healthy_breakfast.jpg',
  'assets/images/chicken_momo.jpg',
];


  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    ingredientsController.dispose();
    instructionsController.dispose();
    caloriesController.dispose();
    servingsController.dispose();

    super.dispose();
  }

  // =========================================================
  // SAVE RECIPE
  // =========================================================

  Future<void> saveRecipe() async {
    final ingredients = _lines(ingredientsController.text);
    final instructions = _lines(instructionsController.text);

    if (titleController.text.trim().isEmpty ||
        category == null ||
        timeController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        ingredients.isEmpty ||
        instructions.isEmpty ||
        (int.tryParse(caloriesController.text.trim()) ?? -1) < 0 ||
        (int.tryParse(servingsController.text.trim()) ?? 0) < 1) {
      _showMessage('Please complete every recipe field.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please log in first.');
      return;
    }

    setState(() => isSaving = true);

    try {
      // =====================================================
      // GET USER NAME
      // =====================================================

      String? profileName;

      try {
        final profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        profileName = profile.data()?['name'] as String?;
      } catch (error) {
        debugPrint('Profile lookup failed: $error');
      }

      String? imagePath;

      // =====================================================
      // OPTION 1: GALLERY IMAGE
      // Upload to Firebase Storage
      // =====================================================

      if (selectedImage != null) {
        try {
          imagePath =
              await recipeService.uploadRecipeImage(selectedImage!);

          debugPrint(
            'Gallery image uploaded successfully: $imagePath',
          );
        } catch (error) {
          debugPrint('Gallery image upload failed: $error');

          if (mounted) {
            _showMessage(
              'Image upload failed. Please try again.',
            );
          }

          return;
        }
      }

      // =====================================================
      // OPTION 2: APP ASSET IMAGE
      // =====================================================

      if (imagePath == null && selectedAssetImage != null) {
        imagePath = selectedAssetImage;

        debugPrint(
          'Using app asset image: $imagePath',
        );
      }

      // =====================================================
      // DEFAULT IMAGE
      // =====================================================

      imagePath ??= 'assets/images/creamy_pasta.jpg';

      // =====================================================
      // SAVE TO FIRESTORE
      // =====================================================

      await recipeService.addRecipe(
        title: titleController.text.trim(),
        category: category!,
        time: timeController.text.trim(),
        description: descriptionController.text.trim(),
        ingredients: ingredients,
        instructions: instructions,
        createdByName:
            profileName ?? user.displayName ?? 'Recipe User',
        calories: int.parse(caloriesController.text.trim()),
        baseServings: int.parse(servingsController.text.trim()),
        imagePath: imagePath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added successfully.'),
        ),
      );

      Navigator.pop(context);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('ADD RECIPE FIREBASE ERROR');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage(
          'Firebase error while adding recipe: ${error.code}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('ADD RECIPE ERROR: $error');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage('Could not add recipe: $error');
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // =========================================================
  // PICK IMAGE FROM GALLERY
  // =========================================================

  Future<void> pickImageFromGallery() async {
    try {
      final image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      final bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        _showMessage('The selected image is empty or invalid.');
        return;
      }

      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;

        // Asset image selection remove করবে
        selectedAssetImage = null;
      });
    } catch (error) {
      debugPrint('Gallery image selection error: $error');

      if (mounted) {
        _showMessage('Could not select image: $error');
      }
    }
  }

  // =========================================================
  // SELECT APP ASSET IMAGE
  // =========================================================

  void selectAssetImage(String imagePath) {
    setState(() {
      selectedAssetImage = imagePath;

      // Gallery image remove করবে
      selectedImage = null;
      selectedImageBytes = null;
    });
  }

  // =========================================================
  // IMAGE SOURCE BOTTOM SHEET
  // =========================================================

  void showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Recipe Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF4FA58C),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text(
                    'Upload an image from your phone',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImageFromGallery();
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.collections_outlined,
                    color: Color(0xFF4FA58C),
                  ),
                  title: const Text('Choose from App Images'),
                  subtitle: const Text(
                    'Select one of the built-in recipe images',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAssetImagePicker();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // APP IMAGE PICKER DIALOG
  // =========================================================

  void _showAssetImagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Choose from App Images',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: GridView.builder(
                      itemCount: assetImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemBuilder: (context, index) {
                        final imagePath = assetImages[index];

                        final isSelected =
                            selectedAssetImage == imagePath;

                        return GestureDetector(
                          onTap: () {
                            selectAssetImage(imagePath);

                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4FA58C)
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),

                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4FA58C),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // TEXT TO LIST
  // =========================================================

  List<String> _lines(String value) {
    return value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // =========================================================
  // BUILD UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =================================================
            // IMAGE PREVIEW
            // =================================================

            GestureDetector(
              onTap: isSaving ? null : showImageSourceOptions,

              child: Container(
                height: 200,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3EE),
                  borderRadius: BorderRadius.circular(14),
                ),

                clipBehavior: Clip.hardEdge,

                child: selectedImage != null
                    ? Image.memory(
                        selectedImageBytes!,
                        fit: BoxFit.cover,
                      )

                    : selectedAssetImage != null
                        ? Image.asset(
                            selectedAssetImage!,
                            fit: BoxFit.cover,
                          )

                        : const Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 55,
                                color: Color(0xFF4FA58C),
                              ),

                              SizedBox(height: 10),

                              Text(
                                'Tap to choose recipe image',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                'Gallery or App Images',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: TextButton.icon(
                onPressed:
                    isSaving ? null : showImageSourceOptions,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Change Image'),
              ),
            ),

            const SizedBox(height: 15),

            // =================================================
            // TITLE
            // =================================================

            _field(
              titleController,
              'Recipe Title',
            ),

            const SizedBox(height: 14),

            // =================================================
            // CATEGORY
            // =================================================

            DropdownButtonFormField<String>(
              initialValue: category,

              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),

              items: Recipe.categories
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),

              onChanged: (value) {
                setState(() => category = value);
              },
            ),

            const SizedBox(height: 14),

            _field(
              timeController,
              'Cooking Time',
            ),

            const SizedBox(height: 14),

            _field(
              descriptionController,
              'Description',
              maxLines: 3,
            ),

            const SizedBox(height: 14),

            _field(
              caloriesController,
              'Calories (kcal)',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 14),

            _field(
              servingsController,
              'Base servings',
              keyboardType: TextInputType.number,
            ),

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

            const SizedBox(height: 25),

            // =================================================
            // SAVE BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: isSaving ? null : saveRecipe,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF4FA58C),

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                child: isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,

                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )

                    : const Text(
                        'Save Recipe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}