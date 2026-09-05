import 'package:flutter/material.dart';

import '../widgets/profile_option.dart';

class ProfileScreen extends StatelessWidget {
  final int favoriteCount;
  final int savedCount;

  const ProfileScreen({
    super.key,
    required this.favoriteCount,
    required this.savedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
            const Text(
              'Recipe Lover',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'recipe@example.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: ProfileStat(
                    number: favoriteCount.toString(),
                    label: 'Favorites',
                    icon: Icons.favorite,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ProfileStat(
                    number: savedCount.toString(),
                    label: 'Saved',
                    icon: Icons.bookmark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            const ProfileOption(
              icon: Icons.favorite_border,
              title: 'My Favorites',
            ),
            const ProfileOption(
              icon: Icons.bookmark_border,
              title: 'Saved Recipes',
            ),
            const ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
            ),
            const ProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
            ),
          ],
        ),
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
          Icon(
            icon,
            color: const Color(0xFF4FA58C),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}