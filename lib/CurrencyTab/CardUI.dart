import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/CurrencyTab/CurrencyChooser.dart';
import 'package:calculator_lite/CurrencyTab/FlagIcon.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CardUI extends StatefulWidget {
  final int index;

  const CardUI({@required this.index});

  @override
  _CardUIState createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> with AutomaticKeepAliveClientMixin {
  static String initial = '';
  final controllerFrom = TextEditingController(text: initial);
  final controllerTo = TextEditingController(text: initial);

  final Box fromBox = Hive.box(CommonsData.fromBox);
  final Box toBox = Hive.box(CommonsData.toBox);

  CurrencyListItem fromCur;
  CurrencyListItem toCur;
  double exchangeRate = 0.0;
  Box fromCurBox;

  String placeholder = '0.00';
  String currentRateStr = '';

  Future<void> openBoxes() async {
    try {
      fromCur = fromBox.getAt(widget.index);
      toCur = toBox.getAt(widget.index);
      fromCurBox = await Hive.openBox(fromCur.currencyCode.toLowerCase());

      updateExchange();
    } catch (e) {
      print('Exception openBoxes: ' + e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void updateExchange() {
    try {
      fromCur = fromBox.getAt(widget.index);
      toCur = toBox.getAt(widget.index);

      if (fromCur.currencyCode == toCur.currencyCode)
        exchangeRate = 1.0;
      else {
        fromCurBox = Hive.box(fromCur.currencyCode.toLowerCase());
        var value = fromCurBox.get(toCur.currencyCode);
        exchangeRate = (value is int) ? value.ceilToDouble() : value;
      }

      currentRateStr =
          '1 ${fromCur.currencyCode} = $exchangeRate ${toCur.currencyCode}.';
    } catch (e) {
      print('Exception updateExchange: ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Card(
        elevation: 2,
        shape: FixedValues.roundShapeLarge,
        child: FutureBuilder(
          future: openBoxes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                secondaryActions: [
                  ClipRRect(
                    borderRadius: FixedValues.large,
                    child: SlideAction(
                      onTap: () async {
                        await fromBox.deleteAt(widget.index);
                        await toBox.deleteAt(widget.index);
                        FocusScope.of(context).unfocus();
                      },
                      closeOnTap: true,
                      child: Icon(Icons.delete_outline),
                    ),
                  ),
                ],
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buttonCurrency(CommonsData.fromBox),
                            buttonCurrency(CommonsData.toBox),
                          ],
                        ),
                        ValueListenableBuilder(
                          valueListenable: fromCurBox.listenable(),
                          builder: (context, data, child) => currentRateInfo(),
                        ),
                      ],
                    )),
              );
            else
              return Container(
                width: MediaQuery.of(context).size.width,
                height: 135.0,
                child: Center(child: CircularProgressIndicator()),
              );
          },
        ),
      ),
    );
  }

  Widget currentRateInfo() {
    updateExchange();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => handleFromText(controllerFrom.text, CommonsData.fromBox));

    return Text(
      currentRateStr,
      style: TextStyle(fontWeight: FontWeight.w600),
    );
  }

  Widget buttonCurrency(String method) {
    return Expanded(
      child: ListTile(
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

                if (mounted)
                  setState(() {
                    updateExchange();
                  });

                handleFromText(controllerFrom.text, CommonsData.fromBox);
              },
              icon: FlagIcon(
                flagURL: isFromMethod(method) ? fromCur.flagURL : toCur.flagURL,
              ),
              label: Text(
                isFromMethod(method)
                    ? fromCur.currencyCode
                    : toCur.currencyCode,
                style: const TextStyle(
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
        subtitle: getTextField(method),
      ),
    );
  }

  bool isFromMethod(String method) => method == CommonsData.fromBox;

  final HelperFunctions helperFunctions = HelperFunctions();
  void handleFromText(String from, String method) {
    if (isFromMethod(method)) {
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

  Widget getTextField(String method) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          shape: FixedValues.roundShapeLarge,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: isFromMethod(method) ? controllerFrom : controllerTo,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              style: textFieldStyle(context),
              onChanged: (str) => handleFromText(str, method),
              readOnly: isFromMethod(method) ? false : true,
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

  TextStyle textFieldStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.w600,
      );

  @override
  bool get wantKeepAlive => true;
}
