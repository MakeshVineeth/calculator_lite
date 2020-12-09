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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          buttonCurrency(CommonsData.fromBox),
          buttonCurrency(CommonsData.toBox),
        ],
      ),
    );
  }

  Widget buttonCurrency(String method) {
    final fromBox = Hive.box(CommonsData.fromBox);
    final CurrencyListItem fromCur = fromBox.getAt(widget.index);
    String currencyNameFrom = fromCur.currencyName;

    final toBox = Hive.box(CommonsData.toBox);
    final CurrencyListItem toCur = toBox.getAt(widget.index);
    String currencyNameTo = toCur.currencyName;

    return Expanded(
      child: ListTile(
        leading: Image.asset(
          method == CommonsData.fromBox ? fromCur.flagURL : toCur.flagURL,
          package: 'country_icons',
        ),
        title: Text(
          method == CommonsData.fromBox ? currencyNameFrom : currencyNameTo,
        ),
      ),
    );
  }
}
