import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/recipe.dart';

class RecipeService {
  RecipeService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('recipes');

  Stream<List<Recipe>> getRecipes() {
    return _recipes.snapshots().map((snapshot) {
      final recipes = snapshot.docs.map(Recipe.fromFirestore).toList();
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

  Future<void> addRecipe({
    required String title,
    required String category,
    required String time,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required String createdByName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to add a recipe.');
    }

    await _recipes.add({
      'title': title.trim(),
      'category': category,
      'time': time.trim(),
      'rating': '0.0',
      'imagePath': 'assets/images/creamy_pasta.jpg',
      'description': description.trim(),
      'ingredients': ingredients,
      'instructions': instructions,
      'createdBy': user.uid,
      'createdByName': createdByName.trim().isEmpty
          ? 'Anonymous User'
          : createdByName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRecipe(String recipeId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to delete a recipe.');
    }

    final reference = _recipes.doc(recipeId);
    final snapshot = await reference.get();
    if (!snapshot.exists || snapshot.data()?['createdBy'] != user.uid) {
      throw StateError('You can only delete your own recipes.');
    }
    await reference.delete();
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
