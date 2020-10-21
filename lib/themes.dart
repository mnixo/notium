import 'package:flutter/material.dart';

class Themes {

  static final appTextTheme = const TextTheme(
  bodyText1: TextStyle(fontSize: 16.0), // Used for drawer
  bodyText2: TextStyle(fontSize: 16.0), // Used for note view mode
  headline6: TextStyle(fontSize: 18.0), // Used for note title
  subtitle1: TextStyle(fontSize: 18.0), // Used for note content
  button: TextStyle(fontSize: 16.0),
  );

  static final appFontFamily = "IBMPlexSans-Extralight";

  static final light = ThemeData(
    brightness: Brightness.light,
    fontFamily: appFontFamily,
    primaryColor: const Color.fromRGBO(255, 255, 255, 1),
    primaryColorLight: const Color.fromRGBO(213, 213, 213, 1),
    primaryColorDark: const Color.fromRGBO(213, 213, 213, 1),
    accentColor: const Color.fromRGBO(0, 119, 145, 0.8),
    cursorColor: const Color.fromRGBO(0, 0, 0, 1),
    textSelectionHandleColor: const Color.fromRGBO(0, 0, 0, 1),
    toggleableActiveColor: Color.fromRGBO(0, 119, 145, 1),
    selectedRowColor: const Color.fromRGBO(184, 184, 184, 1),
    focusColor: const Color.fromRGBO(255, 255, 255, 1),
    bottomAppBarColor: const Color.fromRGBO(255, 255, 255, 1),
    textTheme: appTextTheme,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: appFontFamily,
    primaryColor: const Color.fromRGBO(48, 48, 48, 1),
    primaryColorLight: const Color.fromRGBO(48, 48, 48, 1),
    primaryColorDark: const Color.fromRGBO(48, 48, 48, 1),
    accentColor: const Color.fromRGBO(0, 119, 145, 0.8),
    cursorColor: const Color.fromRGBO(255, 255, 255, 1),
    textSelectionHandleColor: const Color.fromRGBO(255, 255, 255, 1),
    toggleableActiveColor: Color.fromRGBO(0, 119, 145, 1),
    selectedRowColor: const Color.fromRGBO(66, 66, 66, 1),
    focusColor: const Color.fromRGBO(255, 255, 255, 1),
    bottomAppBarColor: const Color.fromRGBO(48, 48, 48, 1),
    buttonColor: const Color.fromRGBO(66, 66, 66, 1),
    textTheme: appTextTheme,
  );
}
