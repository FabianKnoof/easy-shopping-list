import 'dart:developer';

import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
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

class _AddMealViewState extends State<AddMealView> with GeneralUseFunctions {
  List<Meal> _allMeals = [];

  List<Meal> _foundMeals = [];

  final TextEditingController _searchFieldController = TextEditingController();

  List<String> _includeFilters = [];
  List<String> _excludeFilters = [];

  List<String> _includeFiltersShoppingList = [];

  @override
  void initState() {
    super.initState();

    _allMeals = SuggestionsHive().mealBox.values.toList() +
        SuggestionsHive().userMealsBox.values.toList();
    _allMeals
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    _foundMeals = _allMeals;
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
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                SizedBox(
                  height: padding,
                ),
                Expanded(
                  child: _buildSearchField(),
                ),
                SizedBox(
                  width: padding,
                ),
                _buildNewMealButton(context)
              ],
            ),
          ),
          SizedBox(
            height: padding,
          ),
          Wrap(
            children: [
              Padding(
                  padding: EdgeInsets.all(padding),
                  child: _buildFilterButton()),
              Padding(
                  padding: EdgeInsets.all(padding),
                  child: _buildShoppingListFilterButton()),
            ],
          ),
          SizedBox(
            height: padding,
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
      onChanged: (searchPattern) {
        setState(() {
          _filterFoundMeals();
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
              )).then((newMeal) {
            if (newMeal != null) {
              Navigator.pop(context, newMeal);
            }
          });
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
                  )).then((newMeal) {
                    if (newMeal != null) {
                      Navigator.pop(context, newMeal);
                    }
                  });
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
                includeFilters: _includeFilters,
                excludeFilters: _excludeFilters,
                ingredients: SuggestionsHive()
                    .articleBox
                    .values
                    .where((element) => element.isIngredient)
                    .map((e) => e.name)
                    .toList(),
              );
            },
          )).then((filters) {
            if (filters is List<List<String>>) {
              setState(() {
                _includeFilters = filters[0];
                _excludeFilters = filters[1];
                _filterFoundMeals();
              });
            }
          });
        },
        child: Row(
          children: [
            Text("Filter ("),
            Icon(Icons.check),
            Text(":${_includeFilters.length},"),
            Icon(Icons.close),
            Text(":${_excludeFilters.length})")
          ],
        ));
  }

  _buildShoppingListFilterButton() {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return FilterView(
                includeFilters: _includeFiltersShoppingList,
                ingredients: ShoppingListHive()
                    .shoppingListBox
                    .values
                    .map((e) => e.name)
                    .toList(),
              );
            },
          )).then((filters) {
            if (filters is List<String>) {
              setState(() {
                _includeFiltersShoppingList = filters;
                _filterFoundMeals();
              });
            }
          });
        },
        child: Row(
          children: [
            Text("Einkaufsliste Filter ("),
            Icon(Icons.check),
            Text(":${_includeFiltersShoppingList.length})"),
          ],
        ));
  }

  void _filterFoundMeals() {
    _foundMeals = _allMeals;
    List<Meal> filteredMeals = [];

    if (_searchFieldController.text.isNotEmpty) {
      for (Meal meal in _foundMeals) {
        if (meal.name
            .toLowerCase()
            .contains(_searchFieldController.text.toLowerCase())) {
          filteredMeals.add(meal);
        }
      }
      _foundMeals = List.from(filteredMeals);
      filteredMeals.clear();
    }

    if (_excludeFilters.isNotEmpty || _includeFilters.isNotEmpty) {
      mealLoop:
      for (Meal meal in _foundMeals) {
        for (String deselectFilter in _excludeFilters) {
          for (Article ingredient in meal.ingredients) {
            if (ingredient.name.toLowerCase() == deselectFilter.toLowerCase()) {
              log(ingredient.toString());
              continue mealLoop;
            }
          }
        }
        if (_includeFilters.isEmpty) {
          filteredMeals.add(meal);
        }
        for (String selectFilter in _includeFilters) {
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
      _foundMeals = List.from(filteredMeals);
      filteredMeals.clear();
    }

    if (_includeFiltersShoppingList.isNotEmpty) {
      mealLoop:
      for (Meal meal in _foundMeals) {
        for (Article ingredient in meal.ingredients) {
          for (String selectFilter in _includeFiltersShoppingList) {
            if (ingredient.name.toLowerCase() == selectFilter.toLowerCase()) {
              filteredMeals.add(meal);
              continue mealLoop;
            }
          }
        }
      }
      _foundMeals = List.from(filteredMeals);
    }
  }
}

class EditMealView extends StatefulWidget {
  const EditMealView({Key? key, this.meal}) : super(key: key);
  final Meal? meal;

  @override
  _EditMealViewState createState() => _EditMealViewState();
}

class _EditMealViewState extends State<EditMealView> with GeneralUseFunctions {
  Meal _meal = Meal();

  final GlobalKey<FormState> _addMealFormKey = GlobalKey<FormState>();

  final TextEditingController _mealNameController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

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
                    height: padding,
                  ),
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      children: [
                        Expanded(
                            child: FocusTraversalOrder(
                                order: NumericFocusOrder(1),
                                child: _buildMealTypeAheadField())),
                        SizedBox(
                          width: padding,
                        ),
                        _buildSubmitButton()
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: FocusTraversalOrder(
                              order: NumericFocusOrder(2),
                              child: _buildQuantityTextField()),
                        ),
                        SizedBox(
                          width: padding,
                        ),
                        Expanded(flex: 2, child: Text(_meal.quantityUnit)),
                        SizedBox(
                          width: padding,
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
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                _buildAddArticleButton(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: _buildIngredientsList(),
            ),
          )
        ],
      ),
    );
  }

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
      validator: (name) {
        if (name == null || name.trim().isEmpty) {
          return "Gericht eingeben";
        }
        return null;
      },
      onSaved: (name) {
        _meal.name = name!.trim();
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
      validator: (quantity) {
        if (quantity == null || quantity.trim().isEmpty) {
          return "Menge angeben";
        }
        return null;
      },
      onSaved: (quantity) {
        _meal.quantity = int.tryParse(quantity!.trim())!;
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

class FilterView extends StatefulWidget {
  const FilterView(
      {Key? key,
      required this.ingredients,
      required this.includeFilters,
      this.excludeFilters})
      : super(key: key);
  final List<String> ingredients;
  final List<String> includeFilters;
  final List<String>? excludeFilters;

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> with GeneralUseFunctions {
  List<String> _ingredients = [];

  List<String> _availableFilters = [];

  List<String> _includeFilters = [];
  List<String> _excludeFilters = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _ingredients = widget.ingredients;
    _ingredients.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    _availableFilters = _ingredients;

    _includeFilters = widget.includeFilters;
    if (widget.excludeFilters != null) {
      _excludeFilters = widget.excludeFilters!;
    }
  }

  @override
  Widget build(BuildContext context) {
    _includeFilters.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    _excludeFilters.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Gericht Filter"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.vertical_align_top),
            onPressed: () {
              _scrollController.animateTo(0,
                  duration: const Duration(seconds: 2),
                  curve: Curves.elasticInOut);
            },
          ),
          SizedBox(
            height: padding,
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _includeFilters = [];
                if (widget.excludeFilters != null) {
                  _excludeFilters = [];
                }
              });
            },
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(
              context,
              widget.excludeFilters == null
                  ? _includeFilters
                  : [_includeFilters, _excludeFilters]);
          return false;
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: TextField(
                autofocus: true,
                onChanged: (searchPattern) {
                  setState(() {
                    searchPattern = searchPattern.trim();
                    _availableFilters = _ingredients
                        .where((ingredient) => ingredient
                            .toLowerCase()
                            .startsWith(searchPattern.toLowerCase()))
                        .toList();
                  });
                },
                decoration: textFieldInputDecoration("Filter Suche"),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: ListView(
                  shrinkWrap: true,
                  controller: _scrollController,
                  children: [
                    Wrap(
                      spacing: padding,
                      children: _buildIncludeFiltersChips(),
                    ),
                    Wrap(
                      spacing: padding,
                      children: _buildExcludeFiltersChips(),
                    ),
                    Wrap(
                      spacing: padding,
                      children: _buildAvailableFiltersChips(),
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

  List<Widget> _buildAvailableFiltersChips() {
    return [
      for (String ingredient in _availableFilters)
        FilterChip(
          label: Text(ingredient),
          showCheckmark: false,
          selected: _includeFilters.contains(ingredient) ||
              _excludeFilters.contains(ingredient),
          avatar: _getFilterChipAvatar(ingredient),
          onSelected: (value) {
            setState(() {
              if (_includeFilters.contains(ingredient)) {
                _includeFilters.remove(ingredient);
                if (widget.excludeFilters != null) {
                  _excludeFilters.add(ingredient);
                }
              } else if (_excludeFilters.contains(ingredient)) {
                _excludeFilters.remove(ingredient);
              } else {
                _includeFilters.add(ingredient);
              }
            });
          },
        )
    ];
  }

  List<Widget> _buildIncludeFiltersChips() {
    return [
      for (String ingredient in _includeFilters)
        FilterChip(
          label: Text(ingredient),
          avatar: Icon(Icons.check),
          selected: true,
          showCheckmark: false,
          onSelected: (value) {
            setState(() {
              _includeFilters.remove(ingredient);
              if (widget.excludeFilters != null) {
                _excludeFilters.add(ingredient);
              }
            });
          },
        ),
    ];
  }

  List<Widget> _buildExcludeFiltersChips() {
    return [
      for (String ingredient in _excludeFilters)
        FilterChip(
          label: Text(ingredient),
          avatar: Icon(Icons.close),
          selected: true,
          showCheckmark: false,
          onSelected: (value) {
            setState(() {
              _excludeFilters.remove(ingredient);
            });
          },
        ),
    ];
  }

  _getFilterChipAvatar(String ingredient) {
    if (_includeFilters.contains(ingredient)) {
      return Icon(Icons.check);
    } else if (_excludeFilters.contains(ingredient)) {
      return Icon(Icons.close);
    } else {
      return null;
    }
  }
}
