import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool isLight;

  const Loader({this.isLight = false});

  @override
  Widget build(BuildContext context) {
    Color defaultColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.amber;

    if (isLight) defaultColor = Colors.white;

    return CircularProgressIndicator(
      backgroundColor: defaultColor,
    );
  }
}
