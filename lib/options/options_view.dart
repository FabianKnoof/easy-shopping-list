import 'package:easy_shopping_list/db_accesses/cooking_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/list_sharing.dart';
import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/db_accesses/suggestions_mongodb.dart';
import 'package:easy_shopping_list/general_use_functions.dart';
import 'package:easy_shopping_list/meal_list/add_meal.dart';
import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OptionsView extends StatefulWidget {
  const OptionsView({Key? key}) : super(key: key);

  @override
  _OptionsViewState createState() => _OptionsViewState();
}

class _OptionsViewState extends State<OptionsView> with ViewTemplates {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Card(
          child: ListTile(
            title: Text("Eigene Gerichte einsehen"),
            onTap: () {
              _showUserCreatedMeals();
            },
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
            title: Text("Einkaufsliste mit anderen teilen"),
            onTap: () {
              _shareShoppingList(context);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Einkaufliste teilen zurücksetzten"),
            onTap: () {
              _resetListSharing(context);
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
    queryUser(
            context: context,
            question: "Abgehakte Einkaufs- und Kochliste leeren?",
            positiveAnswer: "Ja",
            negativeAnswer: "Nein")
        .then((userAnswer) {
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
      queryUser(
              context: context,
              question: "${meal.name} als Vorschlag absenden?",
              positiveAnswer: "Ja",
              negativeAnswer: "Nein")
          .then((userAnswer) async {
        if (userAnswer) {
          if (!await SuggestionsMongoDB.insertUserMealSuggestion(meal)) {
            queryUser(
                context: context,
                question: "Gericht ist bereits als Vorschlag eingeangen",
                positiveAnswer: "Ok");
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
      queryUser(
              context: context,
              question: "${article.name} als Vorschlag absenden?",
              positiveAnswer: "Ja",
              negativeAnswer: "Nein")
          .then((userAnswer) async {
        if (userAnswer) {
          if (!await SuggestionsMongoDB.insertUserArticleSuggestion(article)) {
            queryUser(
                context: context,
                question: "Artikel ist bereits als Vorschlag eingegangen",
                positiveAnswer: "Ok");
          }
        }
      });
    });
  }

  _clearAllHives(BuildContext context) {
    queryUser(
            context: context,
            question: "Alle Listen leeren?",
            positiveAnswer: "Ja",
            negativeAnswer: "Nein")
        .then((userAnswer) {
      if (userAnswer) {
        ShoppingListHive().shoppingListBox.clear();
        ShoppingListHive().shoppingListCheckedBox.clear();

        CookingListHive().cookingListBox.clear();
        CookingListHive().cookingListCheckedBox.clear();

        SuggestionsHive().versionsBox.clear();
        SuggestionsHive().articleBox.clear();
        SuggestionsHive().mealBox.clear();

        ListSharingHive().listSharingBox.clear();
      }
    });
  }

  void _showUserCreatedMeals() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Eigene Gerichte"),
          ),
          body: ValueListenableBuilder(
            valueListenable: SuggestionsHive().userMealsBox.listenable(),
            builder: (context, value, child) {
              return ListView(
                shrinkWrap: true,
                children: [
                  for (Meal meal in SuggestionsHive().userMealsBox.values)
                    ExpansionTile(
                      title: ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return EditMealView(
                                  meal: meal,
                                );
                              },
                            )).then((newMeal) {
                              if (newMeal is Meal) {
                                SuggestionsHive().removeUserMeal(meal);
                                SuggestionsHive().addUserMeal(newMeal);
                              }
                            });
                          },
                          title: mealRow(meal)),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return EditMealView(
                                      meal: meal,
                                    );
                                  },
                                )).then((newMeal) {
                                  Navigator.pop(context, newMeal);
                                });
                              },
                              child: Icon(Icons.add)),
                          ElevatedButton(
                              onPressed: () {
                                SuggestionsHive().userMealsBox.delete(meal.key);
                              },
                              child: Icon(Icons.delete))
                        ],
                      ),
                      children: [
                        for (Article ingredient in meal.ingredients)
                          ListTile(
                            title: articleColumn(ingredient),
                          )
                      ],
                    )
                ],
              );
            },
          ),
        );
      },
    )).then((newMeal) {
      CookingListHive().addMeal(newMeal);
    });
  }

  void _shareShoppingList(BuildContext context) {
    if (ListSharingHive().isSharing()) {
      _displayUserCode();
    } else {
      queryUser(
              context: context,
              question:
                  "Eigene Liste für andere freigeben oder Liste von jemand anderem  verwenden?",
              positiveAnswer: "Eigene Liste freigeben",
              negativeAnswer: "Liste von jemand anderem verwenden")
          .then((value) {
        if (value) {
          _generateUserCode(context);
        } else {
          _syncListWithOthers();
        }
      });
    }
  }

  void _generateUserCode(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder(
            future: ListSharingHive().generateUserCode(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AlertDialog(
                  title: Text(
                      "Folgenden Code bei jemand anderem eintragen:\n${ListSharingHive().getUserCode()}"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Ok"))
                  ],
                );
              } else if (snapshot.hasError) {
                return AlertDialog(
                  title: Text("Fehler beim generieren des User Codes"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Ok"))
                  ],
                );
              } else {
                return AlertDialog(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
            },
          );
        });
  }

  Future<void> _displayUserCode() async {
    queryUser(
        context: context,
        question:
            "Folgenden Code bei jemand anderem eintragen:\n${ListSharingHive().getUserCode()}",
        positiveAnswer: "Ok");
  }

  void _syncListWithOthers() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController textEditingController = TextEditingController();
        GlobalKey<FormState> formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text("Sechs stelligen Code eingeben"),
          content: Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              maxLines: 1,
              maxLength: 6,
              controller: textEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Code eingeben";
                if (value.length < 6) {
                  return "Code muss sechs Zahlen lang sein";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  FormState? formState = formKey.currentState;
                  if (formState != null && formState.validate()) {
                    Navigator.pop(context, textEditingController.text);
                  }
                },
                child: Text("Bestätigen"))
          ],
        );
      },
    ).then((value) {
      int userCode = int.tryParse(value)!;
      showDialog(
          context: context,
          builder: (context) {
            return FutureBuilder(
              future: ListSharingMongoDB().checkIfUserCodeExists(userCode),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data is bool) {
                  bool userCodeExists = snapshot.data as bool;
                  if (userCodeExists) {
                    ListSharingHive().setUserCode(userCode);
                    ListSharingHive().pullUpdates();
                    return AlertDialog(
                      title: Text("Erfoglreich User Code gesetzt"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Ok"))
                      ],
                    );
                  } else {
                    return AlertDialog(
                      title: Text("User Code exestiert nicht"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Ok"))
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    title: Text("Fehler beim prüfen des User Codes"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Ok"))
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
                }
              },
            );
          });
    });
  }

  void _resetListSharing(BuildContext context) {
    queryUser(
            context: context,
            question: "Listen teilen zurücksetzten?",
            positiveAnswer: "Ja",
            negativeAnswer: "Nein")
        .then((value) {
      if (value) {
        ListSharingHive().listSharingBox.clear();
      }
    });
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
                        if (SuggestionsHive().articleBox.values.any((article) =>
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
