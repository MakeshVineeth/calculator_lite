import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/currency_chooser.dart';
import 'package:calculator_lite/CurrencyTab/flag_icon.dart';
import 'package:calculator_lite/CurrencyTab/reset_form_provider.dart';
import 'package:calculator_lite/UIElements/slide_panel_item.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CardUI extends StatefulWidget {
  final int index;
  final bool remove;
  final ResetFormProvider resetFormProvider;

  const CardUI(
      {@required this.index,
      this.remove = false,
      @required this.resetFormProvider,
      Key key})
      : super(key: key);

  @override
  _CardUIState createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> {
  static String initial = '';
  final controllerFrom = TextEditingController(text: initial);
  final controllerTo = TextEditingController(text: initial);

  final Box fromBox = Hive.box(CommonsData.fromBox);
  final Box toBox = Hive.box(CommonsData.toBox);
  final int decimalPlaces = 3;

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
      if (mounted) {
        controllerFrom.text = '';
        controllerTo.text = '';
      }
    });
  }

  @override
  void dispose() {
    controllerFrom.dispose();
    controllerTo.dispose();
    super.dispose();
  }

  void openBoxes() {
    try {
      if (widget.remove) return;

      fromCur = fromBox.getAt(widget.index);
      toCur = toBox.getAt(widget.index);
      fromCurBox = Hive.box(fromCur.currencyCode.toLowerCase());

      updateExchange();
    } catch (_) {
      debugPrint('Exception openBoxes');
    }
  }

  void updateExchange() {
    if (widget.remove) return;

    try {
      fromCur = fromBox.getAt(widget.index);
      toCur = toBox.getAt(widget.index);

      if (fromCur.currencyCode == toCur.currencyCode) {
        exchangeRate = 1.0;
      } else {
        fromCurBox = Hive.box(fromCur.currencyCode.toLowerCase());
        var value = fromCurBox.get(toCur.currencyCode);
        exchangeRate = (value is int) ? value.ceilToDouble() : value;
      }

      currentRateStr =
          '1 ${fromCur.currencyCode} = $exchangeRate ${toCur.currencyCode}.';
    } catch (_) {
      debugPrint('Exception updateExchange');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: FixedValues.large,
        child: Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: <SlidePanelItem>[
              SlidePanelItem(
                function: delete,
                icon: Icons.delete_outline,
                label: 'Delete',
                light: FixedValues.deleteBtnLight,
                dark: FixedValues.deleteBtnDark,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buttonCurrency(CommonsData.fromBox),
                    buttonCurrency(CommonsData.toBox),
                  ],
                ),
                buttonToolTipInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void delete() => Future.delayed(CommonsData.dur1, () {
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

  Widget buttonToolTipInfo() {
    if (!widget.remove) {
      return ValueListenableBuilder(
        valueListenable: fromCurBox.listenable(),
        builder: (context, data, child) => currentRateInfo(),
      );
    } else {
      return currentRateInfo();
    }
  }

  Widget currentRateInfo() {
    updateExchange();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => handleFromText(controllerFrom.text, CommonsData.fromBox));

    return Text(
      currentRateStr,
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[350]
            : Colors.grey[700],
      ),
    );
  }

  void displayCurrencyChooser(String method) async {
    await CurrencyChooser.show(
      context: context,
      index: widget.index,
      method: method,
    );

    if (mounted) setState(() => updateExchange());

    handleFromText(controllerFrom.text, CommonsData.fromBox);
  }

  Widget buttonCurrency(String method) => Expanded(
        child: ListTile(
          title: Row(
            children: <Widget>[
              ElevatedButton.icon(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 5)),
                ),
                onPressed: () => displayCurrencyChooser(method),
                icon: FlagIcon(
                  flagURL:
                      isFromMethod(method) ? fromCur.flagURL : toCur.flagURL,
                ),
                label: Text(
                  (isFromMethod(method)
                          ? fromCur.currencyCode
                          : toCur.currencyCode) ??
                      '',
                  style: TextStyle(
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.labelLarge.color,
                  ),
                ),
              )
            ],
          ),
          subtitle: getTextField(method),
        ),
      );

  void handleFromText(String from, String method) {
    try {
      // Text is shown in a currency format. So we're replacing the commas for further parsing.
      from = from.replaceAll(',', '');

      bool isFrom = isFromMethod(method);

      List<String> textArray = from.split('');

      if (textArray.isEmpty) {
        if (isFrom) {
          controllerTo.clear();
        } else {
          controllerFrom.clear();
        }
      }

      if (!helperFunctions.numbersList.contains(textArray.last)) {
        textArray.removeLast();
      }

      if (textArray.last == '.') {
        int decimalOccurrence =
            textArray.where((element) => element == '.').toList().length;

        if (decimalOccurrence > 1) textArray.removeLast();
      }

      from = textArray.join();

      double val = double.tryParse(from);

      // making sure text is an integer & format it using currency format.
      if (!textArray.contains('.') &&
          helperFunctions.isInteger(val)) from = formatCurrency.format(val);

      // display the new currency formatted numbers. Following code if users types in Left Text Box.
      if (isFrom) {
        controllerFrom.text = from;
        controllerFrom.selection = controllerFrom.selection.copyWith(
          baseOffset: from.length,
          extentOffset: from.length,
        );

        if (val != null) {
          controllerTo.text =
              (val * exchangeRate).toStringAsFixed(decimalPlaces);
        } else {
          controllerTo.clear();
        }
      }

      // Following code if users types in Right Text Box.
      else {
        controllerTo.text = from;
        controllerTo.selection = controllerTo.selection.copyWith(
          baseOffset: from.length,
          extentOffset: from.length,
        );

        if (val != null) {
          controllerFrom.text =
              (val / exchangeRate).toStringAsFixed(decimalPlaces);
        } else {
          controllerFrom.clear();
        }
      }
    } catch (_) {}
  }

  final formatCurrency = NumberFormat.currency(
    decimalDigits: 0,
    symbol: '',
    locale: 'en_US',
  );

  Widget getTextField(String method) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.black45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: isFromMethod(method) ? controllerFrom : controllerTo,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onChanged: (str) => handleFromText(str, method),
              showCursor: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[800]
                      : Colors.grey,
                ),
                hintText: placeholder,
                fillColor: Colors.white70,
              ),
              scrollPhysics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
            ),
          ),
        ),
      );
}
