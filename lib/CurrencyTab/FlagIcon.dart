import 'package:flutter/material.dart';

class FlagIcon extends StatelessWidget {
  final flagURL;

  const FlagIcon({this.flagURL});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        flagURL,
        width: 25,
        height: 25,
        fit: BoxFit.fill,
        package: 'country_icons',
      ),
    );
  }
}
