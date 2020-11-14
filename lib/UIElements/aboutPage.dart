import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:calculator_lite/UIElements/showBlurDialog.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: FixedValues.roundShapeLarge,
      buttonPadding: EdgeInsets.all(10),
      actions: [
        TextButton(
          onPressed: () => showLicensePage(
              context: context,
              applicationName: FixedValues.appName,
              applicationVersion: FixedValues.appVersion,
              applicationLegalese: FixedValues.appLegalese,
              applicationIcon: applicationIconImg()),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'VIEW LICENSES',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      content: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            applicationIconImg(),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FixedValues.appName,
                  style: appTitleStyle,
                ),
                Text(
                  FixedValues.appVersion,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  FixedValues.appLegalese,
                  style: appLegaleseStyle,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget applicationIconImg() {
    return Image(
      image: AssetImage('assets/Calculator-Icon-512.png'),
      width: 30,
    );
  }

  final TextStyle appTitleStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 25,
    height: 1,
  );

  final TextStyle appLegaleseStyle = TextStyle(
    fontWeight: FontWeight.w500,
  );

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
