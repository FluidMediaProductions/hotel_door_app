import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<Settings> {
  SharedPreferences prefs;

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
    });
  }

  Widget build(BuildContext context) {
    return new ListView(
      children: [
        new ListTile(
          leading: new Icon(Icons.fingerprint),
          title: new Text("Require authentication to open room"),
          onTap: () {
            _handleBiometricsChange(!_biometricsRequired);
          },
          trailing: new Switch(
            value: _biometricsRequired,
            onChanged: _handleBiometricsChange,
          ),
        ),
      ],
    );
  }
}
