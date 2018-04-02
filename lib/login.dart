import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'graphql.dart';
import 'consts.dart';
import 'main.dart';
import 'theme.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<Login> {
  final _graphqlClient = new GraphQLClient(GRAPHQL_SERVER_URL);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _email, _password;
  final _formKey = new GlobalKey<FormState>();
  final _emailRegexp = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  void _submit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      bool loginSuccess = await login();
      if (!loginSuccess) {
        _scaffoldKey.currentState.showSnackBar(
          new SnackBar(
            content: new Text("Login failed"),
          ),
        );
      } else {
        Navigator.of(context).pushReplacementNamed("/home");
      }
    }
  }

  Future<bool> login() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String query = "mutation (\$email: String!, \$pass: String!) {"
          "loginUser(email: \$email, pass: \$pass)"
          "}";
      var resp = await _graphqlClient.runQuery(query, {
        "email": _email,
        "pass": _password,
      });
      if (resp["data"]["loginUser"] != null) {
        prefs.setString("jwt", resp["data"]["loginUser"]);
        return true;
      } else {
        prefs.remove("jwt");
        return false;
      }
    } catch (error, stack) {
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text("Something went wrong"),
        ),
      );
      if (const bool.fromEnvironment("dart.vm.product")) {
        await sentry.captureException(
          exception: error,
          stackTrace: stack,
        );
      }
      return false;
    }
  }

  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context).copyWith(
          hintColor: Colors.white,
        );

    return new Theme(
      data: theme,
      child: new Scaffold(
        key: _scaffoldKey,
        body: new Container(
          color: customThemeData.primaryColor,
          padding: const EdgeInsets.all(24.0),
          child: new Center(
            child: new Form(
              key: _formKey,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new TextFormField(
                    validator: (value) => !_emailRegexp.hasMatch(value)
                        ? 'Not a valid email.'
                        : null,
                    onSaved: (val) => _email = val,
                    decoration: new InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  new TextFormField(
                    validator: (value) =>
                        value == "" ? 'Enter a password' : null,
                    onSaved: (val) => _password = val,
                    decoration: new InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  new Container(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: new RaisedButton(
                      onPressed: _submit,
                      child: new Text(
                        'LOGIN',
                        style: const TextStyle(color: Colors.white),
                      ),
                      color: ThemeColours.orange[700],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: double.INFINITY,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
