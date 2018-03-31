import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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