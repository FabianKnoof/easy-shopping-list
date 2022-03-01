import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';

mixin buildTemplates {
  final double _padding = 5;

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
