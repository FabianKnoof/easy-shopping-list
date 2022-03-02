import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/general_use_functions.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'add_article.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> with BuildTemplates {
  @override
  Widget build(BuildContext context) {
    // Note needs testing and maybe different solution to shrinkWrap
    return ListView(
      shrinkWrap: true,
      children: [_buildShoppingList(), _buildShoppingListChecked()],
    );
  }

  ValueListenableBuilder<Box<ArticleEntry>> _buildShoppingListChecked() {
    return ValueListenableBuilder(
      valueListenable: ShoppingListHive().shoppingListBox.listenable(),
      builder: (context, value, child) {
        return ExpansionTile(
          leading: Icon(Icons.checklist),
          title: Text(
              "Abgehakt (${ShoppingListHive().shoppingListCheckedBox.length})"),
          children: [
            for (ArticleEntry articleEntry
                in ShoppingListHive().shoppingListCheckedBox.values)
              ListTile(
                leading: _buildCheckbox(articleEntry),
                title: articleColumn(articleEntry.getAsArticle()),
              )
          ].reversed.toList(),
        );
      },
    );
  }

  ValueListenableBuilder<Box<dynamic>> _buildShoppingList() {
    return ValueListenableBuilder<Box>(
        valueListenable: ShoppingListHive().shoppingListBox.listenable(),
        builder: (context, box, widget) {
          return ReorderableListView(
            reverse: true,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: _buildArticleEntryListTile(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                ShoppingListHive().reorderArticleEntryAt(oldIndex, newIndex);
              });
            },
          );
        });
  }

  List<Widget> _buildArticleEntryListTile() {
    // Todo / Note Use separate ingredients hive which is in sync with ingredients of cooking list and shopping list
    List<Widget> articleEntryListTiles = [];
    for (int indexKey = 0;
        indexKey < ShoppingListHive().shoppingListBox.length;
        ++indexKey) {
      ArticleEntry articleEntry =
          ShoppingListHive().shoppingListBox.get(indexKey)!;
      articleEntryListTiles.add(ListTile(
        key: Key(indexKey.toString()),
        leading: _buildCheckbox(articleEntry),
        title: articleColumn(articleEntry.getAsArticle()),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return AddArticleBottomSheet(
                article: articleEntry.getAsArticle(),
              );
            },
          ).then((newArticle) {
            if (newArticle.runtimeType == Article) {
              newArticle as Article;
              ShoppingListHive().replaceArticleEntryAt(
                  indexKey,
                  ArticleEntry(
                      newArticle.name,
                      newArticle.quantity,
                      newArticle.quantityUnit,
                      newArticle.details,
                      [newArticle]));
            }
          });
        },
      ));
    }
    return articleEntryListTiles;
  }

  Checkbox _buildCheckbox(ArticleEntry articleEntry) {
    return Checkbox(
      value: (articleEntry.box == ShoppingListHive().shoppingListCheckedBox),
      onChanged: (value) {
        if (value!) {
          ShoppingListHive().checkArticleEntry(articleEntry);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Abgehakt"),
            action: SnackBarAction(
              label: "Rückgängig",
              onPressed: () {
                ShoppingListHive().uncheckArticleEntry(articleEntry);
              },
            ),
          ));
        } else {
          ShoppingListHive().uncheckArticleEntry(articleEntry);
        }
      },
    );
  }
}
