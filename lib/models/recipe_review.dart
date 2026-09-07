import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeReview {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final int? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecipeReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory RecipeReview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];
    final rating = data['rating'];
    return RecipeReview(
      id: snapshot.id,
      userId: data['userId'] as String? ?? snapshot.id,
      userName: data['userName'] as String? ?? 'Anonymous User',
      comment: data['comment'] as String? ?? '',
      rating: rating is num ? rating.toInt() : null,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }
}
