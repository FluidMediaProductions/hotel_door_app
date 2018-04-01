import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry/sentry.dart';
import 'home.dart';
import 'login.dart';
import 'splash.dart';
import 'consts.dart';
import 'theme.dart' as theme;

final SentryClient sentry = new SentryClient(dsn: SENTRY_DSN);

class HotelDoorApp extends StatefulWidget {
  @override
  HotelDoorAppState createState() => new HotelDoorAppState();
}

class HotelDoorAppState extends State<HotelDoorApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hotel Door App',
      color: theme.ThemeColours.orange[500],
      theme: theme.customThemeData,
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
  if (const bool.fromEnvironment("dart.vm.product")) {
    FlutterError.onError = (errorDetails) async {
      await sentry.captureException(
          exception: errorDetails.exception,
          stackTrace: errorDetails.stack
      );
    };
    runZoned(() {
      runApp(new HotelDoorApp());
    }, onError: (error, stack) async {
      print(error);
      print(stack);
    await sentry.captureException(
      exception: error,
      stackTrace: stack,
    );
    });
  } else {
    runApp(new HotelDoorApp());
  }
}
