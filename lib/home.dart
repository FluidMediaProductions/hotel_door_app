import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookings.dart';
import 'settings.dart';
import 'utils.dart';

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

  var _pages = {};

  String _currentTitle = "";
  Widget _currentPageWidget;

  @override
  initState() {
    super.initState();

    _pages = {
      "bookings": {
        "title": "Bookings",
        "icon": new Icon(Icons.hotel),
        "widget": new Bookings(),
      },
      "settings": {
        "title": "Settings",
        "icon": new Icon(Icons.settings),
        "widget": new Settings(),
      }
    };

    _getUserInfo();
    _changePage(_pages.keys.first);
  }

  _getUserInfo() async {
    Map userInfo = await getUserInfo();
    setState(() {
      _userInfo = userInfo;
    });
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
      body: _currentPageWidget,
    );
  }
}
