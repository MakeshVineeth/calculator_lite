import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/CurrencyTab/CurrencyChooser.dart';
import 'package:calculator_lite/CurrencyTab/FlagIcon.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CardUI extends StatefulWidget {
  final int index;

  CardUI({@required this.index});

  @override
  _CardUIState createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> {
  final controllerFrom = TextEditingController();
  final controllerTo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }

  Widget buttonCurrency(String method) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: Hive.box(method).listenable(keys: [widget.index]),
        builder: (BuildContext context, Box data, Widget child) {
          CurrencyListItem currencyListItem =
              data.values.elementAt(widget.index);

          return ListTile(
            title: Row(
              children: [
                RaisedButton.icon(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: FixedValues.roundShapeLarge,
                  onPressed: () => CurrencyChooser.show(
                    context: context,
                    index: widget.index,
                    method: method,
                  ),
                  icon: FlagIcon(
                    flagURL: currencyListItem.flagURL,
                  ),
                  label: Text(
                    currencyListItem.currencyCode,
                    style: const TextStyle(
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Card(
                shape: FixedValues.roundShapeLarge,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: method == CommonsData.fromBox
                        ? controllerFrom
                        : controllerTo,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
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
        },
      ),
    );
  }
}
