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

class _ShoppingListState extends State<ShoppingList> with buildTemplates {
  @override
  Widget build(BuildContext context) {
    // Note needs testing and maybe different solution to shrinkWrap
    return ListView(
      shrinkWrap: true,
      children: [_buildShoppingList(), _buildShoppingListChecked()],
    );
  }

  ValueListenableBuilder<Box<Article>> _buildShoppingListChecked() {
    return ValueListenableBuilder(
      valueListenable: ShoppingListHive().shoppingListBox.listenable(),
      builder: (context, value, child) {
        return ExpansionTile(
          leading: Icon(Icons.checklist),
          title: Text(
              "Abgehakt (${ShoppingListHive().shoppingListCheckedBox.length})"),
          children: [
            for (Article article
                in ShoppingListHive().shoppingListCheckedBox.values)
              ListTile(
                leading: _buildCheckbox(article),
                title: articleColumn(article),
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
            children: _buildArticleListTile(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                ShoppingListHive().reorderArticleAt(oldIndex, newIndex);
              });
            },
          );
        });
  }

  List<Widget> _buildArticleListTile() {
    // Todo / Note Use separate ingredients hive which is in sync with ingredients of cooking list and shopping list
    List<Widget> articleListTiles = [];
    for (int indexKey = 0;
        indexKey < ShoppingListHive().shoppingListBox.length;
        ++indexKey) {
      Article article = ShoppingListHive().shoppingListBox.get(indexKey)!;
      articleListTiles.add(ListTile(
        key: Key(indexKey.toString()),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return AddArticleBottomSheet(
                article: article,
              );
            },
          ).then((newArticle) {
            ShoppingListHive().replaceArticleAt(indexKey, newArticle);
          });
        },
        leading: _buildCheckbox(article),
        title: articleColumn(article),
      ));
    }
    return articleListTiles;
  }

  Checkbox _buildCheckbox(Article article) {
    return Checkbox(
      value: (article.box == ShoppingListHive().shoppingListCheckedBox),
      onChanged: (value) {
        if (value!) {
          ShoppingListHive().checkArticle(article);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Abgehakt"),
            action: SnackBarAction(
              label: "Rückgängig",
              onPressed: () {
                ShoppingListHive().uncheckArticle(article);
              },
            ),
          ));
        } else {
          ShoppingListHive().uncheckArticle(article);
        }
      },
    );
  }
}
