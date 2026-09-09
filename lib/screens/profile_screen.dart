import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/user_recipe_service.dart';
import '../widgets/profile_option.dart';
import 'my_favorites_screen.dart';
import 'saved_recipes_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';

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
          String? photoUrl = user.photoURL;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            name = data['name'] ?? name;
            email = data['email'] ?? email;
            photoUrl = data['photoUrl'] as String? ?? photoUrl;
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
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: photoUrl == null
                              ? null
                              : NetworkImage(photoUrl),
                          child: photoUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
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
                        Text(
                          email,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                        ProfileOption(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                        ProfileOption(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmLogout(context),
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

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to logout. Please try again.')),
        );
      }
    }
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
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

          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
