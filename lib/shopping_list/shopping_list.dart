import 'package:easy_shopping_list/db_accesses/list_sharing.dart';
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

class _ShoppingListState extends State<ShoppingList> with ViewTemplates {
  @override
  Widget build(BuildContext context) {
    if (ListSharingHive().isSharing()) {
      return RefreshIndicator(
        onRefresh: () async {
          if (await ListSharingMongoDB().hasConnection()) {
            return ListSharingHive().pullUpdates();
          } else {
            queryUser(
                context: context,
                question: "Keine Verbindung zur Datenbank",
                positiveAnswer: "Ok");
          }
        },
        child: ListView(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          children: [_buildShoppingList(), _buildShoppingListChecked()],
        ),
      );
    } else {
      return ListView(
        shrinkWrap: true,
        children: [_buildShoppingList(), _buildShoppingListChecked()],
      );
    }
  }

  ValueListenableBuilder<Box<ArticleEntry>> _buildShoppingListChecked() {
    return ValueListenableBuilder(
      valueListenable: ShoppingListHive().shoppingListCheckedBox.listenable(),
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
          if (ListSharingHive().isSharing()) ListSharingHive().pushUpdates();
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
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return AddArticleBottomSheet(
                article: articleEntry.getAsArticle(),
              );
            },
          ).then((newArticle) {
            if (newArticle is Article) {
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
