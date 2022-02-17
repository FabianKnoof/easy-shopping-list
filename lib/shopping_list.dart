import 'package:easy_shopping_list/article.dart';
import 'package:flutter/material.dart';

import 'add_article.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<Article> articleList = <Article>[];

  void addToArticleList(Article newArticle) {
    for (Article article in articleList.where((articleInList) =>
        articleInList.name == newArticle.name &&
        articleInList.quantityUnit == newArticle.quantityUnit)) {
      article.quantity += newArticle.quantity;
      return;
    }
    articleList.add(newArticle);
  }

  List<DataRow> getArticleRows() {
    return <DataRow>[
      for (Article article in articleList)
        (DataRow(
            onLongPress: () {
              articleList.remove(article);
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return AddItemBottomSheet(
                      article: article,
                    );
                  }).then((value) {
                setState(() {
                  addToArticleList(value);
                });
              });
            },
            cells: <DataCell>[
              DataCell(CheckboxWidget()),
              DataCell(Text(article.name)),
              // Todo don't display quantity and quantityUnit if no quantity is given
              DataCell(Text(article.quantity.toString())),
              DataCell(
                  Text(Article.quantityUnitToString(article.quantityUnit))),
              DataCell(Text(article.details))
            ]))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: DataTable(
            columnSpacing: 5,
            columns: const <DataColumn>[
              DataColumn(label: Text("")),
              DataColumn(label: Text("Artikel")),
              DataColumn(label: Text("Menge")),
              DataColumn(label: Text("")),
              DataColumn(label: Text("Details")),
            ],
            rows: getArticleRows()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              // Todo on exit of bottom sheet

              context: context,
              builder: (BuildContext context) {
                return AddItemBottomSheet();
              }).then((value) {
            setState(() {
              if (value != null) {
                addToArticleList(value);
              }
            });
          });

          // AddItemStepper
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => const AddItemView()));
        },
        child: const Icon(Icons.add),
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
  bool isChecked = false;

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
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}
