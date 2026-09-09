import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      ('Welcome to Recipe App', 'Explore recipes, save favorites, and share your own creations.', Icons.waving_hand_outlined),
      ('Community recipes are live', 'Rate and review Firestore-backed recipes to help other cooks.', Icons.groups_outlined),
      ('Make it yours', 'Adjust servings on recipe details to scale numeric ingredients.', Icons.tune_outlined),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(item.$3, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: Text(item.$1),
              subtitle: Text(item.$2),
            ),
          );
        },
      ),
    );
  }
}
