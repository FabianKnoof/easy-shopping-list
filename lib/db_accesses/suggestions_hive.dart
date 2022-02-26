import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VersionsSuggestionsHive {
  static final VersionsSuggestionsHive _versionsSuggestionsHive =
      VersionsSuggestionsHive._internal();

  factory VersionsSuggestionsHive() {
    return _versionsSuggestionsHive;
  }

  VersionsSuggestionsHive._internal();

  static final String boxName = "VersionsSuggestions";

  final Box<int> box = Hive.box<int>(boxName);
}

class ArticleSuggestionsHive {
  static final ArticleSuggestionsHive _articleSuggestionsHive =
      ArticleSuggestionsHive._internal();

  factory ArticleSuggestionsHive() {
    return _articleSuggestionsHive;
  }

  ArticleSuggestionsHive._internal();

  static final String boxName = "ArticleSuggestions";

  final Box<Article> box = Hive.box<Article>(boxName);
}

class MealSuggestionsHive {
  static final MealSuggestionsHive _mealSuggestionsHive =
      MealSuggestionsHive._internal();

  factory MealSuggestionsHive() {
    return _mealSuggestionsHive;
  }

  MealSuggestionsHive._internal();

  static final String boxName = "MealSuggestions";

  final Box<Meal> box = Hive.box<Meal>(boxName);
}
