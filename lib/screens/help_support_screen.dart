import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <Map<String, String>>[
      {'title': 'How do I add a recipe?', 'body': 'Open your profile, choose Add Recipe, complete the fields, and save.'},
      {'title': 'How do I save or favorite a recipe?', 'body': 'Use the bookmark or heart icon on a recipe card or its detail page.'},
      {'title': 'How do I edit my recipe?', 'body': 'Open My Recipes and select the edit icon on one of your recipes.'},
      {'title': 'How do I delete my recipe?', 'body': 'Open My Recipes, select the delete icon, and confirm the action.'},
      {'title': 'How do ratings work?', 'body': 'Open a Firestore recipe and select one to five stars. Your rating can be changed at any time.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => Card(
                elevation: 0,
                child: ExpansionTile(
                  title: Text(item['title']!),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [Text(item['body']!)],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
