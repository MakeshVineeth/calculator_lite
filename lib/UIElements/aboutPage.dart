import 'dart:io' show Platform;
import 'package:calculator_lite/UIElements/dialogTextBtn.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:calculator_lite/UIElements/showBlurDialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'buttons_links.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        shape: FixedValues.roundShapeLarge,
        buttonPadding: const EdgeInsets.all(10.0),
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
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FixedValues.appName,
                      style: FixedValues.appTitleStyle,
                    ),
                    Text(
                      FixedValues.appVersion,
                    ),
                    SizedBox(height: 20),
                    Text(
                      FixedValues.appLegalese,
                      style: appLegaleseStyle,
                    ),
                    SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ButtonLinks(
                              title: 'Play Store',
                              icon: Icons.shop_outlined,
                              backgroundColor: Color(0xff078C30),
                              function: () => launchUrl(
                                  url:
                                      'https://play.google.com/store/apps/details?id=com.makeshtech.calculator_lite'),
                            ),
                            SizedBox(width: 5),
                            ButtonLinks(
                              title: 'GitHub',
                              icon: Icons.code_outlined,
                              backgroundColor: Color(0xff24292E),
                              function: () => launchUrl(
                                  url:
                                      'https://github.com/MakeshVineeth/calculator_lite'),
                            ),
                          ],
                        ),
                      ),
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
