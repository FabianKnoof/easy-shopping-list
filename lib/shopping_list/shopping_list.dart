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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: _shoppingListHive.shoppingListBox.listenable(),
        builder: (context, box, widget) {
          return ReorderableListView(
            children: _buildArticleListTile(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                _shoppingListHive.reorderArticle(oldIndex, newIndex);
              });
            },
          );
        });
  }

  List<Widget> _buildArticleListTile() {
    List<Widget> articleListTiles = [];
    for (int indexKey = 0;
        indexKey < _shoppingListHive.shoppingListBox.length;
        ++indexKey) {
      Article article = _shoppingListHive.shoppingListBox.get(indexKey)!;
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
        title: Row(
          children: [
            CheckboxWidget(),
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
        ),
      ));
    }
    return articleListTiles;
  }
}

class CheckboxWidget extends StatefulWidget {
  const CheckboxWidget({Key? key}) : super(key: key);

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
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
      onChanged: (bool? value) {
        setState(() {
          _isChecked = value!;
        });
      },
    );
  }
}
