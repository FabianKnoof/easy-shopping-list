import 'package:easy_shopping_list/db_accesses/cooking_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/meal_list/add_meal.dart';
import 'package:easy_shopping_list/meal_list/cooking_list.dart';
import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/options/options_view.dart';
import 'package:easy_shopping_list/shopping_list/add_article.dart';
import 'package:easy_shopping_list/shopping_list/shopping_list.dart';
import "package:flutter/material.dart";
import 'package:hive_flutter/adapters.dart';

import 'shopping_list/article.dart';

void main() async {
  await _initHive();
  // MongoDBAccess.syncArticleSuggestions();
  // Todo MongoDBAccess meal suggestions
  runApp(const MyApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(ArticleAdapter());
  Hive.registerAdapter(QuantityUnitAdapter());
  Hive.registerAdapter(MealAdapter());

  await Hive.openBox<Article>(ShoppingListHive.boxName);
  await Hive.openBox<Article>(ShoppingListCheckedHive.boxName);

  await Hive.openBox<Meal>(CookingListHive.boxName);
  await Hive.openBox<Meal>(CookingListCheckedHive.boxName);

  await Hive.openBox<int>(VersionsSuggestionsHive.boxName);
  await Hive.openBox<Article>(ArticleSuggestionsHive.boxName);
  await Hive.openBox<Meal>(MealSuggestionsHive.boxName);
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
    CookingList(),
    OptionsView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Easy Shopping List"),
      ),
      body: IndexedStack(
        children: _widgetOptions,
        index: _selectedIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Einkauf"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Kochen"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "")
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex != 2
          ? FloatingActionButton(
              onPressed: () {
                if (_widgetOptions[_selectedIndex].runtimeType ==
                    ShoppingList) {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return AddArticleBottomSheet();
                      }).then((newArticle) {
                    setState(() {
                      ShoppingListHive().addArticle(newArticle);
                    });
                  });
                } else if (_widgetOptions[_selectedIndex].runtimeType ==
                    CookingList) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMealView(),
                      )).then((newMeal) => CookingListHive().addMeal(newMeal));
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
