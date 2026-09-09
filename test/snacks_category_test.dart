import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/recipe.dart';

void main() {
  test('Recipe includes Snacks in supported categories', () {
    expect(Recipe.categories, contains('Snacks'));
  });
}
