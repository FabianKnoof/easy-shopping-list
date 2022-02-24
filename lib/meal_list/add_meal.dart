import 'package:easy_shopping_list/db_accesses/cooking_list_hive.dart';
import 'package:easy_shopping_list/shopping_list/add_article.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'meal.dart';

class AddMealView extends StatefulWidget {
  const AddMealView({Key? key, this.meal}) : super(key: key);
  final Meal? meal;

  @override
  _AddMealViewState createState() => _AddMealViewState();
}

class _AddMealViewState extends State<AddMealView> {
  Meal _meal = Meal();

  final double _padding = 5;

  List<dynamic> _foundMeals =
      Hive.box("Suggestions").get("MealSuggestions", defaultValue: []);

  @override
  Widget build(BuildContext context) {
    if (widget.meal != null) {
      _meal = widget.meal!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Gericht wählen"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(_padding),
            child: Row(
              children: [
                SizedBox(
                  height: _padding,
                ),
                Expanded(
                  child: _buildSearchField(),
                ),
                SizedBox(
                  width: _padding,
                ),
                _buildNewMealButton(context)
              ],
            ),
          ),
          SizedBox(
            height: _padding,
          ),
          _buildFoundMealsExpansionList()
        ],
      ),
    );
  }

  ListView _buildFoundMealsExpansionList() {
    return ListView(
      shrinkWrap: true,
      children: [
        for (Meal meal in _foundMeals)
          ExpansionTile(
            title: Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return NewMeal(
                            meal: meal,
                          );
                        },
                      )).then((value) => Navigator.pop(context, value));
                    },
                    child: Icon(Icons.add)),
                SizedBox(
                  width: _padding,
                ),
                Text(meal.name),
                SizedBox(
                  width: _padding,
                ),
                Text(meal.quantity.toString()),
                Text(meal.quantityUnit)
              ],
            ),
            children: [
              for (Article ingredient in meal.ingredients)
                _buildMealIngredientTile(ingredient)
            ],
          )
      ],
    );
  }

  ListTile _buildMealIngredientTile(Article ingredient) {
    return ListTile(
      title: Row(
        children: [
          Text(ingredient.name),
          SizedBox(
            width: _padding,
          ),
          Text(ingredient.quantity.toString()),
          Text(Article.quantityUnitToString(ingredient.quantityUnit)),
          SizedBox(
            width: _padding,
          ),
          Text(ingredient.details)
        ],
      ),
    );
  }

  ElevatedButton _buildNewMealButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewMeal(
                  meal: _meal,
                ),
              )).then((newMeal) => Navigator.pop(context, newMeal));
        },
        child: Text("Neues Gericht"));
  }

  TextField _buildSearchField() {
    return TextField(
      onChanged: (String value) {
        _meal.name = value;
        _foundMeals = Hive.box("Suggestions")
            .get("MealSuggestions", defaultValue: [])
            .where((meal) =>
                meal.name.toLowerCase().startsWith(value.toLowerCase()))
            .toList();
      },
      decoration:
          InputDecoration(labelText: "Gericht", border: OutlineInputBorder()),
    );
  }
}

class NewMeal extends StatefulWidget {
  const NewMeal({Key? key, this.meal}) : super(key: key);
  final Meal? meal;

  @override
  _NewMealState createState() => _NewMealState();
}

class _NewMealState extends State<NewMeal> {
  final double _padding = 5;

  Meal _meal = Meal();

  final GlobalKey<FormState> _addMealFormKey = GlobalKey<FormState>();

  final TextEditingController _mealNameController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  final List<String> _mealSuggestions =
      Hive.box("Suggestions").get("MealSuggestions", defaultValue: <String>[]);

