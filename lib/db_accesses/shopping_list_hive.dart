import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive/hive.dart';

class ShoppingListHive {
  static final ShoppingListHive _shoppingListHive =
      ShoppingListHive._internal();

  factory ShoppingListHive() {
    return _shoppingListHive;
  }

  ShoppingListHive._internal();

  static final String shoppingListBoxName = "ShoppingList";

  final Box<Article> shoppingListBox = Hive.box<Article>(shoppingListBoxName);

  static final String shoppingListCheckedBoxName = "ShoppingListChecked";

  final Box<Article> shoppingListCheckedBox =
      Hive.box<Article>(shoppingListCheckedBoxName);

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

  void addArticles(List<Article> newArticles) {
    for (Article newArticle in newArticles) {
      addArticle(newArticle);
    }
  }

  void replaceArticleAt(int? indexKey, Article? article) {
    if (indexKey == null || article == null) return;
    shoppingListBox.put(indexKey, article);
  }

  void reorderArticleAt(int oldIndex, int newIndex) {
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
      for (int indexKey = oldIndex; indexKey > newIndex; --indexKey) {
        Article nextArticle = shoppingListBox.get(indexKey - 1)!;
        shoppingListBox.delete(indexKey - 1);
        shoppingListBox.put(indexKey, nextArticle);
      }
      shoppingListBox.put(newIndex, reorderedArticle);
    }
  }

  void removeArticleAt(int indexKey) {
    Map<dynamic, Article> articleMap = {};
    for (int i = indexKey; i < shoppingListBox.length - 1; ++i) {
      articleMap[i] = shoppingListBox.get(i + 1)!;
    }
    shoppingListBox
        .deleteAll([for (int i = indexKey; i < shoppingListBox.length; ++i) i]);
    shoppingListBox.putAll(articleMap);
  }

  void removeArticle(Article article) {
    removeArticleAt(article.key);
  }

  void checkArticle(Article article) {
    removeArticle(article);
    shoppingListCheckedBox.add(article);
  }

  void uncheckArticle(Article article) {
    article.delete();
    addArticle(article);
  }
}
