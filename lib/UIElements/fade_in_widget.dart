import 'package:flutter/material.dart';

class FadeThis extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const FadeThis(
      {@required this.child,
      this.duration = const Duration(milliseconds: 400)});
  @override
  _FadeThisState createState() => _FadeThisState();
}

class _FadeThisState extends State<FadeThis>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return FadeTransition(
      opacity: _animation,
      child: this.widget.child,
    );
  }
}
