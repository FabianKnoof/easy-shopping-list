import 'package:flutter/cupertino.dart';

class MealList extends StatelessWidget {
  const MealList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Gerichteliste",
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}
