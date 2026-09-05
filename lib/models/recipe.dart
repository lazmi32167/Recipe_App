import 'package:flutter/material.dart';

class Recipe {
  final String title;
  final String category;
  final String time;
  final String rating;
  final IconData icon;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;

  const Recipe({
    required this.title,
    required this.category,
    required this.time,
    required this.rating,
    required this.icon,
    required this.description,
    required this.ingredients,
    required this.instructions,
  });
}