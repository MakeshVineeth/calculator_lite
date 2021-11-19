import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slide_dialog;
import 'package:flutter/material.dart';
import 'package:calculator_lite/fixed_values.dart';

void showSlideUp(
    {@required BuildContext context,
    @required Map<String, Function> menuList}) {
  slide_dialog.showSlideDialog(
    backgroundColor: Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.grey[900],
    context: context,
    child: Expanded(
      child: ListView.separated(
        cacheExtent: 2000,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        separatorBuilder: (context, index) => const Divider(thickness: 1),
        itemCount: menuList.length,
        itemBuilder: (context, index) => buttonDesigned(
          function: () {
            Navigator.of(context, rootNavigator: true).pop();
            menuList.entries.elementAt(index).value();
          },
          text: menuList.entries.elementAt(index).key,
          context: context,
        ),
      ),
    ),
  );
}

Widget buttonDesigned(
    {@required Function function,
    @required String text,
    @required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
    child: TextButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(FixedValues.roundShapeLarge),
      ),
      onPressed: () => function(),
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Text(
              text,
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
  );
}
