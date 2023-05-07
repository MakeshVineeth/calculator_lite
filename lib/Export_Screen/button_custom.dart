import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback function;

  const ButtonCustom({required this.text, required this.function, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
 function();
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
