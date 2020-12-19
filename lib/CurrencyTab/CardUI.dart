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
  static final initialValue = '1.0';
  final controllerFrom = TextEditingController(text: initialValue);
  final controllerTo = TextEditingController();

  Future<void> openBoxes() async {
    final Box fromBox = await Hive.openBox(CommonsData.fromBox);
    CurrencyListItem base = fromBox.getAt(widget.index);
    await Hive.openBox(base.currencyCode);

    final Box toBox = await Hive.openBox(CommonsData.toBox);
    CurrencyListItem to = toBox.getAt(widget.index);
    await Hive.openBox(to.currencyCode);
  }

  @override
  void initState() {
    super.initState();
  }

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
    return FutureBuilder(
      future: openBoxes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box(method).listenable(keys: [widget.index]),
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
                  subtitle: getTextField(method),
                );
              },
            ),
          );
        else
          return Center(child: CircularProgressIndicator());
      },
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
      CurrencyListItem cur = Hive.box(CommonsData.fromBox).getAt(widget.index);
      CurrencyListItem curTo = Hive.box(CommonsData.toBox).getAt(widget.index);

      final Box baseBox = Hive.box(cur.currencyCode);

      String exchange = baseBox.get(curTo.currencyCode);
      double rate = double?.tryParse(exchange) ?? 0.0;

      if (toVal != null) controllerTo.text = (toVal * rate).toString();
    }
  }

  final formatCurrency = new NumberFormat.currency(
    decimalDigits: 0,
    symbol: '',
    locale: 'en_US',
  );

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
              hintText: "0.00",
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
