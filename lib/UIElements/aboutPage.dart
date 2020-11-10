import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:calculator_lite/UIElements/showBlurDialog.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationName: FixedValues.appName,
      applicationVersion: FixedValues.appVersion,
      applicationLegalese: FixedValues.appLegalese,
      applicationIcon: ImageIcon(
        AssetImage('assets/Calculator-Icon-512.png'),
      ),
    );
  }

  static void showAboutDialogFunc(BuildContext context) async {
    try {
      ThemeData temp = Theme.of(context);
      bool useWhiteForeground =
          (temp.brightness == Brightness.dark) ? true : false;

      if (!(kIsWeb ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS))
        FlutterStatusbarcolor.setStatusBarWhiteForeground(!useWhiteForeground);

      showBlurDialog(
        context: context,
        child: AboutPage(),
      ).then((value) {
        if (!(kIsWeb ||
            Platform.isWindows ||
            Platform.isLinux ||
            Platform.isMacOS))
          FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
      });
    } catch (e) {}
  }
}
