import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookings.dart';
import 'settings.dart';
import 'graphql.dart';
import 'consts.dart';
import 'utils.dart';
import 'main.dart';

class UserInheritedWidget extends InheritedWidget {
  const UserInheritedWidget({Key key, this.user, Widget child})
      : super(key: key, child: child);

  final Map<String, dynamic> user;

  @override
  bool updateShouldNotify(UserInheritedWidget old) {
    return user != old.user;
  }

  static UserInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(UserInheritedWidget);
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  Map _userInfo = {
    "name": "",
    "email": "",
  };
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _graphqlClient = new GraphQLClient(GRAPHQL_SERVER_URL);

  var _pages = {};

  String _currentTitle = "";
  Widget _currentPageWidget;

  @override
  initState() {
    super.initState();

    _getUserInfo();
    _pages = {
      "bookings": {
        "title": "Bookings",
        "icon": new Icon(Icons.hotel),
        "widget": new Bookings(),
      },
      "settings": {
        "title": "Settings",
        "icon": new Icon(Icons.settings),
        "widget": new Settings(
          onUpdate: _getUserInfo,
        ),
      }
    };
    _changePage(_pages.keys.first);
  }

  _getUserInfo() async {
    try {
      String jwt = await getJwt();
      if (jwt != null) {
        String query = "query (\$token: String!) {\n"
            "  auth(token: \$token) {\n"
            "    self {\n"
            "      name\n"
            "      email\n"
            "    }\n"
            "  }\n"
            "}";
        var resp = await _graphqlClient.runQuery(query, {
          "token": jwt,
        });
        setState(() {
          if (resp["data"]["auth"] != null) {
            Map<String, dynamic> self = resp["data"]["auth"]["self"];
            if (self != null) {
              setState(() {
                _userInfo = self;
              });
            } else {
              throw new AssertionError("No data returned");
            }
          } else {
            throw new AssertionError("No data returned");
          }
        });
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

  _changePage(String name) {
    setState(() {
      _currentTitle = _pages[name]["title"];
      _currentPageWidget = _pages[name]["widget"];
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("jwt");
    Navigator.pop(context);
    Navigator.of(context).pushReplacementNamed("/");
  }

  Widget _makeDrawerLinks() {
    var links = <Widget>[];

    links.add(
      new UserAccountsDrawerHeader(
        accountName: new Text(_userInfo["name"]),
        accountEmail: new Text(_userInfo["email"]),
      ),
    );

    _pages.forEach((k, v) {
      links.add(
        new ListTile(
          leading: v["icon"],
          title: new Text(v["title"]),
          onTap: () {
            _changePage(k);
            Navigator.pop(context);
          },
        ),
      );
    });

    links.add(new Divider());

    links.add(
      new ListTile(
        leading: new Icon(Icons.power_settings_new),
        title: new Text("Logout"),
        onTap: () {
          _logout();
        },
      ),
    );

    return new ListView(
      padding: EdgeInsets.zero,
      children: links,
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_currentTitle),
      ),
      drawer: new Drawer(
        child: _makeDrawerLinks(),
      ),
      body: new UserInheritedWidget(
        user: _userInfo,
        child: _currentPageWidget,
      ),
    );
  }
}
