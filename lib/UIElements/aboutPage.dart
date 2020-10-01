import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'dart:io' show Platform;

class AboutPage extends StatelessWidget {
  final String appName = 'Calculator Lite';
  final String appVersion = '1.0.0';
  final String appLegalese =
      'Make faster calculations, display latest currencies, endless history scrolling';
  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationName: appName,
      applicationVersion: appVersion,
      applicationLegalese: appLegalese,
    );
  }

  static void showAboutDialogFunc(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) => AboutPage(),
      ).then((value) {
        try {
          if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
            // Must be executed every time the theme changes.
            FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
            ThemeData temp = Theme.of(context);
            bool useWhiteForeground =
                (temp.brightness == Brightness.dark) ? true : false;
            FlutterStatusbarcolor.setStatusBarWhiteForeground(
                useWhiteForeground);
          }
        } catch (e) {}
      });
    } catch (e) {}
  }
}
