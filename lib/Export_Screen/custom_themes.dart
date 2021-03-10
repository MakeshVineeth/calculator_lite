import 'package:flutter/material.dart';

class CustomThemes {
  static final BorderRadius roundEdge = BorderRadius.circular(20.0);
  static final appBarShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(30),
    ),
  );

  static final commonElevation = 3.0;

  static ThemeData customThemes(
      {@required BuildContext context, @required Brightness brightness}) {
    bool isLightTheme = brightness == Brightness.light;
    Color bgColor = isLightTheme ? Colors.white : Colors.black;
    Color fgColor = isLightTheme ? Colors.black : Colors.white;

    return ThemeData(
      brightness: brightness,
      primarySwatch: isLightTheme ? Colors.blue : Colors.amber,
      accentColor: isLightTheme ? Colors.blue : Colors.amber,
      scaffoldBackgroundColor: isLightTheme ? Colors.blue : Colors.black,
      cardTheme: CardTheme(
        elevation: isLightTheme ? commonElevation : 10.0,
        shape: RoundedRectangleBorder(borderRadius: roundEdge),
        color: isLightTheme ? bgColor : Colors.grey[900],
      ),
      errorColor: isLightTheme ? Colors.red : Colors.amber,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        centerTitle: true,
        titleSpacing: 1.0,
        iconTheme: IconThemeData(color: fgColor),
        textTheme: TextTheme(
          headline1:
              Theme.of(context).textTheme.headline1.copyWith(color: fgColor),
          headline2:
              Theme.of(context).textTheme.headline2.copyWith(color: fgColor),
          headline3:
              Theme.of(context).textTheme.headline3.copyWith(color: fgColor),
          headline4:
              Theme.of(context).textTheme.headline4.copyWith(color: fgColor),
          headline5:
              Theme.of(context).textTheme.headline5.copyWith(color: fgColor),
          headline6:
              Theme.of(context).textTheme.headline6.copyWith(color: fgColor),
          subtitle1:
              Theme.of(context).textTheme.subtitle1.copyWith(color: fgColor),
          subtitle2:
              Theme.of(context).textTheme.subtitle2.copyWith(color: fgColor),
          bodyText1:
              Theme.of(context).textTheme.bodyText1.copyWith(color: fgColor),
          bodyText2:
              Theme.of(context).textTheme.bodyText2.copyWith(color: fgColor),
          caption: Theme.of(context).textTheme.caption.copyWith(color: fgColor),
        ),
        actionsIconTheme: IconThemeData(
          color: fgColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: roundEdge),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: roundEdge),
        padding: EdgeInsets.all(12.0),
      )),
      applyElevationOverlayColor: !isLightTheme,
    );
  }

  static InputDecoration fancyTextField = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: roundEdge,
    ),
  );

  static TextStyle smallAppBarActionsText = TextStyle(
    fontWeight: FontWeight.w600,
  );
}
