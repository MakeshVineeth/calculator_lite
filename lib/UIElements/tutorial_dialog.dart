import 'package:calculator_lite/UIElements/dialog_text_btn.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        title: const Text('How to Use'),
        shape: FixedValues.roundShapeLarge,
        buttonPadding: const EdgeInsets.all(10.0),
        actions: [
          DialogTextBtn(
            title: 'No Need',
            function: () => Navigator.pop(context),
          ),
          DialogTextBtn(
            title: 'Open FAQ',
            function: () {
              launchThisUrl(url: FixedValues.faqUrl);
              Navigator.pop(context);
            },
          ),
        ],
        content: const SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Learn more on how to use this app through our FAQ Page.',
                softWrap: true,
              ),
              SizedBox(height: 10),
              Text(
                'You can also visit the website by going to Calculator Tab > 3-dots menu > FAQ.',
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
