import 'dart:io' show Platform;
import 'package:calculator_lite/UIElements/dialogTextBtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:calculator_lite/UIElements/showBlurDialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        shape: FixedValues.roundShapeLarge,
        buttonPadding: EdgeInsets.all(10),
        actions: [
          DialogTextBtn(
            function: () => showLicensePage(
                context: context,
                applicationName: FixedValues.appName,
                applicationVersion: FixedValues.appVersion,
                applicationLegalese: FixedValues.appLegalese,
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: applicationIconImg(),
                )),
            title: 'VIEW LICENSES',
          ),
        ],
        content: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              applicationIconImg(),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FixedValues.appName,
                      style: FixedValues.appTitleStyle,
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget applicationIconImg() {
    return Image(
      image: AssetImage('assets/' + FixedValues.logo),
      width: 30,
    );
  }

  final TextStyle appLegaleseStyle = TextStyle(
      // any styles
      );

  static void showAboutDialogFunc(BuildContext context) async {
    try {
      ThemeData temp = Theme.of(context);

      if (!(kIsWeb ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS))
        FlutterStatusbarcolor.setStatusBarColor(temp.backgroundColor);

      showBlurDialog(
        context: context,
        child: AboutPage(),
      ).then((value) {
        if (!(kIsWeb ||
            Platform.isWindows ||
            Platform.isLinux ||
            Platform.isMacOS))
          FlutterStatusbarcolor.setStatusBarColor(temp.backgroundColor);
      });
    } catch (e) {}
  }
}
