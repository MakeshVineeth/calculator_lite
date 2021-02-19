import 'package:flutter/material.dart';

class ButtonLinks extends StatelessWidget {
  final Function function;
  final String title;
  final Color foregroundColor;
  final Color iconColor;
  final Color backgroundColor;
  final IconData icon;
  const ButtonLinks({
    this.function,
    @required this.title,
    this.foregroundColor = Colors.white,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.green,
    @required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        icon: Icon(
          icon,
          color: iconColor,
        ),
        onPressed: () {
          if (function != null) function();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
          overlayColor: MaterialStateProperty.all(Colors.white10),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12.0)),
        ),
        label: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: foregroundColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
