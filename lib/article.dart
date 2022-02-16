class Article {
  String name = "";
  String quantity = "";
  QuantityUnit quantityUnit = QuantityUnit.pieces;
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
}

enum QuantityUnit { pieces, gram, milliliter }
