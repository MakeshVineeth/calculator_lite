import 'package:flutter/material.dart';

class FadeThis extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeThis(
      {required this.child,
      this.duration = const Duration(milliseconds: 400),
      super.key});

  @override
  State<FadeThis> createState() => _FadeThisState();
}

class _FadeThisState extends State<FadeThis>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
