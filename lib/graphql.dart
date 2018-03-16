import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class GraphQlException implements Exception {
  List<String> errors;
  GraphQlException(this.errors);
}

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
    if (resp["errors"] != null) {
      List errors = resp["errors"];
      throw new GraphQlException(errors.map((v) {
        return v["message"];
      }).toList());
    }
    return resp;
  }
}
