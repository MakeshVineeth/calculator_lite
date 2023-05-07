import 'package:flutter/material.dart';

class PurchaseButton extends StatelessWidget {
  final Color bg;
  final Color fg;
  final VoidCallback callback;
  final String text;

  const PurchaseButton({required this.bg, required this.callback, required this.text, required this.fg, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return ElevatedButton(
      onPressed: () => callback(),
      style: ElevatedButton.styleFrom(
        foregroundColor: fg, backgroundColor: bg,
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
