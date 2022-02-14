import 'package:flutter/material.dart';

class ShoppingListView extends StatelessWidget {
  const ShoppingListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.topLeft, child: ShoppingList());
  }
}

class ShoppingList extends StatelessWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(columnSpacing: 5, columns: const <DataColumn>[
        DataColumn(label: Text("")),
        DataColumn(label: Text("Artikel")),
        DataColumn(label: Text("Menge")),
        DataColumn(label: Text("Details")),
      ], rows: const <DataRow>[
        DataRow(cells: <DataCell>[
          DataCell(CheckboxWidget()),
          DataCell(Text("Joghurt")),
          DataCell(Text("200g")),
          DataCell(Text("Gut&Günstig")),
        ]),
        DataRow(cells: <DataCell>[
          DataCell(CheckboxWidget()),
          DataCell(Text("Spaghetti")),
          DataCell(Text("400g")),
          DataCell(Text("Weizen")),
        ]),
        DataRow(cells: <DataCell>[
          DataCell(CheckboxWidget()),
          DataCell(Text("Tomatensauce")),
          DataCell(Text("400ml")),
          DataCell(Text("Bio")),
        ])
      ]),
    );
  }
}

class CheckboxWidget extends StatefulWidget {
  const CheckboxWidget({Key? key}) : super(key: key);

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}
