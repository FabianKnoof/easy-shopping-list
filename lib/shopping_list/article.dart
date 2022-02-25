import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0, defaultValue: "")
  String name = "";
  @HiveField(1, defaultValue: 1)
  int quantity = 1;
  @HiveField(2, defaultValue: QuantityUnit.pieces)
  QuantityUnit quantityUnit = QuantityUnit.pieces;
  @HiveField(3, defaultValue: "")
  String details = "";
  @HiveField(4, defaultValue: true)
  bool isIngredient = true;

  Article();

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);

  static String quantityUnitToString(QuantityUnit quantityUnit) {
    switch (quantityUnit) {
      case QuantityUnit.pieces:
        return "stk";
      case QuantityUnit.gram:
        return "g";
      case QuantityUnit.milliliter:
        return "ml";
    }
  }

  String quantityUnitAsString() {
    switch (quantityUnit) {
      case QuantityUnit.pieces:
        return "stk";
      case QuantityUnit.gram:
        return "g";
      case QuantityUnit.milliliter:
        return "ml";
    }
  }

  @override
  String toString() {
    return "$name, $quantity ${quantityUnitAsString()}, $details";
  }
}

@HiveType(typeId: 1)
enum QuantityUnit {
  @JsonValue("pieces")
  @HiveField(0)
  pieces,
  @JsonValue("gram")
  @HiveField(1)
  gram,
  @JsonValue("milliliter")
  @HiveField(2)
  milliliter
}
