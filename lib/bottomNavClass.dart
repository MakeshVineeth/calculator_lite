import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';

class BottomNavClass {
  String title;
  IconData icon;
  BottomNavClass({this.title, this.icon});

  BottomNavigationBarItem returnNavItems() {
    return BottomNavigationBarItem(
      label: title,
      icon: Icon(icon),
      activeIcon: Bounce(
        child: Icon(icon),
      ),
    );
  }
}
