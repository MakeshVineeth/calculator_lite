import 'package:flutter/material.dart';
import 'package:charcode/charcode.dart' as charcode;

class FixedValues {
  static String upperArrow = '\u2191';
  static String backSpaceChar = '\u2190';
  static String multiplyChar = 'x';
  static String changeSignChar = '\u207A/-';
  static String decimalChar = '\u00B7';
  static String cubeRoot = '\u00B3√x';
  static String squareChar = 'x\u00B2';
  static String capChar = '\u005E';
  static String reciprocalChar =
      String.fromCharCodes([charcode.$sup1, charcode.$division, charcode.$x]);
  static String divisionChar = String.fromCharCode(charcode.$divide);

  static List rowSimple = [
    [upperArrow, 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar],
    [4, 5, 6, '-'],
    [1, 2, 3, '+'],
    [changeSignChar, 0, decimalChar, '=']
  ];

  static List rowExtras = [
    ['↓', 'i', 'e', '%'],
    ['sin', 'cos', 'tan', 'inv'],
    ['ln', 'log', 'mod', reciprocalChar],
    ['(', ')', '!', '√'],
    ['π', cubeRoot, capChar, squareChar]
  ];

  static ThemeData lightTheme() {
    Color background = Colors.white;
    Color foreground = Colors.red; // For highlighted buttons.
    return ThemeData(
      primaryColor: foreground,
      primarySwatch: foreground,
      accentColor: foreground,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      buttonColor: background,
      bottomAppBarColor: background,
      backgroundColor: background,
      canvasColor: background, // Makes bottomNavBG white along with scaffoldBG
    );
  }

  static ThemeData darkTheme() {
    Color foreground = Colors.yellow; // For highlighted buttons.
    return ThemeData(
      primaryColor:
          foreground, // For Dark, primary Color has to be set, otherwise issues with foreground text for Calc Buttons.
      primarySwatch: foreground,
      accentColor: foreground,
      brightness: Brightness.dark,
      buttonColor: Colors.grey[900],
    );
  }
}
