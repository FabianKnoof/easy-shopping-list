import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:easy_shopping_list/db_accesses/shopping_list_hive.dart';
import 'package:easy_shopping_list/general_use_functions.dart';
import 'package:easy_shopping_list/shopping_list/article.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../secrets.dart';

class ListSharingMongoDB with ViewTemplates {
  static final ListSharingMongoDB _listSharingMongoDB =
      ListSharingMongoDB._internal();

  factory ListSharingMongoDB() {
    return _listSharingMongoDB;
  }

  ListSharingMongoDB._internal();

  final String _url =
      "https://data.mongodb-api.com/app/data-jtfko/endpoint/data/beta/action/";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Access-Control-Request-Headers': '*',
    'api-key': apiKeyMongoDB
    // Todo don't do this
  };

  final Map<dynamic, dynamic> _body = {
    "dataSource": "ESLDB",
    "database": "UserLists",
  };

  Map<dynamic, dynamic> _getBodyWithCollection(String collection) {
    Map<dynamic, dynamic> newBody = _body;
    newBody["collection"] = collection;
    return newBody;
  }

  Future<List<dynamic>> _httpPost(
      String action, Map<dynamic, dynamic> body) async {
    Map<dynamic, dynamic> response = await http
        .post(Uri.parse(_url + action),
            headers: _headers, body: jsonEncode(body))
        .then((response) => jsonDecode(utf8.decode(response.bodyBytes))) as Map;
    return response.values.toList();
  }

  Future<int> generateUserCode() async {
    Map<dynamic, dynamic> body = {};
    body = _getBodyWithCollection("UserLists");

    List<dynamic> httpResponse = [];
    int i = 0;
    int userCode = 0;
    do {
      userCode = Random().nextInt(900000) + 100000;
      body["filter"] = {"_id": userCode};
      httpResponse = await _httpPost("findOne", body);
      ++i;
    } while (httpResponse[0] != null && i < 10);
    body.remove("filter");
    if (userCode == 0) return 0;

    body["document"] = {
      "_id": userCode,
      "version": 1,
      "shoppingList": [
        for (ArticleEntry article in ShoppingListHive().shoppingListBox.values)
          article.toJson()
      ]
    };
    _httpPost("insertOne", body);
    body.remove("document");

    return userCode;
  }

  Future<int> getVersion(int userCode) async {
    Map<dynamic, dynamic> body = {};
    body = _getBodyWithCollection("UserLists");

    body["filter"] = {"_id": userCode};
    body["projection"] = {"_id": 0, "version": 1};
    int version = (await _httpPost("findOne", body))[0]["version"];
    body.remove("filter");
    body.remove("projection");
    return version;
  }

  Future<void> pushUpdates(int userCode, int newVersion) async {
    Map<dynamic, dynamic> body = {};
    body = _getBodyWithCollection("UserLists");

    body["filter"] = {"_id": userCode};

    body["update"] = {
      "_id": userCode,
      "version": newVersion,
      "shoppingList": [
        for (ArticleEntry article in ShoppingListHive().shoppingListBox.values)
          article.toJson()
      ]
    };
    await _httpPost("updateOne", body);
    body.remove("filter");
    body.remove("update");
  }

  Future<List<ArticleEntry>> pullUpdates(int userCode) async {
    Map<dynamic, dynamic> body = {};
    body = _getBodyWithCollection("UserLists");

    body["projection"] = {"_id": 0, "shoppingList": 1};
    List<dynamic> response =
        (await _httpPost("find", body))[0][0]["shoppingList"];
    body.remove("projection");
    return [for (dynamic entry in response) ArticleEntry.fromJson(entry)];
  }

  Future<bool> checkIfUserCodeExists(int userCode) async {
    Map<dynamic, dynamic> body = {};
    body = _getBodyWithCollection("UserLists");

    body["filter"] = {"_id": userCode};
    List<dynamic> response = await _httpPost("findOne", body);
    body.remove("filter");
    return response[0] != null;
  }

  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup("data.mongodb-api.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException {
      // No internet connection
      return false;
    }
    return false;
  }
}

class ListSharingHive {
  static final ListSharingHive _listSharingHive = ListSharingHive._internal();

  factory ListSharingHive() {
    return _listSharingHive;
  }

  ListSharingHive._internal();

  static final String listSharingBoxName = "ListSharing";

  final Box listSharingBox = Hive.box(listSharingBoxName);

  bool isSharing() {
    return (listSharingBox.get("userCode") != null);
  }

  int getUserCode() {
    int userCode = listSharingBox.get("userCode")!;
    return userCode;
  }

  Future<void> setUserCode(int userCode) async {
    listSharingBox.put("userCode", userCode);
    listSharingBox.put("version", 0);
  }

  Future<int> generateUserCode() async {
    int userCode = await ListSharingMongoDB().generateUserCode();
    listSharingBox.put("userCode", userCode);
    listSharingBox.put("version", 1);
    return userCode;
  }

  Future<void> pushUpdates() async {
    int newVersion = listSharingBox.get("version")! + 1;
    listSharingBox.put("version", newVersion);
    try {
      int mongoVersion = await ListSharingMongoDB()
          .getVersion(listSharingBox.get("userCode")!);
      if (newVersion > mongoVersion) {
        await ListSharingMongoDB()
            .pushUpdates(listSharingBox.get("userCode")!, newVersion);
      } else {
        await pullUpdates();
      }
    } on SocketException {
      // No internet connection
    }
  }

  Future<void> pullUpdates() async {
    int mongoVersion =
        await ListSharingMongoDB().getVersion(listSharingBox.get("userCode")!);
    if (mongoVersion > listSharingBox.get("version", defaultValue: 0)!) {
      List<ArticleEntry> shoppingList = await ListSharingMongoDB()
          .pullUpdates(listSharingBox.get("userCode"));
      await ShoppingListHive().shoppingListBox.clear();
      for (int indexKey = 0; indexKey < shoppingList.length; ++indexKey) {
        ShoppingListHive()
            .shoppingListBox
            .put(indexKey, shoppingList[indexKey]);
      }
      listSharingBox.put("version", mongoVersion);
    }
  }
}
