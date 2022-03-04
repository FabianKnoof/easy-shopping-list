import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';

import 'meal_list/meal.dart';

mixin ViewTemplates {
  final double _padding = 5;

  Future<dynamic> queryUser(
      {required BuildContext context,
      required String question,
      required String positiveAnswer,
      String? negativeAnswer}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(question),
          actions: [
            if (negativeAnswer != null)
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(negativeAnswer)),
            TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(positiveAnswer))
          ],
        );
      },
    );
  }

  Row mealRow(Meal meal) {
    return Row(
      children: [
        Flexible(fit: FlexFit.loose, child: Text(meal.name)),
        SizedBox(
          width: _padding,
        ),
        Text(meal.quantity.toString()),
        Text(meal.quantityUnit)
      ],
    );
  }

  Column articleColumn(Article article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  article.name,
                ),
              ),
              if (article.quantity != 0) ...[
                SizedBox(
                  width: _padding,
                ),
                Text(article.quantity.toString()),
                Text(article.quantityUnitAsString()),
              ]
            ],
          ),
        ),
        if (article.details.isNotEmpty)
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              article.details,
            ),
          )
      ],
    );
  }

  InputDecoration textFieldInputDecoration(String labelText) =>
      InputDecoration(border: OutlineInputBorder(), labelText: labelText);
}
