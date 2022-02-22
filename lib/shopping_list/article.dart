import 'package:hive_flutter/hive_flutter.dart';

part 'article.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  int quantity = 1;
  @HiveField(2)
  QuantityUnit quantityUnit = QuantityUnit.pieces;
  @HiveField(3)
  String details = "";

  static String quantityUnitToString(QuantityUnit unit) {
    switch (unit) {
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
    return "$name, $quantity ${quantityUnitToString(quantityUnit)}, $details";
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
