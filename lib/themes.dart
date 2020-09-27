import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color.fromRGBO(48, 48, 48, 1),
    primaryColorLight: const Color.fromRGBO(66, 66, 66, 1),
    primaryColorDark: const Color.fromRGBO(48, 48, 48, 1),
    accentColor: const Color.fromRGBO(255, 109, 105, 1),
    cursorColor: const Color.fromRGBO(0, 0, 0, 1),
    textSelectionHandleColor: const Color.fromRGBO(0, 0, 0, 1),
    toggleableActiveColor: Color.fromRGBO(255, 109, 105, 1),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromRGBO(48, 48, 48, 1),
    accentColor: const Color.fromRGBO(205, 109, 105, 1),
    cursorColor: const Color.fromRGBO(255, 255, 255, 1),
    textSelectionHandleColor: const Color.fromRGBO(255, 255, 255, 1),
    toggleableActiveColor: Color.fromRGBO(255, 109, 105, 1),
  );
}
