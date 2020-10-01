import 'dart:ui';

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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AboutDialog(
        applicationName: appName,
        applicationVersion: appVersion,
        applicationLegalese: appLegalese,
      ),
    );
  }

  static void showAboutDialogFunc(BuildContext context) async {
    try {
      ThemeData temp = Theme.of(context);
      bool useWhiteForeground =
          (temp.brightness == Brightness.dark) ? true : false;
      if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS))
        FlutterStatusbarcolor.setStatusBarWhiteForeground(!useWhiteForeground);
      showDialog(
        context: context,
        barrierColor: Colors.black12,
        builder: (context) => AboutPage(),
      ).then((value) {
        if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS))
          FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
      });
    } catch (e) {}
  }
}
