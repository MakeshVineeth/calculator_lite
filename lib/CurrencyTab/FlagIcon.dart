import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class FlagIcon extends StatefulWidget {
  final flagURL;

  const FlagIcon({@required this.flagURL});

  @override
  _FlagIconState createState() => _FlagIconState();
}

class _FlagIconState extends State<FlagIcon>
    with AutomaticKeepAliveClientMixin {
  final sizeInt = 25.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]),
      ),
      child: (widget.flagURL != null) ? image() : CircularProgressIndicator(),
    );
  }

  Widget image() => OctoImage(
        fit: BoxFit.fill,
        width: sizeInt,
        height: sizeInt,
        image: AssetImage(
          widget.flagURL,
          package: 'country_icons',
        ),
        imageBuilder: OctoImageTransformer.circleAvatar(),
        placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
      );

  @override
  bool get wantKeepAlive => true;
}
