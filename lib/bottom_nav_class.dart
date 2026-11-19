import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/bounce_widget.dart';

class BottomNavClass {
  final String title;
  final IconData icon;

  const BottomNavClass({required this.title, required this.icon});

  BottomNavigationBarItem returnNavItems() => BottomNavigationBarItem(
        label: title,
        icon: Icon(icon),
        activeIcon: BounceWidget(
          child: Icon(icon),
        ),
      );
}
