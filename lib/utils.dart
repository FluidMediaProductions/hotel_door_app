import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

NetworkImage makeStaticMap(String loc, String apiKey, int height, int width) {
  var markers = Uri.encodeQueryComponent("color:red|$loc");
  loc = Uri.encodeQueryComponent(loc);
  var url =
      "https://maps.googleapis.com/maps/api/staticmap?center=$loc&zoom=17&size=${width}x$height&scale=2&maptype=roadmap&markers=$markers&key=$apiKey";
  return new NetworkImage(url);
}

String makeMapURL(String loc) {
  loc = Uri.encodeQueryComponent(loc);
  return "https://www.google.com/maps/search/?api=1&query=$loc";
}

launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

Future<String> getJwt() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("jwt");
  return token;
}

Future<Map> getUserInfo() async {
  final claims = await _getJWTPayload();
  return claims["user"];
}

Future<Map> _getJWTPayload() async {
  String jwt = await getJwt();
  final split = jwt.split('.'),
  payload = split[1];
  final decodedPayload = utf8.decode(base64.decode(payload));
  return json.decode(decodedPayload);
}

Future<bool> biometricsRequired() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool biometricsRequired = prefs.getBool("biometrics");
  biometricsRequired =
  (biometricsRequired == null) ? false : biometricsRequired;
  return biometricsRequired;
}

authenticateAction(BuildContext context, Function action) async {
  bool biometrics = await biometricsRequired();
  if (!biometrics) {
    action();
  } else {
    LocalAuthentication localAuth = new LocalAuthentication();
    try {
      bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: "Please authentice",
        stickyAuth: true,
      );

      if (didAuthenticate) {
        action();
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        showDialog(
          context: context,
          barrierDismissible: true,
          child: new AlertDialog(
            title: new Text("Not availabe"),
            content: new Text("Authentication is not available on this device"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }
}