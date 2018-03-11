import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home.dart';
import 'login.dart';
import 'splash.dart';

class HotelDoorApp extends StatefulWidget {
  @override
  HotelDoorAppState createState() => new HotelDoorAppState();
}

class HotelDoorAppState extends State<HotelDoorApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hotel Door App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new Home(),
        '/login': (BuildContext context) => new Login(),
      },
      home: new SplashPage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('en', 'GB'),
      ],
    );
  }
}

void main() {
  debugPaintSizeEnabled = false;
  runApp(new HotelDoorApp());
}
