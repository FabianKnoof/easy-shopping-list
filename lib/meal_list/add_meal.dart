import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/general_use_functions.dart';
import 'package:easy_shopping_list/shopping_list/add_article.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'meal.dart';

class AddMealView extends StatefulWidget {
  const AddMealView({Key? key}) : super(key: key);

  @override
  _AddMealViewState createState() => _AddMealViewState();
}

class _AddMealViewState extends State<AddMealView> with ViewTemplates {
  final double _padding = 5;

  List<Meal> _foundMeals = [];

  final TextEditingController _searchFieldController = TextEditingController();

  List<String> _filters = [];

  @override
  void initState() {
    super.initState();

    _foundMeals = SuggestionsHive()
            .mealBox
            .values
            .map((e) => e.getCopy())
            .toList() +
        SuggestionsHive().userMealsBox.values.map((e) => e.getCopy()).toList();
    _foundMeals
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.all(_padding),
                  child: _buildFilterButton())),
          SizedBox(
            height: _padding,
          ),
          Flexible(fit: FlexFit.loose, child: _buildFoundMealsExpansionList())
        ],
      ),
    );
  }

  TextField _buildSearchField() {
    return TextField(
      controller: _searchFieldController,
      onChanged: (value) {
        setState(() {
          value = value.trim();
          _foundMeals = SuggestionsHive()
                  .mealBox
                  .values
                  .where((meal) =>
                      meal.name.toLowerCase().contains(value.toLowerCase()))
                  .map((e) => e.getCopy())
                  .toList() +
              SuggestionsHive()
                  .userMealsBox
                  .values
                  .where((meal) =>
                      meal.name.toLowerCase().contains(value.toLowerCase()))
                  .map((e) => e.getCopy())
                  .toList();
          _foundMeals = _filterMeals(_foundMeals);
          _foundMeals.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        });
      },
      decoration: textFieldInputDecoration("Gericht"),
    );
  }

  ElevatedButton _buildNewMealButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditMealView(
                  meal: Meal()..name = _searchFieldController.text,
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
            leading: ElevatedButton(
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
            title: mealRow(meal),
            children: [
              for (Article ingredient in meal.ingredients)
                ListTile(title: articleColumn(ingredient))
            ],
          )
      ],
    );
  }

  _buildFilterButton() {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return FilterView(
                filters: _filters,
              );
            },
          )).then((value) {
            if (value.runtimeType == List<String>) {
              value as List<String>;
              setState(() {
                _filters = value;
                if (_filters.isEmpty) return;
                _foundMeals = _filterMeals(_foundMeals);
              });
            }
          });
        },
        child: Text("Filter (${_filters.length})"));
  }

  List<Meal> _filterMeals(List<Meal> mealList) {
    if (_filters.isEmpty) return mealList;
    List<Meal> filteredMeals = [];
    for (Meal meal in mealList) {
      bool mealContainFilter = false;
      mealLoop:
      for (Article ingredient in meal.ingredients) {
        for (String filter in _filters) {
          if (ingredient.name.toLowerCase().contains(filter.toLowerCase())) {
            mealContainFilter = true;
            continue mealLoop;
          }
        }
      }
      if (mealContainFilter) {
        filteredMeals.add(meal);
      }
    }
    return filteredMeals;
  }
}

class FilterView extends StatefulWidget {
  const FilterView({Key? key, required this.filters}) : super(key: key);
  final List<String> filters;

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> with ViewTemplates {
  final double _padding = 5;

  List<String> _ingredients = [];

  List<String> _filters = [];

  @override
  void initState() {
    super.initState();

    _ingredients = SuggestionsHive()
        .articleBox
        .values
        .where((element) => element.isIngredient)
        .map((e) => e.name)
        .toList();
    _ingredients.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    _filters = widget.filters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gericht Filter"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _filters);
          return false;
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(_padding),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    value = value.trim();
                    _ingredients = SuggestionsHive()
                        .articleBox
                        .values
                        .where((element) => element.isIngredient)
                        .where((element) => element.name
                            .toLowerCase()
                            .startsWith(value.toLowerCase()))
                        .map((e) => e.name)
                        .toList();
                    _ingredients.sort(
                        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  });
                },
                decoration: textFieldInputDecoration("Filter Suche"),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(_padding),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Wrap(
                      spacing: _padding,
                      children: [
                        for (String ingredient in _filters)
                          FilterChip(
                            label: Text(ingredient),
                            selected: true,
                            onSelected: (value) {
                              setState(() {
                                _ingredients.add(ingredient);
                                _ingredients.sort((a, b) =>
                                    a.toLowerCase().compareTo(b.toLowerCase()));
                                _filters.remove(ingredient);
                                _filters.sort((a, b) =>
                                    a.toLowerCase().compareTo(b.toLowerCase()));
                              });
                            },
                          ),
                        for (String ingredient in _ingredients)
                          FilterChip(
                            label: Text(ingredient),
                            selected: false,
                            onSelected: (value) {
                              setState(() {
                                _filters.add(ingredient);
                                _filters.sort((a, b) =>
                                    a.toLowerCase().compareTo(b.toLowerCase()));
                                _ingredients.remove(ingredient);
                                _ingredients.sort((a, b) =>
                                    a.toLowerCase().compareTo(b.toLowerCase()));
                              });
                            },
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

class _EditMealViewState extends State<EditMealView> with ViewTemplates {
  final double _padding = 5;

  Meal _meal = Meal();

  final GlobalKey<FormState> _addMealFormKey = GlobalKey<FormState>();

  final TextEditingController _mealNameController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  void _submitForm() {
    FormState? formState = _addMealFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      for (Article ingredient in _meal.ingredients) {
        ingredient.partOfMeal = _meal.name;
      }

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
      hideOnError: true,
      onSuggestionSelected: (String suggestion) {
        setState(() {
          _meal = SuggestionsHive()
              .getMealsForSuggestion()
              .firstWhere((element) => element.name == suggestion);
          _mealNameController.text = _meal.name;
          _quantityController.text = _meal.quantity.toString();
        });
      },
      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      suggestionsCallback: (pattern) {
        pattern = pattern.trim();
        if (pattern.isEmpty || pattern == _meal.name) {
          return const <String>[];
        }
        return SuggestionsHive()
            .mealBox
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
          decoration: textFieldInputDecoration("Gericht")),
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
      decoration: textFieldInputDecoration("Menge"),
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

  ElevatedButton _buildAddArticleButton() {
    return ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return AddArticleBottomSheet(
                suggestOnlyIngredients: true,
              );
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
            isScrollControlled: true,
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
        leading: ElevatedButton(
            onPressed: () {
              setState(() {
                _meal.ingredients.remove(ingredient);
              });
            },
            child: Icon(Icons.delete)),
        title: articleColumn(ingredient));
  }
}
