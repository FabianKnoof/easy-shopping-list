import 'package:easy_shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddItemBottomSheet extends StatefulWidget {
  const AddItemBottomSheet({Key? key, this.article}) : super(key: key);
  final Article? article;

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  Article _article = Article();

  final double _padding = 5;

  final GlobalKey<FormState> _addItemFormKey = GlobalKey<FormState>();

  QuantityUnit _dropdownValue = QuantityUnit.pieces;
  final List<DropdownMenuItem<QuantityUnit>> _dropdownItems =
      QuantityUnit.values.map((QuantityUnit unit) {
    return DropdownMenuItem<QuantityUnit>(
        value: unit, child: Text(Article.quantityUnitToString(unit)));
  }).toList();

  final TextEditingController _typeAheadController = TextEditingController();

  final List<String> _articleSuggestions = ["Bananen", "Spaghetti", "Joghurt"];

  void _submitForm() {
    FormState? formState = _addItemFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      Navigator.pop(context, _article);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.article != null) {
      _article = widget.article!;
    }

    return Container(
      constraints: BoxConstraints.expand(),
      child: Form(
          key: _addItemFormKey,
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
                        child: TypeAheadFormField(
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
                      suggestionsCallback: (pattern) {
                        if (pattern.isEmpty) {
                          return const <String>[];
                        }
                        return _articleSuggestions
                            .where((String articleSuggestion) {
                          return articleSuggestion
                              .toLowerCase()
                              .contains(pattern.toLowerCase());
                        });
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: _typeAheadController
                            ..text = _article.name,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Artikel")),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Artikel eingeben";
                        }
                        return null;
                      },
                    )),
                    SizedBox(
                      width: _padding,
                    ),
                    ElevatedButton(
                        // Todo fix fit
                        onPressed: () {
                          _submitForm();
                        },
                        child: Text("Add"))
                    // Todo fix visual
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(_padding),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _article.quantity.toString(),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              RegExp commaDecimal = RegExp("(^\\d*[.,]?\\d*\$)",
                                  caseSensitive: false, multiLine: false);
                              if (!commaDecimal.hasMatch(value)) {
                                // Todo adjust regex
                                return "Mengenangabe ist nicht valide";
                              }
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            if (newValue != null && newValue.isNotEmpty) {
                              _article.quantity = int.tryParse(newValue)!;
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "Menge"),
                        )),
                    SizedBox(
                      width: _padding,
                    ),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<QuantityUnit>(
                        // Todo fix focus on dropdown
                        value: _dropdownValue,
                        items: _dropdownItems,
                        onChanged: (value) {
                          setState(() {
                            _dropdownValue = value!;
                            _article.quantityUnit = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(_padding),
                child: TextFormField(
                  initialValue: _article.details,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (value) {
                    _submitForm();
                  },
                  onSaved: (newValue) {
                    _article.details = newValue!;
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Details"),
                ),
              ),
            ],
          )),
    );
  }
}
