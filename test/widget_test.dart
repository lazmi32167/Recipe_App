import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/firebase_options.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/screens/recipe_detail_page.dart';
import 'package:recipe_app/widgets/app_loading.dart';
import 'package:recipe_app/widgets/app_empty_state.dart';
import 'package:recipe_app/widgets/app_error_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('App UI Components', () {
    testWidgets('AppLoading displays circular progress indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoading(message: 'Loading...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('AppEmptyState displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No Items',
              subtitle: 'No items to display',
            ),
          ),
        ),
      );

      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('No items to display'), findsOneWidget);
    });

    testWidgets('AppErrorState displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorState(
              title: 'Error Occurred',
              subtitle: 'Something went wrong',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Error Occurred'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('Recipe detail scales fraction ingredients with servings',
        (WidgetTester tester) async {
      const recipe = Recipe(
        id: 'demo-scaling',
        title: 'Test Recipe',
        category: 'Dinner',
        time: '20 min',
        rating: '4.8',
        imagePath: 'assets/images/creamy_pasta.jpg',
        icon: Icons.restaurant,
        description: 'Test recipe description',
        ingredients: ['1/2 cup milk', '2 eggs'],
        instructions: ['Mix well'],
        baseServings: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RecipeDetailPage(
            recipe: recipe,
            isFavorite: false,
            isSaved: false,
            onFavoriteTap: (_) {},
            onSavedTap: (_) {},
          ),
        ),
      );

      expect(find.text('1/2 cup milk'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('1 cup milk'), findsOneWidget);
      expect(find.text('4 eggs'), findsOneWidget);
    });
  });
}