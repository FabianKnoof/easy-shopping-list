import 'package:easy_shopping_list/db_accesses/cooking_list_hive.dart';
import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/general_use_functions.dart';
import 'package:easy_shopping_list/meal_list/add_meal.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'meal.dart';

class CookingList extends StatefulWidget {
  const CookingList({Key? key}) : super(key: key);

  @override
  _CookingListState createState() => _CookingListState();
}

class _CookingListState extends State<CookingList> with ViewTemplates {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [_buildCookingList(), _buildCookingListChecked()],
    );
  }

  ValueListenableBuilder<Box<Meal>> _buildCookingListChecked() {
    return ValueListenableBuilder<Box<Meal>>(
      valueListenable: CookingListHive().cookingListCheckedBox.listenable(),
      builder: (context, value, child) {
        return ExpansionTile(
          leading: Icon(Icons.checklist),
          title: Text(
              "Abgehakt (${CookingListHive().cookingListCheckedBox.length})"),
          children: [
            for (Meal meal in CookingListHive().cookingListCheckedBox.values)
              ExpansionTile(
                leading: _buildCheckbox(meal),
                title: mealRow(meal),
                children: [
                  for (Article ingredient in meal.ingredients)
                    _buildIngredient(ingredient),
                ],
              )
          ].reversed.toList(),
        );
      },
    );
  }

  ValueListenableBuilder<Box<dynamic>> _buildCookingList() {
    return ValueListenableBuilder<Box>(
      valueListenable: CookingListHive().cookingListBox.listenable(),
      builder: (context, value, child) {
        return ReorderableListView(
          reverse: true,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            for (Meal meal in CookingListHive().cookingListBox.values)
              // Todo fix expanded tile not changed based on index when reordering
              ExpansionTile(
                key: Key(meal.key.toString()),
                leading: _buildCheckbox(meal),
                title: _buildMeal(meal),
                children: [
                  for (Article ingredient in meal.ingredients)
                    _buildIngredient(ingredient),
                ],
              )
          ],
          onReorder: (oldIndex, newIndex) {
            setState(() {
              CookingListHive().reorderMealAt(oldIndex, newIndex);
            });
          },
        );
      },
    );
  }

  Checkbox _buildCheckbox(Meal meal) {
    return Checkbox(
      value: (meal.box == CookingListHive().cookingListCheckedBox),
      onChanged: (value) {
        if (value!) {
          CookingListHive().checkMeal(meal);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Abgehakt"),
            action: SnackBarAction(
              label: "Rückgängig",
              onPressed: () {
                CookingListHive().uncheckMeal(meal);
              },
            ),
          ));
        } else {
          CookingListHive().uncheckMeal(meal);
        }
      },
    );
  }

  ListTile _buildMeal(Meal meal) {
    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return EditMealView(
              meal: meal,
            );
          },
        )).then((value) {
          // Todo replace ingredients
          CookingListHive().replaceMeal(meal.key, value);
        });
      },
      title: mealRow(meal),
    );
  }

  ListTile _buildIngredient(Article ingredient) {
    return ListTile(
        leading: Checkbox(
          value: ingredient.isChecked,
          onChanged: (value) {
            setState(() {
              ingredient.isChecked = value!;
              if (value) {
                ShoppingListHive().checkIngredient(ingredient);
              } else {
                ShoppingListHive().addArticle(ingredient);
              }
            });
          },
        ),
        title: articleColumn(ingredient));
  }
}
