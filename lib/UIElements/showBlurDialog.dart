import 'package:flutter/material.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'dart:ui';

class BlurredWindow extends StatefulWidget {
  final Widget child;

  const BlurredWindow({@required this.child});
  @override
  _BlurredWindowState createState() => _BlurredWindowState();
}

class _BlurredWindowState extends State<BlurredWindow> {
  double _currentOpacity = 0;
  final Duration duration = const Duration(milliseconds: 1000);
  Widget _currentChild;

  @override
  void initState() {
    super.initState();

    setState(() {
      _currentOpacity = 1;
      _currentChild = BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: FixedValues.sigmaLevel, sigmaY: FixedValues.sigmaLevel),
        child: widget.child,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedOpacity(
        key: UniqueKey(),
        opacity: _currentOpacity,
        duration: duration,
        child: GestureDetector(
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
          child: AnimatedContainer(
            key: UniqueKey(),
            duration: duration,
            child: SingleChildScrollView(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Container(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Center(child: _currentChild))),
          ),
        ),
      ),
    );
  }
}

Future<void> showBlurDialog(
        {@required BuildContext context, @required Widget child}) =>
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) => BlurredWindow(
        child: child,
      ),
    );
