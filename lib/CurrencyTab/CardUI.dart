import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/UIElements/fade_in_widget.dart';
import 'package:calculator_lite/fixedValues.dart';
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

  String currencyTitleFrom;
  String currencyTitleTo;

  final controllerFrom = TextEditingController();
  final controllerTo = TextEditingController();

  @override
  void initState() {
    super.initState();

    fromBox = Hive.box(CommonsData.fromBox);
    toBox = Hive.box(CommonsData.toBox);

    fromCur = fromBox.getAt(this.widget.index);
    toCur = toBox.getAt(widget.index);

    currencyTitleFrom = fromCur.currencyCode;
    currencyTitleTo = toCur.currencyCode;
  }

  @override
  Widget build(BuildContext context) {
    return FadeThis(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
        child: Card(
          elevation: 2,
          shape: FixedValues.roundShapeLarge,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                buttonCurrency(CommonsData.fromBox),
                buttonCurrency(CommonsData.toBox),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonCurrency(String method) {
    return Expanded(
      child: ListTile(
        title: Row(
          children: [
            FlatButton.icon(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: FixedValues.roundShapeLarge,
              onPressed: () {},
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]),
                ),
                child: ClipOval(
                  child: Image.asset(
                    method == CommonsData.fromBox
                        ? fromCur.flagURL
                        : toCur.flagURL,
                    width: 25,
                    height: 25,
                    package: 'country_icons',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              label: Text(
                method == CommonsData.fromBox
                    ? currencyTitleFrom
                    : currencyTitleTo,
                style: TextStyle(
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
        subtitle: Card(
          shape: FixedValues.roundShapeLarge,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller:
                  method == CommonsData.fromBox ? controllerFrom : controllerTo,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[800]),
                hintText: "0.00",
                fillColor: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
