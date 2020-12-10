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
  Box fromBox;
  Box toBox;

  CurrencyListItem fromCur;
  CurrencyListItem toCur;

  String currencyNameFrom;
  String currencyNameTo;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    fromBox = Hive.box(CommonsData.fromBox);
    toBox = Hive.box(CommonsData.toBox);

    fromCur = fromBox.getAt(this.widget.index);
    toCur = toBox.getAt(widget.index);

    currencyNameFrom = fromCur.currencyName;
    currencyNameTo = toCur.currencyName;
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
    return Expanded(
      child: ListTile(
        title: Row(
          children: [
            Image.asset(
              method == CommonsData.fromBox ? fromCur.flagURL : toCur.flagURL,
              width: 38,
              height: 38,
              package: 'country_icons',
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              method == CommonsData.fromBox ? currencyNameFrom : currencyNameTo,
            ),
          ],
        ),
        subtitle: TextField(
          controller: controller,
        ),
      ),
    );
  }
}
