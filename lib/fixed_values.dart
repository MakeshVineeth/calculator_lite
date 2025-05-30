import 'package:charcode/charcode.dart' as charcode;
import 'package:flutter/material.dart';

class FixedValues {
  // Set Symbols from Flutter CharCode Library and Static to access across all files.
  static final String upperArrow = String.fromCharCode(charcode.$uarr);
  static final String downArrow = String.fromCharCode(charcode.$darr);
  static final String backSpaceChar = String.fromCharCode(charcode.$larr);
  static final String multiplyChar = String.fromCharCode(charcode.$x);
  static const String changeSignChar =
      '\u207A/-'; // superscript + is not present in charcode library.
  static final String decimalChar = String.fromCharCode(charcode.$middot);
  static final String capChar = String.fromCharCode(charcode.$hat);
  static final String divisionChar = String.fromCharCode(charcode.$divide);
  static final String root = String.fromCharCode(charcode.$radic);
  static final String pi = String.fromCharCode(charcode.$pi);
  static final String sup2 = String.fromCharCode(charcode.$sup2);
  static final String sup3 = String.fromCharCode(charcode.$sup3);
  static final String squareChar = String.fromCharCode(charcode.$x) + sup2;
  static final String cubeChar = String.fromCharCode(charcode.$x) + sup3;
  static const String reciprocalChar = '⅟𝑥';
  static final String cubeRoot = String.fromCharCodes([
    charcode.$sup3,
    charcode.$radic,
    charcode.$x,
  ]);
  static final String minus = String.fromCharCode(charcode.$ndash);
  static final String cubeRootSym = String.fromCharCodes([
    charcode.$sup3,
    charcode.$radic,
  ]);
  static const String invButton = 'inv';
  static const String firstLaunchPref = 'first_launch';

  static const String buyRoute = '/buy';

  static const String calculatorTabTitle = 'Calculator';
  static const String historyTabTitle = 'History';
  static const String currencyTabTitle = 'Currency';

  static const Color deleteBtnLight = Colors.red;
  static final Color deleteBtnDark = Colors.red[400]!;

  // Links
  static const faqUrl = 'https://makeshvineeth.github.io/calc_faq/';
  static const playStoreLink =
      'https://play.google.com/store/apps/details?id=com.makeshtech.calculator_lite';
  static const privacyPolicy =
      'https://makeshvineeth.github.io/privacy_policy/';

  static final List<List<dynamic>> rowSimple = [
    [upperArrow, 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar],
    [4, 5, 6, minus],
    [1, 2, 3, '+'],
    [changeSignChar, 0, decimalChar, '='],
  ];

  static final List<List<dynamic>> rowExtras = [
    [downArrow, invButton, 'e', '%'],
    ['sin', 'cos', 'tan', cubeChar],
    ['ln', 'log', 'mod', reciprocalChar],
    ['(', ')', '!', root],
    [pi, cubeRoot, capChar, squareChar],
  ];

  static final List<List<dynamic>> rowInverse = [
    [downArrow, invButton, 'e', '%'],
    ['sin⁻¹', 'cos⁻¹', 'tan⁻¹', cubeChar],
    ['eˣ', '𝟏𝟬ˣ', 'mod', reciprocalChar],
    ['(', ')', '!', root],
    [pi, cubeRoot, capChar, squareChar],
  ];

  static final List<List<dynamic>> horizontalLayout = [
    ['eˣ', '𝟏𝟬ˣ', invButton, 'e', '%', 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar, 'sin', 'cos', 'tan', cubeChar],
    [4, 5, 6, minus, 'ln', 'log', 'mod', reciprocalChar],
    [1, 2, 3, '+', '(', ')', '!', root],
    [changeSignChar, 0, decimalChar, '=', pi, cubeRoot, capChar, squareChar],
  ];

  static final List<List<dynamic>> horizontalLayoutInverse = [
    ['eˣ', '𝟏𝟬ˣ', invButton, 'e', '%', 'C', backSpaceChar, divisionChar],
    [7, 8, 9, multiplyChar, 'sin⁻¹', 'cos⁻¹', 'tan⁻¹', cubeChar],
    [4, 5, 6, minus, 'ln', 'log', 'mod', reciprocalChar],
    [1, 2, 3, '+', '(', ')', '!', root],
    [changeSignChar, 0, decimalChar, '=', pi, cubeRoot, capChar, squareChar],
  ];

  static ThemeData getThemeData(Brightness brightness, BuildContext context) {
    bool isLight = brightness == Brightness.light;
    MaterialColor foreground = isLight ? Colors.red : Colors.yellow;
    Color? background = isLight ? Colors.white : Colors.grey[900];
    Color? foregroundText = isLight ? Colors.black : Colors.white;
    Color? backgroundScaffold = isLight ? background : Colors.black;

    return ThemeData(
      useMaterial3: true,
      primaryColor: foreground,
      scaffoldBackgroundColor: backgroundScaffold,
      iconTheme: IconThemeData(color: foreground),
      cardTheme: CardThemeData(
        color: background,
        elevation: isLight ? 2.0 : 10.0,
        shape: FixedValues.roundShapeLarge,
        surfaceTintColor: Colors.transparent,
      ),
      cardColor: background,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
        centerTitle: true,
        titleSpacing: 1,
        color: background,
        iconTheme: IconThemeData(color: foreground),
        titleTextStyle: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      canvasColor: backgroundScaffold,
      applyElevationOverlayColor: !isLight,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          shape: roundShapeBtns,
          elevation: isLight ? 2.0 : 10.0,
        ),
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: foregroundText,
        displayColor: foregroundText,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: roundShapeBtns),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: foreground)
          .copyWith(secondary: foreground, brightness: brightness)
          .copyWith(surface: backgroundScaffold),
      bottomAppBarTheme: BottomAppBarTheme(color: backgroundScaffold),
    );
  }

  static const TextStyle semiBoldStyle = TextStyle(
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const Color blurBgColor = Colors.white10;
  static const double sigmaLevel = 5.0;
  static const Duration transitionDuration = Duration(milliseconds: 100);
  static const String appName = 'Calculator Lite';
  static const String appVersion = '2.0.0';
  static const String logo = 'logo.png';
  static const String appLegalese =
      'An Open-Source Calculator that does all the calculations for you. Make faster calculations, display latest currencies, previous history scrolling, renaming the titles of history items and so much more!';

  static final BorderRadius large = BorderRadius.circular(20.0);
  static final RoundedRectangleBorder roundShapeLarge = RoundedRectangleBorder(
    borderRadius: large,
  );

  static final RoundedRectangleBorder roundShapeBtns = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
  );

  static TextStyle appTitleStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 25,
      height: 1,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    );
  }
}
