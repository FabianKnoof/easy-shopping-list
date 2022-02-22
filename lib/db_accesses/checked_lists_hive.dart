import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ShoppingListCheckedHive {
  static final ShoppingListCheckedHive _shoppingListCheckedHive =
      ShoppingListCheckedHive._internal();

  factory ShoppingListCheckedHive() {
    return _shoppingListCheckedHive;
  }

  ShoppingListCheckedHive._internal();

  final Box<Article> box = Hive.box<Article>(
    "ShoppingListChecked",
  );

  final ShoppingListHive _shoppingListHive = ShoppingListHive();

  void checkArticle(Article article) {
    ShoppingListHive().removeArticle(article);
    box.add(article);
  }

  void uncheckArticle(Article article) {
    article.delete();
    _shoppingListHive.addArticle(article);
  }
}
