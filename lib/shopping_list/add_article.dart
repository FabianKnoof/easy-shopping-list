import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddArticleBottomSheet extends StatefulWidget {
  const AddArticleBottomSheet({Key? key, this.article}) : super(key: key);
  final Article? article;

  @override
  State<AddArticleBottomSheet> createState() => _AddArticleBottomSheetState();
}

class _AddArticleBottomSheetState extends State<AddArticleBottomSheet> {
  Article _article = Article();

  final double _padding = 5;

  final GlobalKey<FormState> _addArticleFormKey = GlobalKey<FormState>();

  final TextEditingController _typeAheadController = TextEditingController();

  QuantityUnit _dropdownValue = QuantityUnit.pieces;
  final List<DropdownMenuItem<QuantityUnit>> _dropdownItems =
      QuantityUnit.values.map((QuantityUnit unit) {
    return DropdownMenuItem<QuantityUnit>(
        value: unit, child: Text(Article.quantityUnitToString(unit)));
  }).toList();

  final List<String> _articleSuggestions =
      Hive.box("Suggestions").get("ArticleSuggestions");

  void _submitForm() {
    FormState? formState = _addArticleFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      Navigator.pop(context, _article);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.article != null) {
      _article = widget.article!;
      _typeAheadController.text = _article.name;
      _typeAheadController.selection = TextSelection.fromPosition(
          TextPosition(offset: _typeAheadController.text.length));
      _dropdownValue = _article.quantityUnit;
    }

    return Container(
      constraints: BoxConstraints.expand(),
      child: Form(
          key: _addArticleFormKey,
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
      onSaved: (String? newValue) {
        _article.name = newValue!;
      },
      onSuggestionSelected: (String suggestion) {
        _typeAheadController.text = suggestion;
      },
      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) {
          return const <String>[];
        }
        return _articleSuggestions.where((String articleSuggestion) {
          return articleSuggestion
              .toLowerCase()
              .startsWith(pattern.toLowerCase());
        });
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Artikel eingeben";
        }
        return null;
      },
      textFieldConfiguration: TextFieldConfiguration(
          controller: _typeAheadController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          maxLines: 1,
          decoration: _textFieldInputDecoration("Artikel")),
    );
  }

  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
        onPressed: () {
          _submitForm();
        },
        child: Text("Add"));
  }

  TextFormField _buildQuantityTextField() {
    return TextFormField(
      initialValue: _article.quantity.toString(),
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      maxLines: 1,
      onSaved: (newValue) {
        if (newValue != null && newValue.isNotEmpty) {
          _article.quantity = int.tryParse(newValue)!;
        }
      },
      decoration: _textFieldInputDecoration("Menge"),
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
        _article.details = newValue!;
      },
      decoration: _textFieldInputDecoration("Details"),
    );
  }

  InputDecoration _textFieldInputDecoration(String labelText) =>
      InputDecoration(border: OutlineInputBorder(), labelText: labelText);
}
