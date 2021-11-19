import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class FadeScale extends StatefulWidget {
  final Widget child;
  const FadeScale({this.child, Key key}) : super(key: key);

  @override
  _FadeThisState createState() => _FadeThisState();
}

class _FadeThisState extends State<FadeScale>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final Duration _duration = const Duration(milliseconds: 800);

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    )..forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) => FadeScaleTransition(
        animation: _controller,
        child: widget.child,
      ),
    );
  }
}
