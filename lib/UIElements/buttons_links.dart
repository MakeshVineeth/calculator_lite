import 'package:flutter/material.dart';

class ButtonLinks extends StatelessWidget {
  final Function function;
  final String title;
  final Color foregroundColor;
  final Color backgroundColor;
  const ButtonLinks({
    this.function,
    @required this.title,
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (function != null) function();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
        overlayColor: MaterialStateProperty.all(Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}
