import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class FlagIcon extends StatelessWidget {
  final flagURL;

  const FlagIcon({@required this.flagURL});

  @override
  Widget build(BuildContext context) {
    return OctoImage.fromSet(
      fit: BoxFit.fill,
      width: 25,
      height: 25,
      image: AssetImage(
        flagURL,
        package: 'country_icons',
      ),
      octoSet: OctoSet.circleAvatar(
        backgroundColor: Colors.transparent,
        text: Text(''),
      ),
    );
  }
}