  void _submitForm() {
    FormState? formState = _addMealFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      Navigator.pop(context, _meal);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.meal != null) {
      _meal = widget.meal!;
      _mealNameController.text = _meal.name;
      _mealNameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _mealNameController.text.length));
    }
    _quantityController.text = _meal.quantity.toString();
    _quantityController.selection = TextSelection(
        baseOffset: 0, extentOffset: _meal.quantity.toString().length);

    return Scaffold(
      appBar: AppBar(
        title: Text("Gericht"),
      ),
      body: Column(
        children: [
          Form(
            key: _addMealFormKey,
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
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
                            child: FocusTraversalOrder(
                                order: NumericFocusOrder(1),
                                child: _buildMealTypeAheadField())),
                        SizedBox(
                          width: _padding,
                        ),
                        _buildSubmitButton()
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(_padding),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: FocusTraversalOrder(
                              order: NumericFocusOrder(2),
                              child: _buildQuantityTextField()),
                        ),
                        SizedBox(
                          width: _padding,
                        ),
                        Expanded(flex: 2, child: Text(_meal.quantityUnit)),
                        SizedBox(
                          width: _padding,
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildChangeIngredientQuantityButton(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_padding),
            child: Row(
              children: [
                _buildAddArticleButton(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(_padding),
              child: _buildIngredientsList(),
            ),
          )
        ],
      ),
    );
  }

  TypeAheadFormField<String> _buildMealTypeAheadField() {
    return TypeAheadFormField(
      hideOnEmpty: true,
      hideOnLoading: true,
      onSaved: (newValue) {
        _meal.name = newValue!;
      },
      onSuggestionSelected: (String suggestion) {
        _mealNameController.text = suggestion;
        // Todo meal suggestion selection
      },
      itemBuilder: (context, String itemData) {
        return ListTile(
          title: Text(itemData),
        );
      },
      suggestionsCallback: (pattern) {
        if (pattern.isNotEmpty) {
          return const <String>[];
        }
        return _mealSuggestions.where((String mealSuggestion) {
          return mealSuggestion.toLowerCase().startsWith(pattern.toLowerCase());
        });
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Gericht eingeben";
        }
        return null;
      },
      textFieldConfiguration: TextFieldConfiguration(
          controller: _mealNameController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          maxLines: 1,
          decoration: _textFieldInputDecoration("Gericht")),
    );
  }

  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
        onPressed: () {
          _submitForm();
        },
        child: Icon(Icons.add));
  }

  TextFormField _buildQuantityTextField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      maxLines: 1,
      controller: _quantityController,
      onChanged: (quantityText) {
        if (quantityText.isNotEmpty) {
          _quantityController.text = quantityText;
        }
      },
      onSaved: (newValue) {
        _meal.quantity = int.tryParse(newValue!)!;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Menge angeben";
        }
        return null;
      },
      decoration: _textFieldInputDecoration("Menge"),
    );
  }

  ElevatedButton _buildChangeIngredientQuantityButton() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            for (Article ingredient in _meal.ingredients) {
              ingredient.quantity = (ingredient.quantity /
                      _meal.quantity *
                      int.tryParse(_quantityController.text)!)
                  .round();
            }
            _meal.quantity = int.tryParse(_quantityController.text)!;
          });
        },
        child: Text("Zutaten Mengen anpassen"));
  }

  ListView _buildIngredientsList() {
    return ListView(
      shrinkWrap: true,
      children: [
        for (Article ingredient in _meal.ingredients)
          _buildIngredientListTile(ingredient)
      ],
    );
  }

  ListTile _buildIngredientListTile(Article ingredient) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return AddArticleBottomSheet(
              article: ingredient,
            );
          },
        ).then((value) {
          if (value != null) ingredient = value;
        });
      },
      title: Row(
        children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _meal.ingredients.remove(ingredient);
                });
              },
              child: Icon(Icons.delete)),
          SizedBox(
            width: _padding,
          ),
          Text(ingredient.name),
          SizedBox(
            width: _padding,
          ),
          Text(ingredient.quantity.toString()),
          Text(Article.quantityUnitToString(ingredient.quantityUnit)),
          SizedBox(
            width: _padding,
          ),
          Text(ingredient.details),
        ],
      ),
    );
  }

  ElevatedButton _buildAddArticleButton() {
    return ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return AddArticleBottomSheet();
            },
          ).then((value) {
            if (value != null) {
              setState(() {
                // Note Add article quantity if article already in ingredients?
                _meal.ingredients.insert(0, value);
              });
            }
          });
        },
        child: Text("Zutat hinzufügen"));
  }

  InputDecoration _textFieldInputDecoration(String labelText) =>
      InputDecoration(border: OutlineInputBorder(), labelText: labelText);
}
