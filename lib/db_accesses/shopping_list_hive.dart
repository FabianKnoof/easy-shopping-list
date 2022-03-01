import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive/hive.dart';

class ShoppingListHive {
  static final ShoppingListHive _shoppingListHive =
      ShoppingListHive._internal();

  factory ShoppingListHive() {
    return _shoppingListHive;
  }

  ShoppingListHive._internal();

  static final String boxName = "ShoppingList";

  final Box<Article> box = Hive.box<Article>(boxName);

  void addArticle(Article? newArticle) {
    if (newArticle == null) return;
    for (Article article in box.values) {
      if (article.name == newArticle.name &&
          article.quantityUnit == newArticle.quantityUnit) {
        article.quantity += newArticle.quantity;
        return;
      }
    }
    box.put(box.length, newArticle);
  }

  void addArticles(List<Article> newArticles) {
    for (Article newArticle in newArticles) {
      addArticle(newArticle);
    }
  }

  void replaceArticleAt(int? indexKey, Article? article) {
    if (indexKey == null || article == null) return;
    box.put(indexKey, article);
  }

  void reorderArticleAt(int oldIndex, int newIndex) {
    Article reorderedArticle = box.get(oldIndex)!;
    if (oldIndex < newIndex) {
      --newIndex;
      for (int indexKey = oldIndex; indexKey < newIndex; ++indexKey) {
        Article nextArticle = box.get(indexKey + 1)!;
        box.delete(indexKey + 1);
        box.put(indexKey, nextArticle);
      }
      box.put(newIndex, reorderedArticle);
    } else {
      for (int indexKey = oldIndex; indexKey > newIndex; --indexKey) {
        Article nextArticle = box.get(indexKey - 1)!;
        box.delete(indexKey - 1);
        box.put(indexKey, nextArticle);
      }
      box.put(newIndex, reorderedArticle);
    }
  }

  void removeArticleAt(int indexKey) {
    Map<dynamic, Article> articleMap = {};
    for (int i = indexKey; i < box.length - 1; ++i) {
      articleMap[i] = box.get(i + 1)!;
    }
    box.deleteAll([for (int i = indexKey; i < box.length; ++i) i]);
    box.putAll(articleMap);
  }

  void removeArticle(Article article) {
    removeArticleAt(article.key);
  }
}

class ShoppingListCheckedHive {
  static final ShoppingListCheckedHive _shoppingListCheckedHive =
      ShoppingListCheckedHive._internal();

  factory ShoppingListCheckedHive() {
    return _shoppingListCheckedHive;
  }

  ShoppingListCheckedHive._internal();

  static final String boxName = "ShoppingListChecked";

  final Box<Article> box = Hive.box<Article>(boxName);

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
