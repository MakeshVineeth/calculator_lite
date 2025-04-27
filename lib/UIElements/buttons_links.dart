import 'package:flutter/material.dart';

class ButtonLinks extends StatelessWidget {
  final Function function;
  final String title;
  final Color foregroundColor;
  final Color iconColor;
  final Color backgroundColor;
  final IconData icon;

  const ButtonLinks(
      {required this.function,
      required this.title,
      this.foregroundColor = Colors.white,
      this.iconColor = Colors.white,
      this.backgroundColor = Colors.green,
      required this.icon,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        icon: Icon(
          icon,
          color: iconColor,
        ),
        onPressed: () {
 function();
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(backgroundColor),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
          overlayColor: WidgetStateProperty.all(Colors.white10),
          padding: WidgetStateProperty.all(
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
