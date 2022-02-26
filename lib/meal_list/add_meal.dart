import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/shopping_list/add_article.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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

  List<Meal> _foundMeals =
      MealSuggestionsHive().box.values.toList(growable: true);

  @override
  void initState() {
    super.initState();

    if (widget.meal != null) {
      _meal = widget.meal!;
    }
  }

  @override
  Widget build(BuildContext context) {
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

  TextField _buildSearchField() {
    return TextField(
      onChanged: (value) {
        value = value.trim();
        if (value.isEmpty) return;
        _meal.name = value;
        _foundMeals = MealSuggestionsHive()
            .box
            .values
            .where((meal) =>
                meal.name.toLowerCase().startsWith(value.toLowerCase()))
            .toList();
      },
      decoration:
          InputDecoration(labelText: "Gericht", border: OutlineInputBorder()),
    );
  }

  ElevatedButton _buildNewMealButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditMealView(
                  meal: _meal,
                ),
              )).then((newMeal) => Navigator.pop(context, newMeal));
        },
        child: Text("Neues Gericht"));
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
                          return EditMealView(
                            meal: meal,
                          );
                        },
                      )).then((newMeal) => Navigator.pop(context, newMeal));
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
          Text(ingredient.quantityUnitAsString()),
          SizedBox(
            width: _padding,
          ),
          Text(ingredient.details)
        ],
      ),
    );
  }
}

class EditMealView extends StatefulWidget {
  const EditMealView({Key? key, this.meal}) : super(key: key);
  final Meal? meal;

  @override
  _EditMealViewState createState() => _EditMealViewState();
}

class _EditMealViewState extends State<EditMealView> {
  final double _padding = 5;

  Meal _meal = Meal();

  final GlobalKey<FormState> _addMealFormKey = GlobalKey<FormState>();

  final TextEditingController _mealNameController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  void _submitForm() {
    FormState? formState = _addMealFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      Navigator.pop(context, _meal);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.meal != null) {
      _meal = widget.meal!;
    }
    _mealNameController.text = _meal.name;
    _quantityController.text = _meal.quantity.toString();
    // Note test quantity selection not selecting all on first focus
  }

  @override
  Widget build(BuildContext context) {
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
        pattern = pattern.trim();
        if (pattern.isEmpty) {
          return const <String>[];
        }
        return MealSuggestionsHive()
            .box
            .values
            .where((meal) =>
                meal.name.toLowerCase().startsWith(pattern.toLowerCase()))
            .map((article) => article.name);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Gericht eingeben";
        }
        return null;
      },
      onSaved: (newValue) {
        _meal.name = newValue!.trim();
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
      onTap: () {
        _quantityController.selection = TextSelection(
            baseOffset: 0, extentOffset: _quantityController.text.length);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Menge angeben";
        }
        return null;
      },
      onSaved: (newValue) {
        _meal.quantity = int.tryParse(newValue!.trim())!;
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
                      int.tryParse(_quantityController.text.trim())!)
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
        ).then((newIngredient) {
          if (newIngredient != null) {
            setState(() {
              ingredient = newIngredient;
            });
          }
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
          Text(ingredient.quantityUnitAsString()),
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
          ).then((newIngredient) {
            if (newIngredient != null) {
              setState(() {
                // Note Add article quantity if article already in ingredients?
                _meal.ingredients.insert(0, newIngredient);
              });
            }
          });
        },
        child: Text("Zutat hinzufügen"));
  }

  InputDecoration _textFieldInputDecoration(String labelText) =>
      InputDecoration(border: OutlineInputBorder(), labelText: labelText);
}
