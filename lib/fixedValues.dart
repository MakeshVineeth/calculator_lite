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
  static String sup3 = String.fromCharCode(charcode.$sup3);
  static String squareChar = String.fromCharCode(charcode.$x) + sup2;
  static String cubeChar = String.fromCharCode(charcode.$x) + sup3;
  static String reciprocalChar = '⅟𝑥';
  static String cubeRoot =
      String.fromCharCodes([charcode.$sup3, charcode.$radic, charcode.$x]);
  static String minus = String.fromCharCode(charcode.$ndash);
  static String cubeRootSym =
      String.fromCharCodes([charcode.$sup3, charcode.$radic]);
  static String invButton = 'inv';

  static String buyRoute = '/buy';

  static List<List<dynamic>> rowSimple = [
    [upperArrow, 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar],
    [4, 5, 6, minus],
    [1, 2, 3, '+'],
    [changeSignChar, 0, decimalChar, '=']
  ];

  static List<List<dynamic>> rowExtras = [
    [downArrow, invButton, 'e', '%'],
    ['sin', 'cos', 'tan', cubeChar],
    ['ln', 'log', 'mod', reciprocalChar],
    ['(', ')', '!', root],
    [pi, cubeRoot, capChar, squareChar]
  ];

  static List<List<dynamic>> rowInverse = [
    [downArrow, invButton, 'e', '%'],
    ['sin⁻¹', 'cos⁻¹', 'tan⁻¹', cubeChar],
    ['eˣ', '𝟏𝟬ˣ', 'mod', reciprocalChar],
    ['(', ')', '!', root],
    [pi, cubeRoot, capChar, squareChar]
  ];

  static List<List<dynamic>> horizontalLayout = [
    ['eˣ', '𝟏𝟬ˣ', invButton, 'e', '%', 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar, 'sin', 'cos', 'tan', cubeChar],
    [4, 5, 6, minus, 'ln', 'log', 'mod', reciprocalChar],
    [1, 2, 3, '+', '(', ')', '!', root],
    [changeSignChar, 0, decimalChar, '=', pi, cubeRoot, capChar, squareChar]
  ];

  static List<List<dynamic>> horizontalLayoutInverse = [
    ['eˣ', '𝟏𝟬ˣ', invButton, 'e', '%', 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar, 'sin⁻¹', 'cos⁻¹', 'tan⁻¹', cubeChar],
    [4, 5, 6, minus, 'ln', 'log', 'mod', reciprocalChar],
    [1, 2, 3, '+', '(', ')', '!', root],
    [changeSignChar, 0, decimalChar, '=', pi, cubeRoot, capChar, squareChar]
  ];

  static ThemeData getTotalData(Brightness brightness) {
    bool isLight = brightness == Brightness.light;
    Color foreground = isLight ? Colors.red : Colors.yellow;
    Color background = isLight ? Colors.white : Colors.grey[900];
    Color backgroundScaffold = isLight ? background : Colors.black;

    return ThemeData(
      brightness: brightness,
      primaryColor:
          foreground, // For Dark, primary Color has to be set, otherwise issues with foreground text for Calc Buttons.
      primarySwatch: foreground,
      accentColor: foreground,
      buttonColor: background,
      scaffoldBackgroundColor: backgroundScaffold,
      bottomAppBarColor: backgroundScaffold,
      backgroundColor: backgroundScaffold,
      iconTheme: IconThemeData(color: foreground),
      cardTheme: CardTheme(
        color: background,
        elevation: isLight ? 2.0 : 10.0,
        shape: FixedValues.roundShapeLarge,
      ),
      appBarTheme: AppBarTheme(
          brightness: brightness,
          centerTitle: true,
          titleSpacing: 1,
          color: background,
          iconTheme: IconThemeData(
            color: foreground,
          ),
          textTheme: TextTheme(
              headline6: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ))),
      canvasColor: backgroundScaffold,
      applyElevationOverlayColor: brightness == Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: background,
          onPrimary: foreground,
          shape: roundShapeBtns,
          elevation: isLight ? 2.0 : 10.0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: roundShapeBtns,
        ),
      ),
    );
  }

  static TextStyle semiBoldStyle = TextStyle(fontWeight: FontWeight.w600);
  static Color blurBgColor = Colors.white10;
  static const double sigmaLevel = 5.0;
  static const Duration transitionDuration = const Duration(milliseconds: 100);
  static const String appName = 'Calculator Lite';
  static const String appVersion = '1.0.0';
  static const String logo = 'logo.png';
  static const String appLegalese =
      'An Open-Source Calculator that does all the calculations for you. No bloat, just the essentials: Calculator, History & Currency Tabs. Make faster calculations, display latest currencies, endless history scrolling.';

  static BorderRadius large = BorderRadius.circular(20.0);
  static RoundedRectangleBorder roundShapeLarge = RoundedRectangleBorder(
    borderRadius: large,
  );

  static RoundedRectangleBorder roundShapeBtns = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
  );

  static final TextStyle appTitleStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 25,
    height: 1,
  );
}
