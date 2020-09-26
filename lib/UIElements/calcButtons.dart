import 'package:flutter/material.dart';

class CalcButtons extends StatefulWidget {
  final List rowData;
  final int index;
  final Function displayFunction;
  final bool isCornerRows;
  CalcButtons(
      {this.rowData, this.index, this.displayFunction, this.isCornerRows});
  @override
  _CalcButtonsState createState() => _CalcButtonsState();
}

class _CalcButtonsState extends State<CalcButtons>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
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
    Color fgColor = Theme.of(context)
        .textTheme
        .button
        .color; // Initialized as Default Text Color

    if (this.widget.index == (this.widget.rowData.length - 1)) {
      fgColor = Theme.of(context)
          .primaryColor; // Last Column as Index 3 and is always primary color like red or blue
    }
    if (this.widget.isCornerRows) {
      fgColor = Theme.of(context).primaryColor; // Check if it corners rows
    }

    _controller.forward();
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: RaisedButton(
                elevation: 2.0,
                onPressed: this.widget.displayFunction,
                child: FadeTransition(
                  opacity: _animation,
                  child: Text(
                    this.widget.rowData[this.widget.index].toString(),
                    style: calcButtonTextStyle(fgColor),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle calcButtonTextStyle(Color fgColor) {
    return TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: fgColor,
    );
  }
}
