import 'package:hive_flutter/hive_flutter.dart';

part 'article.g.dart';

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
  bool ingredient = true;

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
  @HiveField(0)
  pieces,
  @HiveField(1)
  gram,
  @HiveField(2)
  milliliter
}
