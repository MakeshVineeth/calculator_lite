import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:calculator_lite/fixedValues.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: FixedValues.sigmaLevel, sigmaY: FixedValues.sigmaLevel),
      child: AboutDialog(
        applicationName: FixedValues.appName,
        applicationVersion: FixedValues.appVersion,
        applicationLegalese: FixedValues.appLegalese,
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
        barrierColor: FixedValues.blurBgColor,
        builder: (context) => AboutPage(),
      ).then((value) {
        if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS))
          FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
      });
    } catch (e) {}
  }
}
