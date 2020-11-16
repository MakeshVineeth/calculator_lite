import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/UIElements/aboutPage.dart';
import 'package:calculator_lite/UIElements/themeChooser.dart';
import 'package:flutter/services.dart';

var _androidAppRetain = MethodChannel("android_app_exit");

void showSlideUp(BuildContext context) {
  List<String> menuList = ['About', 'Change Theme', 'Exit'];

  slideDialog.showSlideDialog(
    context: context,
    child: SingleChildScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
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
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 100.0,
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
      _androidAppRetain.invokeMethod("sendToBackground");
  }
}
