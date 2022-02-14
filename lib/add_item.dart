import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddItemView extends StatelessWidget {
  const AddItemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AddItemStepper();
  }
}

class AddItemStepper extends StatefulWidget {
  const AddItemStepper({Key? key}) : super(key: key);

  @override
  _AddItemStepperState createState() => _AddItemStepperState();
}

class _AddItemStepperState extends State<AddItemStepper> {
  int _index = 0;
  String dropdownValue = "g";

  void nextStep() {
    if (_index < 2) {
      setState(() {
        _index += 1;
      });
    } else {
      Navigator.pop(context);
      // Saving to list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
            alignment: Alignment.bottomCenter,
            child: Stepper(
                currentStep: _index,
                onStepCancel: () {
                  Navigator.pop(context);
                },
                onStepContinue: nextStep,
                steps: <Step>[
                  Step(
                      title: const Text("Artikel"),
                      content: TextField(
                        // inputFormatters: [],
                        onSubmitted: (value) {
                          nextStep();
                          // Do sth with value
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Artikel"),
                      )),
                  Step(
                    title: const Text("Menge"),
                    content: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          // inputFormatters: [],
                          onSubmitted: (value) {
                            nextStep();
                            // Do sth with value
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "Menge"),
                        )),
                        DropdownButton<String>(
                            value: dropdownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: <String>["g", "ml", "stk"]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList()),
                      ],
                    ),
                  ),
                  Step(
                      title: const Text("Details"),
                      content: TextField(
                        // inputFormatters: [],
                        onSubmitted: (value) {
                          nextStep();
                          // Do sth with value
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Details"),
                      ))
                ])));
  }
}
