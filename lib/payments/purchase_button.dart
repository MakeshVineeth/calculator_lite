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
    return ElevatedButton(
      onPressed: () => callback(),
      style: ElevatedButton.styleFrom(
        primary: bg,
        onPrimary: fg,
        elevation: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
