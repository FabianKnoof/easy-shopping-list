import 'package:easy_shopping_list/db_accesses/cooking_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/db_accesses/suggestions_mongodb.dart';
import 'package:easy_shopping_list/meal_list/add_meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';

class OptionsView extends StatefulWidget {
  const OptionsView({Key? key}) : super(key: key);

  @override
  _OptionsViewState createState() => _OptionsViewState();
}

class _OptionsViewState extends State<OptionsView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Card(
          child: ListTile(
            title: Text("Eigene Gerichte einsehen"),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Eigene Artikel einsehen"),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Abgehakt Listen leeren"),
            onTap: () {
              _clearCheckedListsAction(context);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Artikel vorschlagen"),
            onTap: () async {
              await _userArticleSuggestionAction(context);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Gericht vorschlagen"),
            onTap: () async {
              await _userMealSuggestionAction(context);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Lokalen Speicher leeren"),
            onTap: () async {
              await _clearAllHives(context);
            },
          ),
        )
      ],
    );
  }

  void _clearCheckedListsAction(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Abgehakte Einkaufs- und Kochliste leeren?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text("Nein")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text("Ja"))
          ],
        );
      },
    ).then((userAnswer) {
      if (userAnswer) {
        ShoppingListHive().shoppingListCheckedBox.clear();
        CookingListHive().cookingListCheckedBox.clear();
      }
    });
  }

  Future<void> _userMealSuggestionAction(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return EditMealView();
      },
    )).then((meal) {
      if (meal == null) return;
      _getUserAnswer(context, "${meal.name} als Vorschlag absenden?")
          .then((userAnswer) async {
        if (userAnswer) {
          if (!await SuggestionsMongoDB.insertUserMealSuggestion(meal)) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Gericht ist bereits als Vorschlag eingeangen"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Ok"))
                  ],
                );
              },
            );
          }
        }
      });
    });
  }

  Future<void> _userArticleSuggestionAction(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ArticleSuggestion();
      },
    ).then((article) {
      if (article == null) return;
      _getUserAnswer(context, "${article.name} als Vorschlag absenden?")
          .then((userAnswer) async {
        if (userAnswer) {
          if (!await SuggestionsMongoDB.insertUserArticleSuggestion(article)) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Artikel ist bereits als Vorschlag eingegangen"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Ok"))
                  ],
                );
              },
            );
          }
        }
      });
    });
  }

  _clearAllHives(BuildContext context) {
    _getUserAnswer(context, "Alle Listen leeren?").then((userAnswer) {
      if (userAnswer) {
        ShoppingListHive().shoppingListBox.clear();
        ShoppingListHive().shoppingListCheckedBox.clear();

        CookingListHive().cookingListBox.clear();
        CookingListHive().cookingListCheckedBox.clear();

        VersionsSuggestionsHive().box.clear();
        ArticleSuggestionsHive().box.clear();
        MealSuggestionsHive().box.clear();
      }
    });
  }

  Future<dynamic> _getUserAnswer(BuildContext context, String question) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(question),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text("Nein")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text("Ja"))
          ],
        );
      },
    );
  }
}

class ArticleSuggestion extends StatefulWidget {
  const ArticleSuggestion({Key? key}) : super(key: key);

  @override
  _ArticleSuggestionState createState() => _ArticleSuggestionState();
}

class _ArticleSuggestionState extends State<ArticleSuggestion> {
  final double _padding = 5;
  final GlobalKey<FormState> _articleSuggestionFormKey = GlobalKey<FormState>();

  final Article _articleSuggestion = Article();

  void _submitForm() {
    FormState? formState = _articleSuggestionFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      Navigator.pop(context, _articleSuggestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _articleSuggestionFormKey,
        child: Column(
          children: [
            SizedBox(
              height: _padding,
            ),
            Padding(
              padding: EdgeInsets.all(_padding),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLines: 1,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Artikel"),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Artikel eingeben";
                        }
                        if (ArticleSuggestionsHive().box.values.any((article) =>
                            article.name.toLowerCase() ==
                            value.toLowerCase())) {
                          return "Artikel bereits vorhanden";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _articleSuggestion.name = newValue!;
                      },
                    ),
                  ),
                  SizedBox(
                    width: _padding,
                  ),
                  ElevatedButton(
                      onPressed: () => _submitForm(), child: Icon(Icons.check))
                ],
              ),
            ),
            SizedBox(
              height: _padding,
            ),
            Padding(
              padding: EdgeInsets.all(_padding),
              child: Row(
                children: [
                  Text("Ist eine Zutat"),
                  SizedBox(
                    width: _padding,
                  ),
                  Switch(
                    value: _articleSuggestion.isIngredient,
                    onChanged: (value) {
                      setState(() {
                        _articleSuggestion.isIngredient =
                            !_articleSuggestion.isIngredient;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
