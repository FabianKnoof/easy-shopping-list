import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CookingListHive {
  static final CookingListHive _cookingListHive = CookingListHive._internal();

  factory CookingListHive() {
    return _cookingListHive;
  }

  CookingListHive._internal();

  static final String cookingListBoxName = "CookingList";

  final Box<Meal> cookingListBox = Hive.box<Meal>(cookingListBoxName);

  static final String cookingListCheckedBoxName = "CookingListChecked";

  final Box<Meal> cookingListCheckedBox =
      Hive.box<Meal>(cookingListCheckedBoxName);

  void addMeal(Meal? newMeal) {
    if (newMeal == null) return;
    for (Article ingredient in newMeal.ingredients) {
      ingredient.mealIndex = cookingListBox.length;
    }
    cookingListBox.put(cookingListBox.length, newMeal);
    ShoppingListHive().addArticles(newMeal.ingredients);
    // Todo check if meal already present
  }

  void replaceMeal(int? indexKey, Meal? meal) {
    if (indexKey == null || meal == null) return;
    cookingListBox.put(indexKey, meal);
    // Todo maybe change ingredient meal key
  }

  void reorderMealAt(int oldIndex, int newIndex) {
    // Todo handle ingredients meal keys
    Meal reorderedMeal = cookingListBox.get(oldIndex)!;
    if (oldIndex < newIndex) {
      --newIndex;
      for (int indexKey = oldIndex; indexKey < newIndex; ++indexKey) {
        Meal nextMeal = cookingListBox.get(indexKey + 1)!;
        cookingListBox.delete(indexKey + 1);
        cookingListBox.put(indexKey, nextMeal);
      }
      cookingListBox.put(newIndex, reorderedMeal);
    } else {
      for (int indexKey = oldIndex; indexKey > newIndex; --indexKey) {
        Meal nextMeal = cookingListBox.get(indexKey - 1)!;
        cookingListBox.delete(indexKey - 1);
        cookingListBox.put(indexKey, nextMeal);
      }
      cookingListBox.put(newIndex, reorderedMeal);
    }
  }

  void removeMealAt(int indexKey) {
    Map<dynamic, Meal> mealMap = {};
    for (int i = indexKey; i < cookingListBox.length - 1; ++i) {
      mealMap[i] = cookingListBox.get(i + 1)!;
    }
    cookingListBox
        .deleteAll([for (int i = indexKey; i < cookingListBox.length; ++i) i]);
    cookingListBox.putAll(mealMap);
  }

  void checkMeal(Meal meal) {
    // Todo check ingredients?
    removeMealAt(meal.key);
    cookingListCheckedBox.add(meal);
  }

  void uncheckMeal(Meal meal) {
    // Todo uncheck ingredients?
    meal.delete();
    addMeal(meal);
  }
}
