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

  Future<int> checkArticle(int indexKey) async {
    Article article = _shoppingListHive.box.get(indexKey)!;
    return await _shoppingListHive.removeArticleAt(indexKey).then((value) {
      return box.add(article).then((value) {
        return value;
      });
    });
  }

  void uncheckArticle(int indexKey) {
    Article article = box.get(indexKey)!;
    article.delete().whenComplete(() => _shoppingListHive.addArticle(article));
  }
}
