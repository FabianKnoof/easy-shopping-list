import 'dart:convert';
import 'dart:developer';

import 'package:easy_shopping_list/secrets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

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

    log("Check if suggestions sync ist needed");
    if (version > Hive.box("Suggestions").get("VersionArticleSuggestions")) {
      log("Suggestions update available");
      Hive.box("Suggestions").put("ArticleSuggestions", await getSuggestions());
      Hive.box("Suggestions").put("VersionArticleSuggestions", version);
    }
  }
}
