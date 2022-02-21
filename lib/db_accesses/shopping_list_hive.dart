import 'dart:developer' as dev;

import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive/hive.dart';

class ShoppingListHive {
  static final ShoppingListHive _shoppingListHive =
      ShoppingListHive._internal();

  final shoppingListBox = Hive.box<Article>(
    "ShoppingList",
  );

  factory ShoppingListHive() {
    return _shoppingListHive;
  }

  ShoppingListHive._internal();

  void addArticle(Article? newArticle) {
    if (newArticle == null) return;
    for (Article article in shoppingListBox.values) {
      if (article.name == newArticle.name &&
          article.quantityUnit == newArticle.quantityUnit) {
        article.quantity += newArticle.quantity;
        return;
      }
    }
    shoppingListBox.put(shoppingListBox.length, newArticle);
  }

  void replaceArticleAt(int indexKey, Article article) {
    shoppingListBox.put(indexKey, article);
  }

  void reorderArticle(int oldIndex, int newIndex) {
    Article reorderedArticle = shoppingListBox.get(oldIndex)!;
    if (oldIndex < newIndex) {
      --newIndex;
      for (int indexKey = oldIndex; indexKey < newIndex; ++indexKey) {
        Article nextArticle = shoppingListBox.get(indexKey + 1)!;
        shoppingListBox.delete(indexKey + 1);
        shoppingListBox.put(indexKey, nextArticle);
      }
      shoppingListBox.put(newIndex, reorderedArticle);
    } else {
      dev.log("$oldIndex > $newIndex");
      for (int indexKey = oldIndex; indexKey > newIndex; --indexKey) {
        dev.log("$indexKey");
        Article nextArticle = shoppingListBox.get(indexKey - 1)!;
        shoppingListBox.delete(indexKey - 1);
        shoppingListBox.put(indexKey, nextArticle);
      }
      shoppingListBox.put(newIndex, reorderedArticle);
    }
  }
}
