import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'meal.g.dart';

@HiveType(typeId: 2)
class Meal extends HiveObject {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  int quantity = 1;
  @HiveField(2)
  final String quantityUnit = "Portion(en)";
  @HiveField(3)
  List<Article> ingredients = [];

  @override
  String toString() {
    return "$name $quantity$quantityUnit $ingredients";
  }
}
