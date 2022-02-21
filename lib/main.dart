
import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/suggestions_mongodb.dart';
import 'package:easy_shopping_list/meal_list.dart';
import 'package:easy_shopping_list/options_list.dart';
import 'package:easy_shopping_list/shopping_list/add_article.dart';
import 'package:easy_shopping_list/shopping_list/shopping_list.dart';
import "package:flutter/material.dart";
import 'package:hive_flutter/adapters.dart';

import 'shopping_list/article.dart';

void main() async {
  await _initHive();
  MongoDBAccess.syncArticleSuggestions();
  runApp(const MyApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  // Shopping list
  Hive.registerAdapter(ArticleAdapter());
  Hive.registerAdapter(QuantityUnitAdapter());
  await Hive.openBox<Article>("ShoppingList");
  // await Hive.openBox<Article>("ShoppingList")
  //     .then((value) async => await value.clear());

  // Suggestions
  await Hive.openBox("Suggestions");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Easy shopping list",
      home: AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ShoppingList(),
    MealList(),
    OptionsList()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: _widgetOptions,
        index: _selectedIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Einkauf"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Gerichte"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "")
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_widgetOptions[_selectedIndex].runtimeType == ShoppingList) {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return AddArticleBottomSheet();
                }).then((newArticle) {
              setState(() {
                ShoppingListHive().addArticle(newArticle);
              });
            });
          } else {}
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
