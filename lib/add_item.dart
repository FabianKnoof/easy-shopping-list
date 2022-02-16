import 'dart:developer';

import 'package:flutter/material.dart';

class AddItemView extends StatelessWidget {
  const AddItemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            Align(alignment: Alignment.bottomCenter, child: AddItemStepper()));
  }
}

class Article {
  String name = "";
  String quantity = "";
  String quantityUnit =
      ""; // Todo rework quantityUnit to use sth else than string
  String details = "";
}

class AddItemBottomSheet extends StatefulWidget {
  const AddItemBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final double _padding = 5;

  Article _article = Article();
  GlobalKey<FormState> _addItemFormKey = GlobalKey<FormState>();

  final List<String> dropdownValues = ["stk", "g", "ml"];
  String dropdownValue = "stk";

  void _submitForm() {
    FormState? formState = _addItemFormKey.currentState;

    if (formState == null || !formState.validate()) {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Not valid'),
                content: const Text('Not Valid'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ));
    } else {
      formState.save();
      log("Name: ${_article.name}");
      log("Quantity: ${_article.quantity}");
      log("QuantityUnit: ${_article.quantityUnit}");
      log("Details: ${_article.details}");
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Valid'),
                content: Text(
                    "Name: ${_article.name}, Quantity: ${_article.quantity}, QuantityUnit: ${_article.quantityUnit}, Details: ${_article.details}"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> dropdownItems =
        dropdownValues.map((String unit) {
      return DropdownMenuItem<String>(value: unit, child: Text(unit));
    }).toList();
    _article.quantityUnit = dropdownValues[0];

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
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Artikel eingeben"; // Todo Fix validation
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _article.name = newValue!;
                  },
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Artikel"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(_padding),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          onSaved: (newValue) {
                            _article.quantity = newValue!;
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
                      child: DropdownButtonFormField<String>(
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        value: dropdownValue,
                        items: dropdownItems,
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValue = value!;
                            _article.quantityUnit = value;
                            log("unit " + value);
                            log("unit " + _article.quantityUnit);
                          });
                        },
                      ),
                    ),
                    // DropdownButton<String>(
                    //   // Todo fix focus on dropdown
                    //   value: dropdownValue,
                    //   onChanged: (String? value) {
                    //     setState(() {
                    //       // Todo fix string value weirdness
                    //       dropdownValue = value!;
                    //       _article.quantityUnit = value;
                    //     });
                    //   },
                    //   items: dropdownItems,
                    // )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(_padding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        onSaved: (newValue) {
                          _article.details = newValue!;
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Details"),
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
                        child: Text("Add"))
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class AddItemStepper extends StatefulWidget {
  const AddItemStepper({Key? key}) : super(key: key);

  @override
  _AddItemStepperState createState() => _AddItemStepperState();
}

class _AddItemStepperState extends State<AddItemStepper> {
  int _index = 0;
  String dropdownValue = "stk";
  static Article article = Article();
  FocusNode _focusNode = FocusNode();

  List<DropdownMenuItem<String>> dropdownItems =
      ["stk", "g", "ml"].map((String unit) {
    return DropdownMenuItem<String>(value: unit, child: Text(unit));
  }).toList();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  void nextStep() {
    if (_index < 2) {
      setState(() {
        _index += 1;
      });
    } else if (_index == 2) {
      print(article.name);
    } else {
      Navigator.pop(context);
      // Saving to list
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
          title: Text("Artikel"),
          content: TextFormField(
              focusNode: _focusNode,
              onSaved: (value) {
                article.name = value!;
                nextStep();
              },
              onEditingComplete: nextStep,
              maxLines: 1,
              // validator: (value) {
              //   if (value.isEmpty || value.length < 1) {
              //     return 'Please enter name';
              //   }
              // },
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Artikel"))),
      Step(
          title: Text("Menge"),
          content: Row(
            children: [
              Expanded(
                  child: TextFormField(
                focusNode: _focusNode,
                onSaved: (value) {
                  article.quantity = value!;
                  nextStep();
                },
                onEditingComplete: nextStep,
                maxLines: 1,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Menge"),
              )),
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: dropdownItems,
              )
            ],
          )),
      Step(
          title: const Text("Details"),
          content: TextFormField(
            focusNode: _focusNode,
            onSaved: (value) {
              article.details = value!;
              nextStep();
            },
            maxLines: 1,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Details"),
          ))
    ];

    return Form(
        child: Stepper(
      steps: steps,
      currentStep: _index,
      onStepContinue: nextStep,
      onStepCancel: () {
        Navigator.pop(context);
      },
    ));
  }
}
