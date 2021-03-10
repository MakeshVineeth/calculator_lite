import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback function;
  final Color buttonColor;

  const ButtonCustom({@required this.text, this.function, this.buttonColor});

  @override
  Widget build(BuildContext context) {
    Color _currentColor;

    if (buttonColor == null)
      _currentColor = Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.amber;
    else
      _currentColor = buttonColor;

    return TextButton(
      style: TextButton.styleFrom(
        primary: _currentColor,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (function != null) function();
      },
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(text),
        ),
      ),
    );
  }
}
