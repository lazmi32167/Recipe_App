import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/widgets/app_loading.dart';
import 'package:recipe_app/widgets/app_empty_state.dart';
import 'package:recipe_app/widgets/app_error_state.dart';

void main() {
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
  });
}