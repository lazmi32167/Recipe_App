import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String category;
  final String time;
  final String rating;
  final String imagePath;
  final IconData icon;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String? createdBy;
  final String? createdByName;
  final DateTime? createdAt;

  const Recipe({
    String? id,
    required this.title,
    required this.category,
    required this.time,
    required this.rating,
    required this.imagePath,
    required this.icon,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  }) : id = id ?? '';

  String get legacyId => title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  bool matchesIdentifier(String identifier) {
    return id == identifier ||
        legacyId == identifier ||
        'legacy_$legacyId' == identifier;
  }

  static Recipe fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final category = _stringValue(data['category'], fallback: 'Dinner');
    return Recipe(
      id: snapshot.id,
      title: _stringValue(data['title'], fallback: 'Untitled Recipe'),
      category: category,
      time: _stringValue(data['time'], fallback: 'Time unavailable'),
      rating: _stringValue(data['rating'], fallback: '0.0'),
      imagePath: _stringValue(
        data['imagePath'],
        fallback: 'assets/images/creamy_pasta.jpg',
      ),
      icon: _iconForCategory(category),
      description: _stringValue(data['description']),
      ingredients: _stringList(data['ingredients']),
      instructions: _stringList(data['instructions']),
      createdBy: _nullableString(data['createdBy']),
      createdByName: _nullableString(data['createdByName']),
      createdAt: _dateValue(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'time': time,
      'rating': rating,
      'imagePath': imagePath,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdByName != null) 'createdByName': createdByName,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  static String _stringValue(Object? value, {String fallback = ''}) {
    return value is String && value.trim().isNotEmpty ? value : fallback;
  }

  static String? _nullableString(Object? value) {
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! Iterable) {
      return const [];
    }
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static IconData _iconForCategory(String category) {
    switch (category) {
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dessert':
        return Icons.cake;
      case 'Dinner':
      default:
        return Icons.restaurant;
    }
  }
}
