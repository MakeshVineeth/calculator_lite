import 'package:calculator_lite/UIElements/dialogTextBtn.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/material.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        title: Text('How to Use'),
        shape: FixedValues.roundShapeLarge,
        buttonPadding: const EdgeInsets.all(10.0),
        actions: [
          DialogTextBtn(
            title: 'No Need',
            function: () => Navigator.pop(context),
          ),
          DialogTextBtn(
            title: 'Open Website',
            function: () {
              launchUrl(url: FixedValues.faqUrl);
              Navigator.pop(context);
            },
          ),
        ],
        content: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Text(
            'Learn to use Calculator Lite through our FAQ Website which will have most of the questions and answers on how to use our app. Click on Open Website to visit our FAQ Page.',
          ),
        ),
      ),
    );
  }
}
