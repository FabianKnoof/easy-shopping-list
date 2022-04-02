import 'dart:convert';

import 'package:easy_shopping_list/db_accesses/list_sharing.dart';
import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/secrets.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:http/http.dart' as http;

class SuggestionsMongoDB {
  static final String _url =
      "https://data.mongodb-api.com/app/data-jtfko/endpoint/data/beta/action/";

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Access-Control-Request-Headers': '*',
    'api-key': apiKeyMongoDB
  };

  static final Map<dynamic, dynamic> _bodySuggestions = {
    "dataSource": "ESLDB",
    "database": "Suggestions",
  };

  static Map<dynamic, dynamic> _getBodyWithCollection(String collection) {
    Map<dynamic, dynamic> newBody = _bodySuggestions;
    newBody["collection"] = collection;
    return newBody;
  }

  static Future<List<dynamic>> _httpPost(
      String action, Map<dynamic, dynamic> body) async {
    Map<dynamic, dynamic> response = await http
        .post(Uri.parse(_url + action),
            headers: _headers, body: jsonEncode(body))
        .then((response) => jsonDecode(utf8.decode(response.bodyBytes))) as Map;
    return response.values.toList();
  }

  static Future<void> syncSuggestions() async {
    if (!(await ListSharingMongoDB().hasConnection())) return;

    Map<dynamic, dynamic> body = _getBodyWithCollection("VersionsSuggestions");
    body["projection"] = {
      "_id": 0,
      "articleSuggestions": 1,
      "mealSuggestions": 1
    };
    List<dynamic> response = (await _httpPost("find", body))[0];
    body.remove("projection");

    Map<dynamic, dynamic> version = {};
    for (var element in response) {
      version[element.keys.toList()[0]] = element.values.toList()[0];
    }

    if (version["articleSuggestions"] >
        SuggestionsHive()
            .versionsBox
            .get("articleSuggestions", defaultValue: 0)) {
      await SuggestionsHive().articleBox.clear();
      SuggestionsHive().articleBox.addAll(await _getArticleSuggestions());
      SuggestionsHive()
          .versionsBox
          .put("articleSuggestions", version["articleSuggestions"]);
    }
    if (version["mealSuggestions"] >
        SuggestionsHive().versionsBox.get("mealSuggestions", defaultValue: 0)) {
      await SuggestionsHive().mealBox.clear();
      SuggestionsHive().mealBox.addAll(await _getMealSuggestions());
      SuggestionsHive()
          .versionsBox
          .put("mealSuggestions", version["mealSuggestions"]);
    }
  }

  static _getMealSuggestions() async {
    Map<dynamic, dynamic> body = _getBodyWithCollection("MealSuggestions");
    body["projection"] = {"_id": 0};
    List<dynamic> response = (await _httpPost("find", body))[0];
    body.remove("projection");

    List<Meal> mealSuggestions = [];
    for (Map<String, dynamic> meal in response) {
      mealSuggestions.add(Meal.fromJson(meal));
    }

    return mealSuggestions;
  }

  static Future<Iterable<Article>> _getArticleSuggestions() async {
    Map<dynamic, dynamic> body = _getBodyWithCollection("ArticleSuggestions");
    body["projection"] = {"_id": 0};
    List<dynamic> response = (await _httpPost("find", body))[0];
    body.remove("projection");

    List<Article> articleSuggestions = [];
    for (Map<String, dynamic> article in response) {
      articleSuggestions.add(Article()
        ..name = article["article"]
        ..isIngredient = article["isIngredient"]);
    }
    return articleSuggestions;
  }

  static Future<bool> tryAddUserMealSuggestion(Meal meal) async {
    Map<dynamic, dynamic> body = _getBodyWithCollection("UserMealSuggestions");
    body["filter"] = {"name": meal.name};
    List<dynamic> httpResponse = await _httpPost("findOne", body);
    body.remove("filter");
    if (httpResponse[0] != null) return false;

    body["document"] = meal.toJson();
    _httpPost("insertOne", body);
    body.remove("document");
    return true;
  }

  static Future<bool> tryAddUserArticleSuggestion(Article article) async {
    Map<dynamic, dynamic> body =
        _getBodyWithCollection("UserArticleSuggestions");
    body["filter"] = {"article": article.name};
    List<dynamic> httpResponse = await _httpPost("findOne", body);
    body.remove("filter");
    if (httpResponse[0] != null) return false;

    body["document"] = {
      "article": article.name,
      "isIngredient": article.isIngredient
    };
    _httpPost("insertOne", body);
    body.remove("document");
    return true;
  }
}
