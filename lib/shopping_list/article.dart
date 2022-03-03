import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0, defaultValue: "")
  String name = "";
  @HiveField(1, defaultValue: 0)
  int quantity = 0;
  @HiveField(2, defaultValue: QuantityUnit.pieces)
  QuantityUnit quantityUnit = QuantityUnit.pieces;
  @HiveField(3, defaultValue: "")
  String details = "";
  @HiveField(4, defaultValue: true)
  bool isIngredient = true;
  @JsonKey(ignore: true)
  @HiveField(5, defaultValue: false)
  bool isChecked = false;
  @JsonKey(ignore: true)
  @HiveField(6, defaultValue: "")
  String partOfMeal = "";

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
      case QuantityUnit.teaspoon:
        return "tl";
      case QuantityUnit.tablespoon:
        return "el";
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
      case QuantityUnit.teaspoon:
        return "tl";
      case QuantityUnit.tablespoon:
        return "el";
    }
  }

  Article getCopy() {
    return Article()
      ..name = name
      ..quantity = quantity
      ..quantityUnit = quantityUnit
      ..details = details
      ..isIngredient = isIngredient
      ..isChecked = isChecked
      ..partOfMeal = partOfMeal;
  }

  @override
  String toString() {
    return "$name, $quantity${quantityUnitAsString()}, $details, $isIngredient, $isChecked, $partOfMeal;";
  }
}

@HiveType(typeId: 1)
class ArticleEntry extends HiveObject {
  @HiveField(0, defaultValue: "")
  String name = "";
  @HiveField(1, defaultValue: 0)
  int quantity = 0;
  @HiveField(2, defaultValue: QuantityUnit.pieces)
  QuantityUnit quantityUnit = QuantityUnit.pieces;
  @HiveField(3, defaultValue: "")
  String details = "";
  @HiveField(4, defaultValue: [])
  List<Article> articles = [];

  ArticleEntry(
      this.name, this.quantity, this.quantityUnit, this.details, this.articles);

  void addArticle(Article article) {
    articles.add(article);
    quantity += article.quantity;
    details += details.isEmpty ? article.details : ", ${article.details}";

    save();
  }

  void removeArticle(Article removeArticle) {
    articles
        .removeWhere((element) => element.quantity == removeArticle.quantity);
    if (articles.isEmpty) {
      ShoppingListHive().removeArticleEntry(this);
    } else {
      quantity -= removeArticle.quantity;
      details.replaceAll(removeArticle.details, "");
      details.replaceAll(",,", ",");
      save();
    }
  }

  Article getAsArticle() {
    return Article()
      ..name = name
      ..quantity = quantity
      ..quantityUnit = quantityUnit
      ..details = details;
  }

  String quantityUnitAsString() {
    switch (quantityUnit) {
      case QuantityUnit.pieces:
        return "stk";
      case QuantityUnit.gram:
        return "g";
      case QuantityUnit.milliliter:
        return "ml";
      case QuantityUnit.teaspoon:
        return "tl";
      case QuantityUnit.tablespoon:
        return "el";
    }
  }
}

@HiveType(typeId: 2)
enum QuantityUnit {
  @JsonValue("pieces")
  @HiveField(0)
  pieces,
  @JsonValue("gram")
  @HiveField(1)
  gram,
  @JsonValue("milliliter")
  @HiveField(2)
  milliliter,
  @JsonValue("teaspoon")
  @HiveField(3)
  teaspoon,
  @JsonValue("tablespoon")
  @HiveField(4)
  tablespoon
}
