import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/UIElements/aboutPage.dart';
import 'package:calculator_lite/UIElements/themeChooser.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform, exit;

var _androidAppRetain = MethodChannel("android_app_exit");

void showSlideUp(BuildContext context) {
  List<String> menuList = ['About', 'Change Theme', 'Exit'];
  double height = MediaQuery.of(context).size.height;

  slideDialog.showSlideDialog(
    context: context,
    child: SingleChildScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Container(
        height: height / 2,
        child: AnimationLimiter(
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(
              thickness: 1,
            ),
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: height / 3,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 0),
                      child: TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              FixedValues.roundShapeLarge),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          popUpFunction(index, context);
                        },
                        child: IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Text(
                                menuList[index],
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

void popUpFunction(int value, BuildContext context) {
  switch (value) {
    case 0:
      AboutPage.showAboutDialogFunc(context);
      break;
    case 1:
      PopThemeChooser.showThemeChooser(context);
      break;
    default:
      {
        if (Platform.isAndroid)
          _androidAppRetain.invokeMethod("sendToBackground");
        else if (!Platform.isIOS)
          exit(
              0); // Not allowed on IOS as it's against Apple Human Interface guidelines to exit the app programmatically.
      }
  }
}
