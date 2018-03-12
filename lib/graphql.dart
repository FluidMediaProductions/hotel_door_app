
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class GraphQLClient {
  GraphQLClient(this.endpoint);

  final httpClient = createHttpClient();
  final String endpoint;

  Future<Map> runQuery(String query, Map variables) async {
    String req = JSON.encode({
      "query": query,
      "variables": variables,
    });
    var response = await httpClient.post(
      this.endpoint,
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
