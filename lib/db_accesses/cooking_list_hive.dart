import 'package:easy_shopping_list/db_accesses/hive_interaction.dart';
import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CookingListHive with HiveHelperFunctions {
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
    cookingListBox.put(cookingListBox.length, newMeal);
    ShoppingListHive().addArticles(newMeal.ingredients);
  }

  void replaceMeal(int? indexKey, Meal? meal) {
    if (indexKey == null || meal == null) return;
    for (Article ingredient in cookingListBox.get(indexKey)!.ingredients) {
      ShoppingListHive().removeIngredient(ingredient);
    }
    ShoppingListHive().addArticles(meal.ingredients);
    cookingListBox.put(indexKey, meal);
  }

  void reorderMealAt(int oldIndex, int newIndex) {
    reorderEntries(oldIndex, newIndex, cookingListBox);
  }

  void removeMealAt(int indexKey) {
    removeEntryAt(indexKey, cookingListBox);
  }

  void checkMeal(Meal meal) {
    for (Article ingredient in meal.ingredients) {
      ShoppingListHive().removeIngredient(ingredient);
      ingredient.isChecked = true;
    }
    removeMealAt(meal.key);
    cookingListCheckedBox.add(meal);
  }

  void uncheckMeal(Meal meal) {
    for (Article ingredient in meal.ingredients) {
      ingredient.isChecked = false;
    }
    meal.delete();
    addMeal(meal);
  }

  Meal getMealByName(String name) {
    return cookingListBox.values.singleWhere((element) => element.name == name);
  }
}
