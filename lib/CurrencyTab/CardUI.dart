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

    print('tobox: ${toBox.length}');
    final CurrencyListItem toCur = toBox.getAt(widget.index);
    print(toCur.currencyCode);
    String currencyNameTo = toCur.currencyName;
    print(currencyNameTo);

    return Card(
      child: InkWell(
        onTap: () {},
        child: Text(currencyNameFrom),
      ),
    );
  }
}
