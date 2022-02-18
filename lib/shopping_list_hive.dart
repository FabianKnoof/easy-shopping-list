import 'package:easy_shopping_list/article.dart';
import 'package:hive/hive.dart';

class ShoppingListHive {
  final _shoppingListBox = Hive.box<Article>("ShoppingList", );
}
