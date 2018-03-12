import 'dart:async';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'graphql.dart';
import 'consts.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageState createState() => new SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  final _graphqlClient = new GraphQLClient(GRAPHQL_SERVER_URL);

  @override
  void initState() {
    super.initState();

    _getIsLoggedIn().then((isLoggedIn) {
      if (!isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  Future<bool> _getIsLoggedIn() async {
    String jwt = await getJwt();
    if (jwt != null) {
      String query =
          "query (\$token: String!) {\n"
          "  auth(token: \$token) {\n"
          "    self {\n"
          "      ID\n"
          "    }\n"
          "  }\n"
          "}";
      return _graphqlClient.runQuery(query, {
        "token": jwt,
      }).then((resp) {
        return (resp["data"]["auth"] != null);
      });
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }
}
