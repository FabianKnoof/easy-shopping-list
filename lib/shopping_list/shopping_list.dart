import 'package:easy_shopping_list/db_accesses/checked_lists_hive.dart';
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

  final ShoppingListHive _shoppingListHive = ShoppingListHive();
  final ShoppingListCheckedHive _shoppingListCheckedHive =
      ShoppingListCheckedHive();

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
      valueListenable: _shoppingListCheckedHive.box.listenable(),
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
                    trailing: Text("(${_shoppingListCheckedHive.box.length})"),
                  );
                },
                body: ListView(
                  shrinkWrap: true,
                  children: [
                    for (int indexKey in _shoppingListCheckedHive.box.keys)
                      ListTile(
                        key: Key(indexKey.toString()),
                        title: _article(indexKey,
                            _shoppingListCheckedHive.box.get(indexKey)!),
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
        valueListenable: _shoppingListHive.box.listenable(),
        builder: (context, box, widget) {
          return ReorderableListView(
            children: _buildArticleListTile(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                _shoppingListHive.reorderArticleAt(oldIndex, newIndex);
              });
            },
          );
        });
  }

  List<Widget> _buildArticleListTile() {
    List<Widget> articleListTiles = [];
    for (int indexKey = 0;
        indexKey < _shoppingListHive.box.length;
        ++indexKey) {
      Article article = _shoppingListHive.box.get(indexKey)!;
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
            _shoppingListHive.replaceArticleAt(indexKey, newArticle);
          });
        },
        title: _article(indexKey, article),
      ));
    }
    return articleListTiles;
  }

  Row _article(int indexKey, Article article) {
    return Row(
      children: [
        CheckboxWidget(
          indexKey: indexKey,
          article: article,
        ),
        Text(article.name),
        SizedBox(
          width: _padding,
        ),
        Text(article.quantity.toString()),
        Text(Article.quantityUnitToString(article.quantityUnit)),
        SizedBox(
          width: _padding,
        ),
        Text(article.details)
      ],
    );
  }
}

class CheckboxWidget extends StatefulWidget {
  const CheckboxWidget(
      {Key? key, required this.indexKey, required this.article})
      : super(key: key);
  final int indexKey;
  final Article article;

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    bool _isChecked = !(ShoppingListHive().box.containsKey(widget.indexKey) &&
        ShoppingListHive().box.get(widget.indexKey) == widget.article);

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: _isChecked,
      onChanged: (bool? value) async {
        if (value!) {
          await ShoppingListCheckedHive()
              .checkArticle(widget.indexKey)
              .then((indexKey) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Abgehakt"),
              action: SnackBarAction(
                label: "Rückgängig",
                onPressed: () {
                  ShoppingListCheckedHive().uncheckArticle(indexKey);
                },
              ),
            ));
          });
        } else {
          ShoppingListCheckedHive().uncheckArticle(widget.indexKey);
        }
        setState(() {});
      },
    );
  }
}
