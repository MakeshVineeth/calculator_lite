import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'buttons_links.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: FixedValues.roundShapeLarge,
        buttonPadding: const EdgeInsets.all(10.0),

        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              applicationIconImg(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FixedValues.appName,
                      style: FixedValues.appTitleStyle(context),
                    ),
                    const Text(
                      FixedValues.appVersion,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      FixedValues.appLegalese,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),

                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ButtonLinks(
                              title: 'Play Store',
                              icon: Icons.shop_outlined,
                              backgroundColor: const Color(0xff078C30),
                              function: () => launchThisUrl(
                                url:
                                    'https://play.google.com/store/apps/details?id=com.makeshtech.calculator_lite',
                              ),
                            ),
                            const SizedBox(width: 5),
                            ButtonLinks(
                              title: 'GitHub',
                              icon: Icons.code_outlined,
                              backgroundColor: const Color(0xff24292E),
                              function: () => launchThisUrl(
                                url:
                                    'https://github.com/MakeshVineeth/calculator_lite',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget applicationIconImg() =>
      const Image(image: AssetImage('assets/${FixedValues.logo}'), width: 30);

  static void showAboutDialogFunc(BuildContext context) async {
    try {
      showBlurDialog(context: context, child: const AboutPage());
    } catch (_) {}
  }
}
