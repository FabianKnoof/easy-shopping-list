import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ArticleSuggestionsHive {
  static final ArticleSuggestionsHive _articleSuggestionsHive =
      ArticleSuggestionsHive._internal();

  factory ArticleSuggestionsHive() {
    return _articleSuggestionsHive;
  }

  ArticleSuggestionsHive._internal();

  final Box<Article> box = Hive.box<Article>("ArticleSuggestions");
}

class MealSuggestionsHive {
  static final MealSuggestionsHive _mealSuggestionsHive =
      MealSuggestionsHive._internal();

  factory MealSuggestionsHive() {
    return _mealSuggestionsHive;
  }

  MealSuggestionsHive._internal();

  final Box<Meal> box = Hive.box<Meal>("MealSuggestions");
}
