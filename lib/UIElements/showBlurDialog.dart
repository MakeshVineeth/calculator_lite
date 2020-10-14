import 'package:flutter/material.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'dart:ui';

Future<Type> showBlurDialog(
    {@required BuildContext context, @required Widget child}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    barrierColor: FixedValues.blurBgColor,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: FixedValues.sigmaLevel * animation.value,
            sigmaY: FixedValues.sigmaLevel * animation.value),
        child: AnimatedOpacity(
          opacity: animation.value,
          duration: FixedValues.transitionDuration,
          child: child,
        ),
      );
    },
    transitionDuration: FixedValues.transitionDuration,
    barrierDismissible: true,
    barrierLabel: '',
  );
}
