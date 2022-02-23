import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CookingListHive {
  static final CookingListHive _cookingListHive = CookingListHive._internal();

  factory CookingListHive() {
    return _cookingListHive;
  }

  CookingListHive._internal();

  final Box<Meal> box = Hive.box<Meal>("CookingList");
}
