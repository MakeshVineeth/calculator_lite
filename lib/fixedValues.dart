import 'package:flutter/material.dart';
import 'package:charcode/charcode.dart' as charcode;

class FixedValues {
  // Set Symbols from Flutter CharCode Library and Static to access across all files.
  static String upperArrow = String.fromCharCode(charcode.$uarr);
  static String downArrow = String.fromCharCode(charcode.$darr);
  static String backSpaceChar = String.fromCharCode(charcode.$larr);
  static String multiplyChar = String.fromCharCode(charcode.$x);
  static String changeSignChar =
      '\u207A/-'; // superscript + is not present in charcode library.
  static String decimalChar = String.fromCharCode(charcode.$middot);
  static String capChar = String.fromCharCode(charcode.$hat);
  static String divisionChar = String.fromCharCode(charcode.$divide);
  static String root = String.fromCharCode(charcode.$radic);
  static String pi = String.fromCharCode(charcode.$pi);
  static String sup2 = String.fromCharCode(charcode.$sup2);
  static String squareChar = String.fromCharCode(charcode.$x) + sup2;
  static String reciprocalChar =
      String.fromCharCodes([charcode.$sup1, charcode.$division, charcode.$x]);
  static String cubeRoot =
      String.fromCharCodes([charcode.$sup3, charcode.$radic, charcode.$x]);
  static String minus = String.fromCharCode(charcode.$ndash);

  static List rowSimple = [
    [upperArrow, 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar],
    [4, 5, 6, minus],
    [1, 2, 3, '+'],
    [changeSignChar, 0, decimalChar, '=']
  ];

  static List rowExtras = [
    [downArrow, 'i', 'e', '%'],
    ['sin', 'cos', 'tan', 'inv'],
    ['ln', 'log', 'mod', reciprocalChar],
    ['(', ')', '!', root],
    [pi, cubeRoot, capChar, squareChar]
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
