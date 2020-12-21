import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/CurrencyTab/CurrencyChooser.dart';
import 'package:calculator_lite/CurrencyTab/FlagIcon.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CardUI extends StatefulWidget {
  final int index;

  CardUI({@required this.index});

  @override
  _CardUIState createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> {
  static String initial = '';
  final controllerFrom = TextEditingController(text: initial);
  final controllerTo = TextEditingController(text: initial);

  final Box fromBox = Hive.box(CommonsData.fromBox);
  final Box toBox = Hive.box(CommonsData.toBox);

  CurrencyListItem fromCur;
  CurrencyListItem toCur;
  double exchangeRate = 0.0;

  String placeholder = '0.00';
  String currentRateStr = '';

  Future<void> openBoxes() async {
    try {
      fromCur = fromBox.getAt(widget.index);
      await Hive.openBox(fromCur.currencyCode);

      toCur = toBox.getAt(widget.index);
      await Hive.openBox(toCur.currencyCode);

      updateExchange();
    } catch (e) {}
  }

  void updateExchange() {
    try {
      fromCur = fromBox.getAt(widget.index);
      toCur = toBox.getAt(widget.index);

      if (fromCur.currencyCode == toCur.currencyCode)
        exchangeRate = 1.0;
      else {
        final Box baseBox = Hive.box(fromCur.currencyCode);
        exchangeRate = baseBox.get(toCur.currencyCode);
      }

      currentRateStr =
          '1 ${fromCur.currencyCode} = $exchangeRate ${toCur.currencyCode}.';
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Card(
        elevation: 2,
        shape: FixedValues.roundShapeLarge,
        child: FutureBuilder(
          future: openBoxes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buttonCurrency(CommonsData.fromBox),
                          buttonCurrency(CommonsData.toBox),
                          popUpMenuCustom(),
                        ],
                      ),
                      Text(
                        currentRateStr,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ));
            else
              return Container(
                width: MediaQuery.of(context).size.width,
                height: 150.0,
                child: Center(child: Text('Loading...')),
              );
          },
        ),
      ),
    );
  }

  Widget buttonCurrency(String method) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: Hive.box(method).listenable(),
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
                  onPressed: () async {
                    await CurrencyChooser.show(
                      context: context,
                      index: widget.index,
                      method: method,
                    );
                    updateExchange();
                  },
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
            subtitle: getTextField(method),
          );
        },
      ),
    );
  }

  final HelperFunctions helperFunctions = HelperFunctions();
  void handleFromText(String from, String method) {
    if (method == CommonsData.fromBox) {
      from = from.replaceAll(',', '');

      if (!from.endsWith('.')) {
        double val = double.tryParse(from);
        if (val != null && helperFunctions.isInteger(val))
          from = formatCurrency.format(val);
      }

      controllerFrom.text = from;
      controllerFrom.selection = controllerFrom.selection.copyWith(
        baseOffset: from.length,
        extentOffset: from.length,
      );

      double toVal =
          double.tryParse(controllerFrom.text.replaceAll(',', '').trim());

      if (toVal != null)
        controllerTo.text = (toVal * exchangeRate).toString();
      else
        controllerTo.clear();
    }
  }

  final formatCurrency = new NumberFormat.currency(
    decimalDigits: 0,
    symbol: '',
    locale: 'en_US',
  );

  Widget popUpMenuCustom() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      shape: FixedValues.roundShapeBtns,
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false,
          value: 1,
          child: MaterialButton(
            onPressed: () {
              fromBox.deleteAt(widget.index);
              toBox.deleteAt(widget.index);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
              ),
              child: Text(
                'Remove',
                style: FixedValues.semiBoldStyle,
              ),
            ),
            shape: FixedValues.roundShapeBtns,
          ),
        ),
      ],
      onSelected: (val) {},
    );
  }

  Widget getTextField(String method) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
        shape: FixedValues.roundShapeLarge,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextFormField(
            controller:
                method == CommonsData.fromBox ? controllerFrom : controllerTo,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            style: textFieldStyle(context),
            onChanged: (str) => handleFromText(str, method),
            readOnly: (method == CommonsData.fromBox) ? false : true,
            showCursor: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              hintText: placeholder,
              fillColor: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle textFieldStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.w600,
      );
}
