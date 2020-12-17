import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class FlagIcon extends StatelessWidget {
  final flagURL;
  final sizeInt = 25.0;

  FlagIcon({@required this.flagURL});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]),
      ),
      child: OctoImage(
        fit: BoxFit.fill,
        width: sizeInt,
        height: sizeInt,
        image: AssetImage(
          flagURL,
          package: 'country_icons',
        ),
        imageBuilder: OctoImageTransformer.circleAvatar(),
        placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
      ),
    );
  }
}
