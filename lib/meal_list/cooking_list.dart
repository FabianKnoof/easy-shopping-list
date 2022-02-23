import 'package:easy_shopping_list/db_accesses/cooking_list_hive.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'meal.dart';

class CookingList extends StatefulWidget {
  const CookingList({Key? key}) : super(key: key);

  @override
  _CookingListState createState() => _CookingListState();
}

class _CookingListState extends State<CookingList> {
  final double _padding = 5;

  final CookingListHive _cookingListHive = CookingListHive();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCookingListChecked(),
        Expanded(child: _buildCookingList()),
      ],
    );
  }

  Container _buildCookingListChecked() {
    return Container();
  }

  ValueListenableBuilder<Box<dynamic>> _buildCookingList() {
    return ValueListenableBuilder<Box>(
      valueListenable: _cookingListHive.box.listenable(),
      builder: (context, value, child) {
        return ReorderableListView(
          children: [
            for (Meal meal in _cookingListHive.box.values)
              ExpansionTile(
                title: _buildMeal(meal),
                children: [
                  for (Article ingredient in meal.ingredients)
                    ListTile(
                      title: _buildIngredient(ingredient),
                    )
                ],
              )
          ],
          onReorder: (oldIndex, newIndex) {
            // Todo reorder list
          },
        );
      },
    );
  }

  Row _buildMeal(Meal meal) {
    return Row(
      children: [
        Text(meal.name),
        SizedBox(
          width: _padding,
        ),
        Text(meal.quantity.toString()),
        Text(meal.quantityUnit)
      ],
    );
  }

  Row _buildIngredient(Article ingredient) {
    return Row(
      children: [
        Checkbox(
          value: false, // Todo ingredient shopping list checkbox
          onChanged: (value) {
            // Todo change value of checkbox / check/uncheck
          },
        ),
        Text(ingredient.name),
        SizedBox(
          width: _padding,
        ),
        Text(ingredient.quantity.toString()),
        Text(Article.quantityUnitToString(ingredient.quantityUnit)),
        SizedBox(
          width: _padding,
        ),
        Text(ingredient.details)
      ],
    );
  }
}
