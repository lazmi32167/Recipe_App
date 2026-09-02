import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/main.dart';

void main() {
  testWidgets('Recipe app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const RecipeApp());

    expect(find.text('What are you\ncooking today?'), findsOneWidget);
  });
}