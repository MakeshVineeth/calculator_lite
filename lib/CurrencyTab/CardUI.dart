import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/CurrencyTab/CurrencyChooser.dart';
import 'package:calculator_lite/CurrencyTab/FlagIcon.dart';
import 'package:calculator_lite/CurrencyTab/resetFormProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:calculator_lite/UIElements/slidePanelItem.dart';

class CardUI extends StatefulWidget {
  final int index;
  final bool remove;
  final ResetFormProvider resetFormProvider;

  const CardUI(
      {@required this.index,
      this.remove = false,
      @required this.resetFormProvider});

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
  Box fromCurBox;

  String placeholder = '0.00';
  String currentRateStr = '';

  bool isFromMethod(String method) => method == CommonsData.fromBox;

  final HelperFunctions helperFunctions = HelperFunctions();

  @override
  void initState() {
    super.initState();
    openBoxes();

    widget.resetFormProvider.addListener(() {
      controllerFrom.text = '';
      controllerTo.text = '';
    });
  }

  @override
  void dispose() {
    super.dispose();
    controllerFrom.dispose();
    controllerTo.dispose();
  }

  void openBoxes() {
    try {
      if (widget.remove) return;

      fromCur = fromBox.getAt(widget.index);
      toCur = toBox.getAt(widget.index);
      fromCurBox = Hive.box(fromCur.currencyCode.toLowerCase());

      updateExchange();
    } catch (e) {
      print('Exception openBoxes: ' + e.toString());
    }
  }

  void updateExchange() {
    if (widget.remove) return;

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
    return Card(
      child: slidable(),
    );
  }

  Widget slidable() => Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: [
          SlidePanelItem(
            function: delete,
            icon: Icons.delete_outline,
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
              buttonToolTipInfo(),
            ],
          ),
        ),
      );

  void delete() {
    Future.delayed(CommonsData.dur1, () {
      FocusScope.of(context).unfocus();
      fromBox.deleteAt(widget.index);
      toBox.deleteAt(widget.index);
      AnimatedList.of(context).removeItem(
        widget.index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: CardUI(
              index: widget.index,
              remove: true,
              resetFormProvider: widget.resetFormProvider,
            ),
          ),
        ),
      );
    });
  }

  Widget buttonToolTipInfo() {
    if (!widget.remove)
      return ValueListenableBuilder(
        valueListenable: fromCurBox.listenable(),
        builder: (context, data, child) => currentRateInfo(),
      );
    else
      return currentRateInfo();
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

  void displayCurrencyChooser(String method) async {
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
  }

  Widget buttonCurrency(String method) {
    return Expanded(
      child: ListTile(
        title: Row(
          children: [
            ElevatedButton.icon(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 5)),
              ),
              onPressed: () => displayCurrencyChooser(method),
              icon: FlagIcon(
                flagURL:
                    isFromMethod(method) ? fromCur?.flagURL : toCur?.flagURL,
              ),
              label: Text(
                (isFromMethod(method)
                        ? fromCur?.currencyCode
                        : toCur?.currencyCode) ??
                    '',
                style: TextStyle(
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.button.color,
                ),
              ),
            )
          ],
        ),
        subtitle: getTextField(method),
      ),
    );
  }

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

  final formatCurrency = NumberFormat.currency(
    decimalDigits: 0,
    symbol: '',
    locale: 'en_US',
  );

  Widget getTextField(String method) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.black45,
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
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[800]
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
              hintText: placeholder,
              fillColor: Colors.white70,
            ),
            scrollPhysics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          ),
        ),
      ),
    );
  }

  TextStyle textFieldStyle(BuildContext context) =>
      TextStyle(fontWeight: FontWeight.w600);
}
