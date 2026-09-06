import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/user_recipe_service.dart';
import '../widgets/profile_option.dart';
import 'my_favorites_screen.dart';
import 'saved_recipes_screen.dart';

class ProfileScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onRecipeTap;
  final VoidCallback onAddRecipe;
  final VoidCallback onMyRecipes;

  const ProfileScreen({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
    required this.onAddRecipe,
    required this.onMyRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    final service = UserRecipeService();

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          String name = user.displayName ?? 'Recipe Lover';
          String email = user.email ?? '';

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            name = data['name'] ?? name;
            email = data['email'] ?? email;
          }

          return StreamBuilder<int>(
            stream: service.countStream('favorites'),
            builder: (context, favoriteCountSnapshot) {
              return StreamBuilder<int>(
                stream: service.countStream('savedRecipes'),
                builder: (context, savedCountSnapshot) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 55,
                          backgroundColor: Color(0xFFE8F3EE),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF4FA58C),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(email, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 35),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileStat(
                                number: '${favoriteCountSnapshot.data ?? 0}',
                                label: 'Favorites',
                                icon: Icons.favorite,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ProfileStat(
                                number: '${savedCountSnapshot.data ?? 0}',
                                label: 'Saved',
                                icon: Icons.bookmark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        ProfileOption(
                          icon: Icons.favorite_border,
                          title: 'My Favorites',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyFavoritesScreen(
                                  recipes: recipes,
                                  onRecipeTap: onRecipeTap,
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileOption(
                          icon: Icons.bookmark_border,
                          title: 'Saved Recipes',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SavedRecipesScreen(
                                  recipes: recipes,
                                  onRecipeTap: onRecipeTap,
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileOption(
                          icon: Icons.add_circle_outline,
                          title: 'Add Recipe',
                          onTap: onAddRecipe,
                        ),
                        ProfileOption(
                          icon: Icons.restaurant_menu,
                          title: 'My Recipes',
                          onTap: onMyRecipes,
                        ),
                        const ProfileOption(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                        ),
                        const ProfileOption(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Logout',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const ProfileStat({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4FA58C)),

          const SizedBox(height: 8),

          Text(
            number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
