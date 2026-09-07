import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/recipe_review.dart';

class RecipeRatingSummary {
  final double average;
  final int count;

  const RecipeRatingSummary({required this.average, required this.count});
}

class RecipeFeedbackService {
  RecipeFeedbackService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _subcollection(
    String recipeId,
    String name,
  ) => _firestore.collection('recipes').doc(recipeId).collection(name);

  Stream<RecipeRatingSummary> ratingSummaryStream(String recipeId) {
    return _subcollection(recipeId, 'ratings').snapshots().map((snapshot) {
      final values = snapshot.docs
          .map((doc) => (doc.data()['rating'] as num?)?.toDouble())
          .whereType<double>()
          .where((value) => value >= 1 && value <= 5)
          .toList();
      final average = values.isEmpty
          ? 0.0
          : values.reduce((first, second) => first + second) / values.length;
      return RecipeRatingSummary(average: average, count: values.length);
    });
  }

  Stream<int> currentUserRatingStream(String recipeId) {
    final user = _auth.currentUser;
    if (user == null) return Stream<int>.value(0);
    return _subcollection(recipeId, 'ratings')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) => (snapshot.data()?['rating'] as num?)?.toInt() ?? 0);
  }

  Future<void> setRating(String recipeId, int rating) async {
    final user = _requireUser();
    if (recipeId.isEmpty || rating < 1 || rating > 5) {
      throw ArgumentError('A recipe rating must be between 1 and 5.');
    }
    final path = 'recipes/$recipeId/ratings/${user.uid}';
    debugPrint('Submitting rating: recipeId=$recipeId uid=${user.uid} path=$path');
    try {
      await _subcollection(recipeId, 'ratings').doc(user.uid).set({
        'userId': user.uid,
        'rating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Rating saved: path=$path');
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Rating Firebase error: ${error.code} - ${error.message}\n$stackTrace',
      );
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Rating error: $error\n$stackTrace');
      rethrow;
    }
  }

  Stream<List<RecipeReview>> reviewsStream(String recipeId) {
    return _subcollection(recipeId, 'reviews').snapshots().map((snapshot) {
      final reviews = snapshot.docs
          .map(RecipeReview.fromFirestore)
          .where((review) => review.comment.trim().isNotEmpty)
          .toList();
      reviews.sort((first, second) {
        final firstDate = first.updatedAt ?? first.createdAt;
        final secondDate = second.updatedAt ?? second.createdAt;
        if (firstDate == null && secondDate == null) return 0;
        if (firstDate == null) return 1;
        if (secondDate == null) return -1;
        return secondDate.compareTo(firstDate);
      });
      return reviews;
    });
  }

  Future<void> saveReview(
    String recipeId,
    String comment, {
    int? rating,
  }) async {
    final user = _requireUser();
    final trimmedComment = comment.trim();
    if (recipeId.isEmpty ||
        trimmedComment.isEmpty ||
        trimmedComment.length > 500) {
      throw ArgumentError('Review text must contain 1 to 500 characters.');
    }
    if (rating != null && (rating < 1 || rating > 5)) {
      throw ArgumentError('A review rating must be between 1 and 5.');
    }
    final reference = _subcollection(recipeId, 'reviews').doc(user.uid);
    final path = 'recipes/$recipeId/reviews/${user.uid}';
    debugPrint('Submitting review: recipeId=$recipeId uid=${user.uid} path=$path');
    final existing = await reference.get();
    Object? profileName;
    try {
      final profile = await _firestore.collection('users').doc(user.uid).get();
      profileName = profile.data()?['name'];
    } on FirebaseException catch (error) {
      debugPrint(
        'Profile lookup failed; using fallback name: ${error.code} - ${error.message}',
      );
    } catch (error) {
      debugPrint('Profile lookup failed; using fallback name: $error');
    }
    final userName = profileName is String && profileName.trim().isNotEmpty
        ? profileName.trim()
        : user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'Recipe User';
    try {
      await reference.set({
        'userId': user.uid,
        'userName': userName,
        'comment': trimmedComment,
        ...?rating == null ? null : {'rating': rating},
        'createdAt':
            existing.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Review saved: path=$path');
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Review Firebase error: ${error.code} - ${error.message}\n$stackTrace',
      );
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Review error: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteReview(String recipeId, String reviewId) async {
    final user = _requireUser();
    if (reviewId != user.uid) {
      throw StateError('You can only delete your own review.');
    }
    await _subcollection(recipeId, 'reviews').doc(reviewId).delete();
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please log in to continue.');
    return user;
  }
}
