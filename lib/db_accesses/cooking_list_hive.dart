import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CookingListHive {
  static final CookingListHive _cookingListHive = CookingListHive._internal();

  factory CookingListHive() {
    return _cookingListHive;
  }

  CookingListHive._internal();

  final Box<Meal> box = Hive.box<Meal>("CookingList");

  void addMeal(Meal? newMeal) {
    if (newMeal == null) return;
    box.put(box.length, newMeal);
  }

  void replaceMeal(int? indexKey, Meal? meal) {
    if (indexKey == null || meal == null) return;
    box.put(indexKey, meal);
  }

  void reorderMealAt(int oldIndex, int newIndex) {
    Meal reorderedMeal = box.get(oldIndex)!;
    if (oldIndex < newIndex) {
      --newIndex;
    } else {
      int tmp = oldIndex;
      oldIndex = newIndex;
      newIndex = tmp;
    }
    for (int indexKey = oldIndex; indexKey < newIndex; ++indexKey) {
      Meal nextMeal = box.get(indexKey + 1)!;
      box.delete(indexKey + 1);
      box.put(indexKey, nextMeal);
    }
    // box.put(newIndex, reorderedMeal);
  }
}
