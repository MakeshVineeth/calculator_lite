import 'package:flutter/material.dart';

class PurchaseButton extends StatelessWidget {
  final Color bg;
  final Color fg;
  final VoidCallback callback;
  final String text;

  const PurchaseButton({
    this.bg,
    this.callback,
    this.text,
    this.fg,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return ElevatedButton(
      onPressed: () => callback(),
      style: ElevatedButton.styleFrom(
        primary: bg,
        onPrimary: fg,
        elevation: 10,
      ),
      child: Padding(
        padding: EdgeInsets.all(isPortrait ? 15.0 : 5.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isPortrait ? 25.0 : 15.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
