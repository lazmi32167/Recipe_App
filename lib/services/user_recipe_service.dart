import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/recipe.dart';

class UserRecipeService {
  UserRecipeService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No user is currently signed in.');
    }

    return _firestore.collection('users').doc(user.uid).collection(name);
  }

  Stream<Set<String>> recipeIdsStream(String collectionName) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<Set<String>>.value(<String>{});
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection(collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Stream<int> countStream(String collectionName) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<int>.value(0);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection(collectionName)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> recipesStream(
    String collectionName,
  ) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection(collectionName)
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  Future<void> toggleFavorite(Recipe recipe, bool isFavorite) {
    return _toggleRecipe('favorites', recipe, isFavorite);
  }

  Future<void> toggleSaved(Recipe recipe, bool isSaved) {
    return _toggleRecipe('savedRecipes', recipe, isSaved);
  }

  Future<void> _toggleRecipe(
    String collectionName,
    Recipe recipe,
    bool isActive,
  ) async {
    final reference = _collection(collectionName).doc(recipe.id);

    if (!isActive) {
      await reference.delete();
      if (recipe.id.startsWith('legacy_') && recipe.legacyId != recipe.id) {
        await _collection(collectionName).doc(recipe.legacyId).delete();
      }
      return;
    }

    if (recipe.id.startsWith('legacy_') && recipe.legacyId != recipe.id) {
      await _collection(collectionName).doc(recipe.legacyId).delete();
    }

    await reference.set({
      'recipeId': recipe.id,
      'title': recipe.title,
      'category': recipe.category,
      'time': recipe.time,
      'rating': recipe.rating,
      'imagePath': recipe.imagePath,
      'description': recipe.description,
      'ingredients': recipe.ingredients,
      'instructions': recipe.instructions,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }
}
