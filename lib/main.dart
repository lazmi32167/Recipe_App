import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FA58C),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
