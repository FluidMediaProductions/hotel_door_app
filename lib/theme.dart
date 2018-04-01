import 'package:flutter/material.dart';

final ThemeData customThemeData = new ThemeData(
    brightness: Brightness.light,
    primaryColor: ThemeColours.orange[500],
    primarySwatch: ThemeColours.orange,
    primaryColorBrightness: Brightness.light,
);

class ThemeColours {
  ThemeColours._();
  
  static const _orange = 0xfff57e1c;

  static const MaterialColor orange =  const MaterialColor(
      _orange,
      const <int, Color>{
        50: const Color(0xff180c01),
        100: const Color(0xff311702),
        200: const Color(0xff622e04),
        300: const Color(0xff934506),
        400: const Color(0xffc45d08),
        500: const Color(_orange),
        600: const Color(0xfff7903b),
        700: const Color(0xfff9ab6c),
        800: const Color(0xfffbc79d),
        900: const Color(0xfffde3ce),
      },
  );
}