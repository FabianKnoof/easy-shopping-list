
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

  final Box<ArticleEntry> shoppingListBox =
      Hive.box<ArticleEntry>(shoppingListBoxName);

  static final String shoppingListCheckedBoxName = "ShoppingListChecked";

  final Box<ArticleEntry> shoppingListCheckedBox =
      Hive.box<ArticleEntry>(shoppingListCheckedBoxName);

  void addArticle(Article? newArticle) {
    if (newArticle == null) return;
    for (ArticleEntry articleEntry in shoppingListBox.values) {
      if (articleEntry.name == newArticle.name &&
          articleEntry.quantityUnit == newArticle.quantityUnit) {
        articleEntry.addArticle(newArticle);
        return;
      }
    }
    shoppingListBox.put(
        shoppingListBox.length,
        ArticleEntry(newArticle.name, newArticle.quantity,
            newArticle.quantityUnit, newArticle.details, [newArticle]));
  }

  void addArticles(List<Article> newArticles) {
    for (Article newArticle in newArticles) {
      addArticle(newArticle);
    }
  }

  void replaceArticleEntryAt(int? indexKey, ArticleEntry? articleEntry) {
    if (indexKey == null || articleEntry == null) return;
    shoppingListBox.put(indexKey, articleEntry);
  }

  void reorderArticleEntryAt(int oldIndex, int newIndex) {
    ArticleEntry reorderedArticleEntry = shoppingListBox.get(oldIndex)!;
    if (oldIndex < newIndex) {
      --newIndex;
      for (int indexKey = oldIndex; indexKey < newIndex; ++indexKey) {
        ArticleEntry nextArticleEntry = shoppingListBox.get(indexKey + 1)!;
        shoppingListBox.delete(indexKey + 1);
        shoppingListBox.put(indexKey, nextArticleEntry);
      }
      shoppingListBox.put(newIndex, reorderedArticleEntry);
    } else {
      for (int indexKey = oldIndex; indexKey > newIndex; --indexKey) {
        ArticleEntry nextArticleEntry = shoppingListBox.get(indexKey - 1)!;
        shoppingListBox.delete(indexKey - 1);
        shoppingListBox.put(indexKey, nextArticleEntry);
      }
      shoppingListBox.put(newIndex, reorderedArticleEntry);
    }
  }

  void removeArticleEntryAt(int indexKey) {
    Map<dynamic, ArticleEntry> articleEntryMap = {};
    for (int i = indexKey; i < shoppingListBox.length - 1; ++i) {
      articleEntryMap[i] = shoppingListBox.get(i + 1)!;
    }
    shoppingListBox
        .deleteAll([for (int i = indexKey; i < shoppingListBox.length; ++i) i]);
    shoppingListBox.putAll(articleEntryMap);
  }

  void removeArticleEntry(ArticleEntry articleEntry) {
    removeArticleEntryAt(articleEntry.key);
  }

  void checkArticleEntry(ArticleEntry articleEntry) {
    removeArticleEntry(articleEntry);
    shoppingListCheckedBox.add(articleEntry);
  }

  void uncheckArticleEntry(ArticleEntry articleEntry) {
    articleEntry.delete();
    addArticles(articleEntry.articles);
  }

// void checkIngredient(Article ingredient) {
//   for (Article article in shoppingListBox.values) {
//     if (article.name == ingredient.name &&
//         article.quantityUnit == ingredient.quantityUnit) {
//       log("${article.quantity == ingredient.quantity}");
//       if (article.quantity == ingredient.quantity) {
//         checkArticleEntry(article);
//       } else {
//         article.quantity -= ingredient.quantity;
//         article.save();
//       }
//       return;
//     }
//   }
// }
//
// void uncheckIngredient(Article ingredient) {
//   for (Article ingredient in shoppingListBox.values) {
//     log(ingredient.toString());
//   }
// }
}
