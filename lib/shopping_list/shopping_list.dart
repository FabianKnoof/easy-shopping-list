import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'add_article.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final double _padding = 5;

  @override
  Widget build(BuildContext context) {
    // Note needs testing and maybe different solution to shrinkWrap
    return ListView(
      shrinkWrap: true,
      children: [_buildShoppingListChecked(), _buildShoppingList()],
    );
  }

  ValueListenableBuilder<Box<Article>> _buildShoppingListChecked() {
    return ValueListenableBuilder(
      valueListenable: ShoppingListCheckedHive().box.listenable(),
      builder: (context, value, child) {
        return ExpansionTile(
          leading: Icon(Icons.checklist),
          title: Text("Abgehakt (${ShoppingListCheckedHive().box.length})"),
          children: [
            for (Article article in ShoppingListCheckedHive().box.values)
              ListTile(
                leading: _buildCheckbox(article),
                title: _article(article),
              )
          ],
        );
      },
    );
  }

  ValueListenableBuilder<Box<dynamic>> _buildShoppingList() {
    return ValueListenableBuilder<Box>(
        valueListenable: ShoppingListHive().box.listenable(),
        builder: (context, box, widget) {
          return ReorderableListView(
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
        indexKey < ShoppingListHive().box.length;
        ++indexKey) {
      Article article = ShoppingListHive().box.get(indexKey)!;
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
        title: _article(article),
      ));
    }
    return articleListTiles;
  }

  Checkbox _buildCheckbox(Article article) {
    return Checkbox(
      value: (article.box == ShoppingListCheckedHive().box),
      onChanged: (value) {
        if (value!) {
          ShoppingListCheckedHive().checkArticle(article);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Abgehakt"),
            action: SnackBarAction(
              label: "Rückgängig",
              onPressed: () {
                ShoppingListCheckedHive().uncheckArticle(article);
              },
            ),
          ));
        } else {
          ShoppingListCheckedHive().uncheckArticle(article);
        }
      },
    );
  }

  Column _article(Article article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                article.name,
              ),
            ),
            if (article.quantity != 0) ...[
              SizedBox(
                width: _padding,
              ),
              Text(article.quantity.toString()),
              Text(article.quantityUnitAsString()),
              Text(article.details)
            ]
          ],
        ),
        if (article.details.isNotEmpty)
          Text(
            article.details,
          )
      ],
    );
  }
}
