import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationName: FixedValues.appName,
      applicationVersion: FixedValues.appVersion,
      applicationLegalese: FixedValues.appLegalese,
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

      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => AboutPage(),
        barrierColor: FixedValues.blurBgColor,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: FixedValues.sigmaLevel * animation.value,
                sigmaY: FixedValues.sigmaLevel * animation.value),
            child: AnimatedOpacity(
              opacity: animation.value,
              duration: FixedValues.transitionDuration,
              child: child,
            ),
          );
        },
        transitionDuration: FixedValues.transitionDuration,
        barrierDismissible: true,
        barrierLabel: '',
      ).then((value) {
        if (!(kIsWeb ||
            Platform.isWindows ||
            Platform.isLinux ||
            Platform.isMacOS))
          FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
      });
    } catch (e) {
      print(e);
    }
  }
}
