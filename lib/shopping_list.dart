import 'dart:developer';

import 'package:easy_shopping_list/article.dart';
import 'package:flutter/material.dart';

import 'add_article.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final double _padding = 5;

  final List<Article> _articleList =
      List.generate(5, (index) => Article()..name = "Artikel $index");

  void _addToArticleList(Article? newArticle) {
    if (newArticle == null) return;
    for (Article article in _articleList) {
      if (article.name == newArticle.name &&
          article.quantityUnit == newArticle.quantityUnit) {
        article.quantity += newArticle.quantity;
        return;
      }
    }
    _articleList.add(newArticle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildShoppingList(),
      floatingActionButton: _buildAddArticleFloatingButton(context),
    );
  }

  FloatingActionButton _buildAddArticleFloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return AddArticleBottomSheet();
            }).then((value) {
          setState(() {
            _addToArticleList(value);
          });
        });
      },
      child: const Icon(Icons.add),
    );
  }

  ReorderableListView _buildShoppingList() {
    return ReorderableListView(
      children: <Widget>[
        for (int index = 0; index < _articleList.length; ++index)
          _buildArticleListTile(index)
      ],
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          _articleList.insert(newIndex, _articleList.removeAt(oldIndex));
        });
      },
    );
  }

  ListTile _buildArticleListTile(int index) {
    Article article = _articleList[index];
    return ListTile(
      key: Key(index.toString()),
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return AddArticleBottomSheet();
            }).then((value) {
          setState(() {
            _addToArticleList(value);
          });
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
    );
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
