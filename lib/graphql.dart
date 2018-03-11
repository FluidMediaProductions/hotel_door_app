
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class GraphQLClient {
  final httpClient = createHttpClient();

  Future<Map> runQuery(String url, String query, Map variables) async {
    String req = JSON.encode({
      "query": query,
      "variables": variables,
    });
    var response = await httpClient.post(
      url,
      body: req,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );
    Map resp = JSON.decode(response.body);
    return resp;
  }
}
