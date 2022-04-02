import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/general_use_functions.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddArticleBottomSheet extends StatefulWidget {
  const AddArticleBottomSheet(
      {Key? key, this.article, this.suggestOnlyIngredients})
      : super(key: key);
  final Article? article;
  final bool? suggestOnlyIngredients;

  @override
  State<AddArticleBottomSheet> createState() => _AddArticleBottomSheetState();
}

class _AddArticleBottomSheetState extends State<AddArticleBottomSheet>
    with GeneralUseFunctions {
  Article _article = Article();

  bool _suggestOnlyIngredients = false;

  final double _padding = 5;

  final GlobalKey<FormState> _addArticleFormKey = GlobalKey<FormState>();

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _quantityTextController = TextEditingController();

  QuantityUnit _dropdownValue = QuantityUnit.pieces;
  final List<DropdownMenuItem<QuantityUnit>> _dropdownItems =
      QuantityUnit.values.map((QuantityUnit unit) {
    return DropdownMenuItem<QuantityUnit>(
        value: unit, child: Text(Article.quantityUnitToString(unit)));
  }).toList();

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _article = widget.article!;
    }
    _typeAheadController.text = _article.name;
    _quantityTextController.text =
        _article.quantity == 0 ? "" : _article.quantity.toString();
    _dropdownValue = _article.quantityUnit;
    if (widget.suggestOnlyIngredients != null) {
      _suggestOnlyIngredients = widget.suggestOnlyIngredients!;
    }
  }

  void _submitForm() {
    FormState? formState = _addArticleFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      Navigator.pop(context, _article);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 3),
      child: Form(
          key: _addArticleFormKey,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                              child: _buildArticleTypeAheadField())),
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
                          flex: 2,
                          child: FocusTraversalOrder(
                              order: NumericFocusOrder(2),
                              child: _buildQuantityTextField())),
                      SizedBox(
                        width: _padding,
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildQuantityUnitDropdownButton(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(_padding),
                  child: FocusTraversalOrder(
                      order: NumericFocusOrder(3),
                      child: _buildDetailsTextField()),
                ),
              ],
            ),
          )),
    );
  }

  TypeAheadFormField<String> _buildArticleTypeAheadField() {
    return TypeAheadFormField(
      hideOnEmpty: true,
      hideOnLoading: true,
      direction: AxisDirection.up,
      onSuggestionSelected: (String suggestion) {
        setState(() {
          _typeAheadController.text = suggestion;
        });
      },
      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      suggestionsCallback: (pattern) {
        pattern = pattern.trim();
        if (pattern.isEmpty) {
          return const <String>[];
        }
        return SuggestionsHive().articleBox.values.where((Article article) {
          return article.name.toLowerCase().startsWith(pattern.toLowerCase()) &&
              (!_suggestOnlyIngredients || article.isIngredient);
        }).map((article) => article.name);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Artikel eingeben";
        }
        return null;
      },
      onSaved: (newValue) {
        _article.name = newValue!.trim();
      },
      textFieldConfiguration: TextFieldConfiguration(
          controller: _typeAheadController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          maxLines: 1,
          decoration: textFieldInputDecoration("Artikel")),
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
      controller: _quantityTextController,
      onTap: () {
        _quantityTextController.selection = TextSelection(
            baseOffset: 0, extentOffset: _quantityTextController.text.length);
      },
      onSaved: (newValue) {
        if (newValue != null && newValue.trim().isNotEmpty) {
          _article.quantity = int.tryParse(newValue)!;
        } else if (newValue != null && newValue.trim().isEmpty) {
          _article.quantity = 0;
        }
      },
      decoration: textFieldInputDecoration("Menge"),
    );
  }

  DropdownButtonFormField<QuantityUnit> _buildQuantityUnitDropdownButton() {
    return DropdownButtonFormField<QuantityUnit>(
      value: _dropdownValue,
      items: _dropdownItems,
      onChanged: (value) {
        setState(() {
          _dropdownValue = value!;
          _article.quantityUnit = value;
        });
      },
    );
  }

  TextFormField _buildDetailsTextField() {
    return TextFormField(
      initialValue: _article.details,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      maxLines: 1,
      onFieldSubmitted: (value) {
        _submitForm();
      },
      onSaved: (newValue) {
        if (newValue != null && newValue.trim().isNotEmpty) {
          _article.details = newValue;
        }
      },
      decoration: textFieldInputDecoration("Details"),
    );
  }
}
