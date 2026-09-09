import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/recipe.dart';

class RecipeService {
  RecipeService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('recipes');

  Stream<List<Recipe>> getRecipes() {
    // A single malformed Firestore document must never make the whole Home
    // catalog disappear. Parse documents independently and keep valid ones.
    return _recipes.snapshots().map((snapshot) {
      final recipes = <Recipe>[];
      for (final document in snapshot.docs) {
        try {
          recipes.add(Recipe.fromFirestore(document));
        } catch (error, stackTrace) {
          debugPrint(
            'Skipping invalid recipe document ${document.id}: $error\n$stackTrace',
          );
        }
      }
      recipes.sort(_compareByDate);
      return recipes;
    });
  }

  Stream<List<Recipe>> getMyRecipes(String userId) {
    return _recipes.where('createdBy', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final recipes = snapshot.docs.map(Recipe.fromFirestore).toList();
      recipes.sort(_compareByDate);
      return recipes;
    });
  }

  Future<void> seedDemoRecipes(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;
    final batch = _firestore.batch();
    for (final recipe in recipes) {
      final reference = _recipes.doc(recipe.id);
      batch.set(reference, {
        ...recipe.toMap(),
        'calories': recipe.calories > 0 ? recipe.calories : 350,
        'baseServings': recipe.baseServings > 0 ? recipe.baseServings : 2,
        'createdBy': 'system',
        'createdByName': 'Recipe App',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: false));
    }
    try {
      await batch.commit();
      debugPrint('Demo recipe seed completed: ${recipes.length} recipes');
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Demo recipe seed failed: ${error.code} - ${error.message}\n$stackTrace');
    }
  }

  Future<void> ensureSeededRecipes(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;
    try {
      final snapshot = await _recipes.limit(1).get();
      if (snapshot.docs.isNotEmpty) return;
      await seedDemoRecipes(recipes);
    } catch (error, stackTrace) {
      debugPrint('Demo recipe check failed: $error\n$stackTrace');
    }
  }

  Future<String> addRecipe({
    required String title,
    required String category,
    required String time,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required String createdByName,
    required int calories,
    required int baseServings,
    String? imagePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to add a recipe.');
    }

    final reference = _recipes.doc();
    final data = <String, dynamic>{
      'title': title.trim(),
      'category': category,
      'time': time.trim(),
      'rating': '0.0',
      'imagePath': imagePath ?? 'assets/images/creamy_pasta.jpg',
      'description': description.trim(),
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'baseServings': baseServings,
      'createdBy': user.uid,
      'createdByName': createdByName.trim().isEmpty
          ? 'Anonymous User'
          : createdByName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    debugPrint('ADD RECIPE STEP 1: authenticated uid=${user.uid}');
    debugPrint('ADD RECIPE STEP 7: Firestore write starting');
    debugPrint('Firestore path: ${reference.path}');
    debugPrint('Firestore createdBy: ${data['createdBy']}');
    try {
      await reference.set(data);
      debugPrint('ADD RECIPE STEP 8: Firestore document created');
      debugPrint('Generated recipe document ID: ${reference.id}');
      return reference.id;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('ADD RECIPE FIRESTORE ERROR');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('Path: ${reference.path}');
      debugPrint('UID: ${user.uid}');
      debugPrint('$stackTrace');
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('ADD RECIPE ERROR: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<String> uploadRecipeImage(XFile image) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to upload an image.');
    }

    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('The selected image is empty or invalid.');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final reference = _storage.ref().child('recipes/${user.uid}/$fileName');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    debugPrint('Uploading recipe image to ${reference.fullPath}');
    try {
      await reference.putData(bytes, metadata);
      final downloadUrl = await reference.getDownloadURL();
      debugPrint('Recipe image uploaded: ${reference.fullPath}');
      return downloadUrl;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Recipe image Firebase error: ${error.code} - ${error.message}\n$stackTrace',
      );
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Recipe image upload error: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<void> updateRecipe({
    required Recipe recipe,
    required String title,
    required String category,
    required String time,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required int calories,
    required int baseServings,
    String? imagePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to update a recipe.');
    }
    if (recipe.id.isEmpty || recipe.createdBy != user.uid) {
      throw StateError('You can only update your own recipes.');
    }

    final updates = <String, Object?>{
      'title': title.trim(),
      'category': category,
      'time': time.trim(),
      'description': description.trim(),
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'baseServings': baseServings,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (imagePath != null) {
      updates['imagePath'] = imagePath;
    }
    try {
      await _recipes.doc(recipe.id).update(updates);
    } catch (_) {
      if (imagePath != null) {
        await _deleteStorageImage(imagePath);
      }
      rethrow;
    }
    if (imagePath != null && imagePath != recipe.imagePath) {
      await _deleteStorageImage(recipe.imagePath);
    }
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to delete a recipe.');
    }

    if (recipe.id.isEmpty || recipe.createdBy != user.uid) {
      throw StateError('You can only delete your own recipes.');
    }

    final reference = _recipes.doc(recipe.id);
    final snapshot = await reference.get();
    if (!snapshot.exists || snapshot.data()?['createdBy'] != user.uid) {
      throw StateError('You can only delete your own recipes.');
    }
    await reference.delete();
    await _deleteStorageImage(snapshot.data()?['imagePath']);
  }

  Future<void> replaceRecipeImage({
    required Recipe recipe,
    required XFile image,
  }) async {
    final imagePath = await uploadRecipeImage(image);
    try {
      await updateRecipe(
        recipe: recipe,
        title: recipe.title,
        category: recipe.category,
        time: recipe.time,
        description: recipe.description,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        calories: recipe.calories,
        baseServings: recipe.baseServings,
        imagePath: imagePath,
      );
    } catch (_) {
      await _deleteStorageImage(imagePath);
      rethrow;
    }
    await _deleteStorageImage(recipe.imagePath);
  }

  Future<void> _deleteStorageImage(Object? imagePath) async {
    if (imagePath is! String || !_isRecipeStorageUrl(imagePath)) {
      return;
    }
    try {
      await _storage.refFromURL(imagePath).delete();
    } catch (_) {
      // Firestore changes should remain successful if cleanup is unavailable.
    }
  }

  bool _isRecipeStorageUrl(String imagePath) {
    final uri = Uri.tryParse(imagePath);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return false;
    }
    final decodedPath = Uri.decodeComponent(uri.path);
    final isFirebaseStorageHost =
        uri.host == 'firebasestorage.googleapis.com' ||
        uri.host.endsWith('.firebasestorage.app');
    return isFirebaseStorageHost && decodedPath.contains('/o/recipes/');
  }

  static int _compareByDate(Recipe first, Recipe second) {
    final firstDate = first.createdAt;
    final secondDate = second.createdAt;
    if (firstDate == null && secondDate == null) {
      return first.title.toLowerCase().compareTo(second.title.toLowerCase());
    }
    if (firstDate == null) return 1;
    if (secondDate == null) return -1;
    return secondDate.compareTo(firstDate);
  }
}
