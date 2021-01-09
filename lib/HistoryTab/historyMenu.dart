import 'package:flutter/material.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:calculator_lite/fixedValues.dart';

void showHistoryMenu(BuildContext context) {
  slideDialog.showSlideDialog(
      context: context,
      child: Expanded(
        child: ListView(
          itemExtent: 60,
          //  shrinkWrap: true,
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {},
                child: Text('Clear All'),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(FixedValues.roundShapeLarge),
                ),
              ),
            ),
          ],
        ),
      ));
}
