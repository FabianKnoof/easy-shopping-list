
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

  void checkArticle(int indexKey) {
    Article article = _shoppingListHive.box.get(indexKey)!;
    _shoppingListHive.removeArticleAt(indexKey).whenComplete(() {
      box.add(article);
    });
  }

  void uncheckArticle(int indexKey) {
    Article article = box.get(indexKey)!;
    article.delete().whenComplete(() => _shoppingListHive.addArticle(article));
  }
}
