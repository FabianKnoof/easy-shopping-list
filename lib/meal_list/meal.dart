import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 3)
class Meal extends HiveObject {
  @HiveField(0, defaultValue: "")
  String name = "";
  @HiveField(1, defaultValue: 1)
  int quantity = 1;
  @HiveField(2, defaultValue: "Portion(en)")
  String quantityUnit = "Portion(en)";
  @HiveField(3, defaultValue: [])
  List<Article> ingredients = [];

  Meal();

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);

  Meal getCopy() {
    return Meal()
      ..name = name
      ..quantity = quantity
      ..quantityUnit = quantityUnit
      ..ingredients = [
        for (Article ingredient in ingredients) ingredient.getCopy()
      ];
  }

  @override
  String toString() {
    return "$name $quantity$quantityUnit $ingredients";
  }
}
