import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
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

  bool _checkedShoppingListExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildShoppingListChecked(),
        Expanded(
          child: _buildShoppingList(),
        ),
      ],
    );
  }

  ValueListenableBuilder<Box<Article>> _buildShoppingListChecked() {
    return ValueListenableBuilder(
      valueListenable: ShoppingListCheckedHive().box.listenable(),
      builder: (context, value, child) {
        return ExpansionPanelList(
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              _checkedShoppingListExpanded = !_checkedShoppingListExpanded;
            });
          },
          children: [
            ExpansionPanel(
                isExpanded: _checkedShoppingListExpanded,
                canTapOnHeader: true,
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text("Abgehakt"),
                    leading: Icon(Icons.checklist),
                    trailing: Text("(${ShoppingListCheckedHive().box.length})"),
                  );
                },
                body: ListView(
                  shrinkWrap: true,
                  children: [
                    for (int indexKey in ShoppingListCheckedHive().box.keys)
                      ListTile(
                        key: Key(indexKey.toString()),
                        title: _article(
                            ShoppingListCheckedHive().box.get(indexKey)!),
                      )
                  ].toList(),
                ))
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
        title: _article(article),
      ));
    }
    return articleListTiles;
  }

  Row _article(Article article) {
    return Row(
      children: [
        Checkbox(
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
        ),
        Text(article.name),
        SizedBox(
          width: _padding,
        ),
        Text(article.quantity.toString()),
        Text(article.quantityUnitAsString()),
        SizedBox(
          width: _padding,
        ),
        Text(article.details)
      ],
    );
  }
}
