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

  List<String> _selectFilters = [];
  List<String> _deselectFilters = [];

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
      autofocus: true,
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
          _filterFoundMeals();
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
                selectFilters: _selectFilters,
                deselectFilters: _deselectFilters,
                ingredients: SuggestionsHive()
                    .articleBox
                    .values
                    .where((element) => element.isIngredient)
                    .map((e) => e.name)
                    .toList(),
              );
            },
          )).then((value) {
            if (value is List<List<String>>) {
              setState(() {
                _selectFilters = value[0];
                _deselectFilters = value[1];
                if (_selectFilters.isNotEmpty || _deselectFilters.isNotEmpty) {
                  _filterFoundMeals();
                }
              });
            }
          });
        },
        child: Row(
          children: [
            Text("Filter ("),
            Icon(Icons.check),
            Text(":${_selectFilters.length},"),
            Icon(Icons.close),
            Text(":${_deselectFilters.length})")
          ],
        ));
  }

  void _filterFoundMeals() {
    List<Meal> filteredMeals = [];
    mealLoop:
    for (Meal meal in _foundMeals) {
      for (String deselectFilter in _deselectFilters) {
        for (Article ingredient in meal.ingredients) {
          if (ingredient.name.toLowerCase() == deselectFilter.toLowerCase()) {
            continue mealLoop;
          }
        }
      }
      for (String selectFilter in _selectFilters) {
        for (Article ingredient in meal.ingredients) {
          if (ingredient.name
              .toLowerCase()
              .contains(selectFilter.toLowerCase())) {
            filteredMeals.add(meal);
            continue mealLoop;
          }
        }
      }
    }
    _foundMeals = filteredMeals;
  }
}

class FilterView extends StatefulWidget {
  const FilterView(
      {Key? key,
      required this.ingredients,
      required this.selectFilters,
      required this.deselectFilters})
      : super(key: key);
  final List<String> ingredients;
  final List<String> selectFilters;
  final List<String> deselectFilters;

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> with ViewTemplates {
  final double _padding = 5;

  List<String> _ingredients = [];

  List<String> _filters = [];

  List<String> _selectFilters = [];
  List<String> _deselectFilters = [];

  @override
  void initState() {
    super.initState();

    _ingredients = widget.ingredients;
    _ingredients.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    _filters = _ingredients;

    _selectFilters = widget.selectFilters;
    _deselectFilters = widget.deselectFilters;
  }

  @override
  Widget build(BuildContext context) {
    _selectFilters.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    _deselectFilters.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Gericht Filter"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, [_selectFilters, _deselectFilters]);
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
                    _filters = _ingredients
                        .where((element) => element
                            .toLowerCase()
                            .startsWith(value.toLowerCase()))
                        .toList();
                    // Todo maybe fix that it only shows searched filters
                    // _selectFilters = _selectFilters
                    //     .where((element) => element
                    //         .toLowerCase()
                    //         .startsWith(value.toLowerCase()))
                    //     .toList();
                    // _deselectFilters = _deselectFilters
                    //     .where((element) => element
                    //         .toLowerCase()
                    //         .startsWith(value.toLowerCase()))
                    //     .toList();
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
                      children: _buildSelectFiltersChips(),
                    ),
                    Wrap(
                      spacing: _padding,
                      children: _buildDeselectFiltersChips(),
                    ),
                    Wrap(
                      spacing: _padding,
                      children: _buildFiltersChips(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFiltersChips() {
    return [
      for (String ingredient in _filters)
        FilterChip(
          label: Text(ingredient),
          showCheckmark: false,
          selected: _selectFilters.contains(ingredient) ||
              _deselectFilters.contains(ingredient),
          avatar: _getFilterChipAvatar(ingredient),
          onSelected: (value) {
            setState(() {
              if (_selectFilters.contains(ingredient)) {
                _selectFilters.remove(ingredient);
                _deselectFilters.add(ingredient);
              } else if (_deselectFilters.contains(ingredient)) {
                _deselectFilters.remove(ingredient);
              } else {
                _selectFilters.add(ingredient);
              }
            });
          },
        )
    ];
  }

  List<Widget> _buildDeselectFiltersChips() {
    return [
      for (String ingredient in _deselectFilters)
        FilterChip(
          label: Text(ingredient),
          avatar: Icon(Icons.close),
          selected: true,
          showCheckmark: false,
          onSelected: (value) {
            setState(() {
              _deselectFilters.remove(ingredient);
            });
          },
        ),
    ];
  }

  List<Widget> _buildSelectFiltersChips() {
    return [
      for (String ingredient in _selectFilters)
        FilterChip(
          label: Text(ingredient),
          avatar: Icon(Icons.check),
          selected: true,
          showCheckmark: false,
          onSelected: (value) {
            setState(() {
              _selectFilters.remove(ingredient);
              _deselectFilters.add(ingredient);
            });
          },
        ),
    ];
  }

  _getFilterChipAvatar(String ingredient) {
    if (_selectFilters.contains(ingredient)) {
      return Icon(Icons.check);
    } else if (_deselectFilters.contains(ingredient)) {
      return Icon(Icons.close);
    } else {
      return null;
    }
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
      _meal = widget.meal!.getCopy();
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
            setState(() {
              if (newIngredient != null) {
                ingredient = newIngredient;
              }
            });
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
