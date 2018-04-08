import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart';
import 'graphql.dart';
import 'consts.dart';
import 'main.dart';
import 'home.dart';

class _SettingsCategory extends StatelessWidget {
  const _SettingsCategory({Key key, this.icon, this.children})
      : super(key: key);

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(color: themeData.dividerColor))),
      child: new DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: new SafeArea(
          top: false,
          bottom: false,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  width: 72.0,
                  child: new Icon(icon, color: themeData.primaryColor)),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  _SettingsItem({Key key, this.trailing, this.lines, this.tooltip})
      : super(key: key);

  final Widget trailing;
  final List<String> lines;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    List<Widget> columnChildren;
    if (lines.length != 1) {
      columnChildren = lines
          .sublist(0, lines.length - 1)
          .map((String line) => new Text(line))
          .toList();
      columnChildren
          .add(new Text(lines.last, style: themeData.textTheme.caption));
    } else {
      columnChildren = lines.map((String line) => new Text(line)).toList();
    }

    final List<Widget> rowChildren = <Widget>[
      new Expanded(
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren))
    ];
    if (trailing != null) {
      rowChildren.add(new SizedBox(
        width: 72.0,
        child: trailing,
      ));
    }
    return new MergeSemantics(
      child: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowChildren)),
    );
  }
}

class Settings extends StatefulWidget {
  Settings({this.onUpdate});

  final Function onUpdate;

  @override
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<Settings> {
  SharedPreferences prefs;
  final _graphqlClient = new GraphQLClient(GRAPHQL_SERVER_URL);

  bool _biometricsRequired = false;

  setup() async {
    prefs = await SharedPreferences.getInstance();
    bool biometrics = await biometricsRequired();

    setState(() {
      _biometricsRequired = biometrics;
    });
  }

  @override
  initState() {
    super.initState();

    setup();
  }

  _handleBiometricsChange(bool state) async {
    authenticateAction(context, () {
      setState(() {
        _biometricsRequired = state;
        prefs.setBool("biometrics", _biometricsRequired);
      });
    }, true);
  }

  _changePassword() async {
    final _formKey = new GlobalKey<FormState>();
    String _password;
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        title: const Text('Enter new password'),
        content: new Form(
          key: _formKey,
          child: new TextFormField(
            validator: (value) => value == "" ? 'Enter a password' : null,
            onSaved: (val) => _password = val,
            obscureText: true,
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Save'),
            onPressed: () {
              final form = _formKey.currentState;
              if (form.validate()) {
                form.save();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
    if (_password != null) {
      try {
        String query = "mutation (\$token: String!, \$pass: String!) {\n"
            "  auth(token: \$token) {\n"
            "    changePassword(pass: \$pass)\n"
            "  }\n"
            "}";
        var resp = await _graphqlClient.runQuery(query, {
          "token": await getJwt(),
          "pass": _password,
        });
        if (resp["data"]["auth"]["changePassword"] != "true") {
          Scaffold.of(context).showSnackBar(
                new SnackBar(
                  content: new Text("Something went wrong"),
                ),
              );
        } else {
          widget.onUpdate();
        }
      } catch (error, stack) {
        Scaffold.of(context).showSnackBar(
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
      }
    }
  }

  _changeName(String orig) async {
    final _formKey = new GlobalKey<FormState>();
    String _name;
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        title: const Text('Enter new name'),
        content: new Form(
          key: _formKey,
          child: new TextFormField(
            validator: (value) => value == "" ? 'Enter a name' : null,
            onSaved: (val) => _name = val,
            initialValue: orig,
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Save'),
            onPressed: () {
              final form = _formKey.currentState;
              if (form.validate()) {
                form.save();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
    if (_name != null) {
      try {
        String query = "mutation (\$token: String!, \$name: String!) {\n"
            "  auth(token: \$token) {\n"
            "    updateUser(name: \$name)\n"
            "  }\n"
            "}";
        var resp = await _graphqlClient.runQuery(query, {
          "token": await getJwt(),
          "name": _name,
        });
        if (resp["data"]["auth"]["updateUser"] != "true") {
          Scaffold.of(context).showSnackBar(
                new SnackBar(
                  content: new Text("Something went wrong"),
                ),
              );
        } else {
          widget.onUpdate();
        }
      } catch (error, stack) {
        print(error);
        Scaffold.of(context).showSnackBar(
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
      }
    }
  }

  _changeEmail(String orig) async {
    final _formKey = new GlobalKey<FormState>();
    String _email;
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        title: const Text('Enter new email'),
        content: new Form(
          key: _formKey,
          child: new TextFormField(
            validator: (value) => value == "" ? 'Enter a email' : null,
            onSaved: (val) => _email = val,
            initialValue: orig,
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Save'),
            onPressed: () {
              final form = _formKey.currentState;
              if (form.validate()) {
                form.save();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
    if (_email != null) {
      try {
        String query = "mutation (\$token: String!, \$email: String!) {\n"
            "  auth(token: \$token) {\n"
            "    updateUser(email: \$email)\n"
            "  }\n"
            "}";
        var resp = await _graphqlClient.runQuery(query, {
          "token": await getJwt(),
          "email": _email,
        });
        if (resp["data"]["auth"]["updateUser"] != "true") {
          Scaffold.of(context).showSnackBar(
                new SnackBar(
                  content: new Text("Something went wrong"),
                ),
              );
        } else {
          widget.onUpdate();
        }
      } catch (error, stack) {
        Scaffold.of(context).showSnackBar(
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
      }
    }
  }

  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Map userInfo = UserInheritedWidget.of(context).user;

    return new ListView(
      children: [
        new _SettingsCategory(
          icon: Icons.person,
          children: [
            new _SettingsItem(
              lines: <String>[
                userInfo["name"],
                'Name',
              ],
              trailing: new IconButton(
                icon: new Icon(
                  Icons.edit,
                ),
                onPressed: () {
                  _changeName(userInfo["name"]);
                },
              ),
            ),
            new _SettingsItem(
              lines: <String>[
                userInfo["email"],
                'Email',
              ],
              trailing: new IconButton(
                icon: new Icon(
                  Icons.edit,
                ),
                onPressed: () {
                  _changeEmail(userInfo["email"]);
                },
              ),
            ),
          ],
        ),
        new _SettingsCategory(
          icon: Icons.lock,
          children: [
            new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new RaisedButton(
                color: themeData.primaryColor,
                child: new Text("Change password"),
                onPressed: _changePassword,
              ),
            ),
          ],
        ),
        new _SettingsCategory(
          icon: Icons.fingerprint,
          children: [
            new _SettingsItem(
              lines: const <String>[
                'Require authentication to open room',
              ],
              trailing: new Switch(
                value: _biometricsRequired,
                onChanged: _handleBiometricsChange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
