import 'package:easy_shopping_list/article.dart';
import 'package:flutter/material.dart';

class AddItemBottomSheet extends StatefulWidget {
  const AddItemBottomSheet({Key? key, this.article}) : super(key: key);
  final Article? article;

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  Article article = Article();

  final double _padding = 5;

  final GlobalKey<FormState> _addItemFormKey = GlobalKey<FormState>();

  QuantityUnit dropdownValue = QuantityUnit.pieces;
  final List<DropdownMenuItem<QuantityUnit>> dropdownItems =
      QuantityUnit.values.map((QuantityUnit unit) {
    return DropdownMenuItem<QuantityUnit>(
        value: unit, child: Text(Article.quantityUnitToString(unit)));
  }).toList();

  void _submitForm() {
    FormState? formState = _addItemFormKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      Navigator.pop(context, article);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.article != null) {
      article = widget.article!;
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
                      child: TextFormField(
                        initialValue: article.name,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Artikel eingeben"; // Todo Fix validation
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          article.name = newValue!;
                        },
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Artikel"),
                      ),
                    ),
                    SizedBox(
                      width: _padding,
                    ),
                    ElevatedButton(
                        // Todo fix fit
                        onPressed: () {
                          _submitForm();
                        },
                        child: Text("Add")) // Todo fix visual
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
                          initialValue: article.quantity.toString(),
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
                              article.quantity = int.tryParse(newValue)!;
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
                        value: dropdownValue,
                        items: dropdownItems,
                        onChanged: (value) {
                          setState(() {
                            dropdownValue = value!;
                            article.quantityUnit = value;
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
                  initialValue: article.details,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (value) {
                    _submitForm();
                  },
                  onSaved: (newValue) {
                    article.details = newValue!;
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
