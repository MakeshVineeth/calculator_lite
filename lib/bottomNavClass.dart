import 'package:flutter/material.dart';

class BottomNavClass {
  String title;
  IconData icon;
  BottomNavClass({this.title, this.icon});

  BottomNavigationBarItem returnNavItems() {
    return BottomNavigationBarItem(
      label: title,
      icon: Icon(icon),
    );
  }
}
