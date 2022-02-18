import 'dart:convert';
import 'dart:developer';

import 'package:easy_shopping_list/secrets.dart';
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

  static final Map<dynamic, dynamic> _bodyArticleCollection = {
    "collection": "Artikel",
    "database": "FoodData",
    "dataSource": "ESLDB",
  };

  static Future<List> getSuggestions() async {
    Map<dynamic, dynamic> body = _bodyArticleCollection;
    body["projection"] = {"_id": 0, "Apfel": 1};
    var response = await http.post(Uri.parse(_url + "/find"),
        headers: _headers, body: jsonEncode(body));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List<dynamic> documentsResponse = decodedResponse["documents"];
    List suggestions = documentsResponse.map((e) => e["Apfel"]).toList();
    log("Get suggestions");
    return suggestions;
  }
}
