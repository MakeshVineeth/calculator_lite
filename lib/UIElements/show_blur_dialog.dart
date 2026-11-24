import 'dart:ui';

import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';

class BlurredWindow extends StatelessWidget {
  final Widget child;

  const BlurredWindow({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context, rootNavigator: true).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: FixedValues.sigmaLevel,
                sigmaY: FixedValues.sigmaLevel,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        SafeArea(
          child: Center(child: child),
        ),
      ],
    );
  }
}

Future<void> showBlurDialog({
  required BuildContext context,
  required Widget child,
}) {
  final bool isLight = Theme.of(context).brightness == Brightness.light;
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: isLight ? const Color(0x33000000) : const Color(0x55000000),
    barrierDismissible: true,
    builder: (context) => BlurredWindow(child: child),
  );
}
