import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'buttons_links.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static final Future<PackageInfo> _packageInfoFuture = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        shape: FixedValues.roundDialogShape(context),
        buttonPadding: const EdgeInsets.all(10.0),

        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              applicationIconImg(context),
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
                    FutureBuilder<PackageInfo>(
                      future: _packageInfoFuture,
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? 'Version ${snapshot.data!.version} (Build ${snapshot.data!.buildNumber})'
                            : 'Version ${FixedValues.appVersion}';
                        return Text(
                          version,
                          style: const TextStyle(color: Colors.grey),
                        );
                      },
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
                    Row(
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
                        const SizedBox(width: 8),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget applicationIconImg(BuildContext context) {
    final cachePx = (30 * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.asset(
      'assets/${FixedValues.logo}',
      width: 30,
      cacheWidth: cachePx > 0 ? cachePx : null,
    );
  }

  static void showAboutDialogFunc(BuildContext context) async {
    try {
      await showBlurDialog(context: context, child: const AboutPage());
    } catch (_) {}
  }
}
