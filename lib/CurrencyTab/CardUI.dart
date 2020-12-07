import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CardUI extends StatefulWidget {
  final int index;

  CardUI({@required this.index});

  @override
  _CardUIState createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> {
  String currencyName;

  @override
  void initState() {
    super.initState();

    final fromBox = Hive.box(CommonsData.fromBox);
    final CurrencyListItem fromCur = fromBox.get(widget.index);
    currencyName = fromCur.currencyName;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          MaterialButton(
            onPressed: () {},
            child: Text(currencyName),
          ),
        ],
      ),
    );
  }
}
