import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SuggestionsHive {
  static final SuggestionsHive _suggestionsHive = SuggestionsHive._internal();

  factory SuggestionsHive() {
    return _suggestionsHive;
  }

  SuggestionsHive._internal();

  static final String versionsBoxName = "VersionsSuggestions";

  final Box<int> versionsBox = Hive.box<int>(versionsBoxName);

  static final String articleBoxName = "ArticleSuggestions";

  final Box<Article> articleBox = Hive.box<Article>(articleBoxName);

  static final String mealBoxName = "MealSuggestions";

  final Box<Meal> mealBox = Hive.box<Meal>(articleBoxName);
}
