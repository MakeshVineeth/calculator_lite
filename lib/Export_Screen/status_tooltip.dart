import 'package:flutter/material.dart';

class StatusToolTip extends StatelessWidget {
  final String status;
  final bool isError;
  final bool isLoading;
  final bool visibility;
  final bool forceLight;

  const StatusToolTip(
      {this.status = '',
      this.visibility = false,
      this.isError = false,
      this.isLoading = false,
      this.forceLight = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visibility,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState:
            (isLoading) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: const Padding(
          padding: EdgeInsets.all(5.0),
          child: CircularProgressIndicator(),
        ),
        secondChild: Text(
          status,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: getColor(Theme.of(context).brightness),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color getColor(Brightness brightness) {
    Color color;

    if (forceLight) {
      color = isError ? Colors.yellowAccent : Colors.white;
    } else if (brightness == Brightness.light) {
      color = isError ? Colors.red : Colors.green;
    } else {
      color = (isError ? Colors.yellowAccent : Colors.blue[200])!;
    }

    return color;
  }
}
