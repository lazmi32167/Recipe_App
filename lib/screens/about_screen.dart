import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Recipe App')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Icon(Icons.restaurant_menu, size: 64, color: Color(0xFF4FA58C)),
          SizedBox(height: 12),
          Center(child: Text('Recipe App', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
          Center(child: Text('Version 1.0.0')),
          SizedBox(height: 28),
          Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('A recipe discovery and community application where users can explore, save, favorite, create, rate, and review recipes.'),
          SizedBox(height: 24),
          Text('Main Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Recipe Discovery\nSearch and Categories\nFavorites\nSaved Recipes\nAdd and Edit Recipes\nCommunity Ratings\nReviews\nDark Mode\nFirebase Authentication'),
          SizedBox(height: 24),
          Text('Technology', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Flutter\nFirebase Authentication\nCloud Firestore\nFirebase Storage'),
        ],
      ),
    );
  }
}
