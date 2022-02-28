import 'dart:convert';
import 'dart:developer';

import 'package:easy_shopping_list/db_accesses/suggestions_hive.dart';
import 'package:easy_shopping_list/meal_list/meal.dart';
import 'package:easy_shopping_list/secrets.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class SuggestionsMongoDB {
  static final String _url =
      "https://data.mongodb-api.com/app/data-jtfko/endpoint/data/beta/action/";

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Access-Control-Request-Headers': '*',
    'api-key': apiKeyMongoDB
    // Todo don't do this
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
        VersionsSuggestionsHive()
            .box
            .get("articleSuggestions", defaultValue: 0)) {
      log("Article suggestions update available");
      await ArticleSuggestionsHive().box.clear();
      ArticleSuggestionsHive().box.addAll(await _getArticleSuggestions());
      VersionsSuggestionsHive()
          .box
          .put("articleSuggestions", version["articleSuggestions"]);

      log("Article suggestions updated");
    }
    if (version["mealSuggestions"] >
        VersionsSuggestionsHive().box.get("mealSuggestions", defaultValue: 0)) {
      log("Meal suggestions update available");
      await MealSuggestionsHive().box.clear();
      MealSuggestionsHive().box.addAll(await _getMealSuggestions());
      VersionsSuggestionsHive()
          .box
          .put("mealSuggestions", version["mealSuggestions"]);
      log("Meal suggestions updated");
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

  static Future<bool> insertUserMealSuggestion(Meal meal) async {
    Map<dynamic, dynamic> body = _getBodyWithCollection("UserMealSuggestions");
    // Note case insensitivity
    // Note check if meal already exists in Suggestion List
    body["filter"] = {"name": meal.name};
    List<dynamic> httpResponse = await _httpPost("findOne", body);
    body.remove("filter");
    if (httpResponse[0] != null) return false;

    body["document"] = meal.toJson();
    _httpPost("insertOne", body);
    body.remove("document");
    return true;
  }

  static Future<bool> insertUserArticleSuggestion(Article article) async {
    Map<dynamic, dynamic> body =
        _getBodyWithCollection("UserArticleSuggestions");
    // Note case insensitivity
    // Note check if article already exists in Suggestion List
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

class MongoDBAccess {
  static final String _url =
      "https://data.mongodb-api.com/app/data-jtfko/endpoint/data/beta/action";

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Access-Control-Request-Headers': '*',
    'api-key': apiKeyMongoDB
    // Todo don't do this
  };

  static final Map<dynamic, dynamic> _bodyArticleSuggestions = {
    "dataSource": "ESLDB",
    "database": "Suggestions",
    "collection": "ArticleSuggestions"
  };

  static Future<List<String>> getSuggestions() async {
    Map<dynamic, dynamic> body = _bodyArticleSuggestions;
    body["projection"] = {"_id": 0, "Suggestion": 1};

    var response = await http.post(Uri.parse(_url + "/find"),
        headers: _headers, body: jsonEncode(body));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List documentsResponse = decodedResponse["documents"];
    documentsResponse.removeWhere((element) => element.isEmpty);
    List<String> suggestions =
        documentsResponse.map((e) => e["Suggestion"] as String).toList();
    return suggestions;
  }

  static void syncArticleSuggestions() async {
    Map<dynamic, dynamic> body = _bodyArticleSuggestions;
    body["projection"] = {"_id": 0, "Version": 1};

    var response = await http.post(Uri.parse(_url + "/findOne"),
        headers: _headers, body: jsonEncode(body));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    int version = decodedResponse["document"]["Version"];

    if (version >
        Hive.box("Suggestions")
            .get("VersionArticleSuggestions", defaultValue: 0)) {
      log("Suggestions update available");
      Hive.box("Suggestions").put("ArticleSuggestions", await getSuggestions());
      Hive.box("Suggestions").put("VersionArticleSuggestions", version);
    }
  }
}
