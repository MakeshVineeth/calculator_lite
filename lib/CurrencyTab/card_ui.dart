import 'dart:io';

import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/currency_chooser.dart';
import 'package:calculator_lite/CurrencyTab/flag_icon.dart';
import 'package:calculator_lite/CurrencyTab/reset_form_provider.dart';
import 'package:calculator_lite/UIElements/slide_panel_item.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CardUI extends StatefulWidget {
  final int index;
  final bool remove;
  final ResetFormProvider resetFormProvider;

  const CardUI({
    required this.index,
    this.remove = false,
    required this.resetFormProvider,
    super.key,
  });

  @override
  State<CardUI> createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> {
  static String initial = '';
  static final NumberFormat _formatCurrency = _buildCurrencyFormat();

  static NumberFormat _buildCurrencyFormat() {
    try {
      return NumberFormat.currency(
        decimalDigits: 0,
        symbol: '',
        locale: Platform.localeName,
      );
    } catch (_) {
      return NumberFormat.currency(
        decimalDigits: 0,
        symbol: '',
        locale: 'en_US',
      );
    }
  }

  final controllerFrom = TextEditingController(text: initial);
  final controllerTo = TextEditingController(text: initial);

  late final Box<CurrencyListItem> fromBox;
  late final Box<CurrencyListItem> toBox;
  final int decimalPlaces = 3;

  late CurrencyListItem fromCur;
  late CurrencyListItem toCur;
  bool isInitialized = false;

  double exchangeRate = 0.0;
  Box<dynamic>? _fromCurBox;
  ValueListenable<Box<dynamic>>? _rateBoxListenable;
  String? _rateBoxCode;

  String placeholder = '0.00';
  String currentRateStr = '';
  bool _isChooserOpen = false;

  bool isFromMethod(String method) => method == CommonsData.fromBox;
  final HelperFunctions helperFunctions = const HelperFunctions();

  void _handleResetForm() {
    if (mounted) {
      controllerFrom.clear();
      controllerTo.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    fromBox = Hive.box<CurrencyListItem>(CommonsData.fromBox);
    toBox = Hive.box<CurrencyListItem>(CommonsData.toBox);
    openBoxes();

    if (!widget.remove) {
      widget.resetFormProvider.addListener(_handleResetForm);
    }
  }

  @override
  void didUpdateWidget(covariant CardUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetFormProvider != widget.resetFormProvider) {
      if (!oldWidget.remove) {
        oldWidget.resetFormProvider.removeListener(_handleResetForm);
      }
      if (!widget.remove) {
        widget.resetFormProvider.addListener(_handleResetForm);
      }
    }
  }

  @override
  void dispose() {
    if (!widget.remove) {
      widget.resetFormProvider.removeListener(_handleResetForm);
    }
    controllerFrom.dispose();
    controllerTo.dispose();
    super.dispose();
  }

  void _updateRateBoxListenable(String fromCode) {
    if (_rateBoxCode == fromCode && _rateBoxListenable != null) return;
    if (Hive.isBoxOpen(fromCode)) {
      _fromCurBox = Hive.box<dynamic>(fromCode);
      _rateBoxListenable = _fromCurBox!.listenable();
      _rateBoxCode = fromCode;
    } else {
      _fromCurBox = null;
      _rateBoxListenable = null;
      _rateBoxCode = null;
    }
  }

  Future<void> _closeBoxIfUnused(String code) async {
    if (!Hive.isBoxOpen(code)) return;
    final stillUsed = fromBox.values.any(
      (c) => c.currencyCode.toLowerCase() == code,
    );
    if (!stillUsed) {
      await Hive.box<dynamic>(code).close();
    }
  }

  void openBoxes() async {
    try {
      if (widget.remove) return;
      if (widget.index >= fromBox.length || widget.index >= toBox.length) return;

      fromCur = fromBox.getAt(widget.index) as CurrencyListItem;
      toCur = toBox.getAt(widget.index) as CurrencyListItem;
      final fromCode = fromCur.currencyCode.toLowerCase();
      if (!Hive.isBoxOpen(fromCode)) {
        await Hive.openBox<dynamic>(fromCode);
      }
      if (!mounted) return;
      _updateRateBoxListenable(fromCode);
      isInitialized = true;

      setState(() => updateExchange());
    } catch (_) {
      debugPrint('Exception openBoxes');
    }
  }

  void updateExchange() {
    if (widget.remove) return;
    if (widget.index >= fromBox.length || widget.index >= toBox.length) return;

    try {
      fromCur = fromBox.getAt(widget.index) as CurrencyListItem;
      toCur = toBox.getAt(widget.index) as CurrencyListItem;
      final fromCode = fromCur.currencyCode.toLowerCase();
      _updateRateBoxListenable(fromCode);

      if (fromCur.currencyCode == toCur.currencyCode) {
        exchangeRate = 1.0;
      } else if (_fromCurBox != null) {
        final value = _fromCurBox!.get(toCur.currencyCode);
        if (value is num) {
          exchangeRate = value.toDouble();
        } else {
          exchangeRate = 1.0;
        }
      } else {
        exchangeRate = 1.0;
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
          closeOnScroll: true,
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
    if (!mounted) return;
    if (widget.index >= fromBox.length || widget.index >= toBox.length) return;

    FocusScope.of(context).unfocus();
    final String? deletedFromCode =
        isInitialized ? fromCur.currencyCode.toLowerCase() : null;
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
    if (deletedFromCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeBoxIfUnused(deletedFromCode);
      });
    }
  });

  Widget buttonToolTipInfo() {
    final listenable = _rateBoxListenable;
    if (!widget.remove && isInitialized && listenable != null) {
      return ValueListenableBuilder<Box<dynamic>>(
        valueListenable: listenable,
        builder: (context, data, child) => currentRateInfo(),
      );
    }
    return currentRateInfo();
  }

  Widget currentRateInfo() {
    final double prevRate = exchangeRate;
    updateExchange();

    if (prevRate != exchangeRate && controllerFrom.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          handleFromText(controllerFrom.text, CommonsData.fromBox);
        }
      });
    }

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
    if (_isChooserOpen) return;
    _isChooserOpen = true;
    final String? prevFromCode =
        isInitialized && isFromMethod(method)
            ? fromCur.currencyCode.toLowerCase()
            : null;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await CurrencyChooser.show(
        context: context,
        index: widget.index,
        method: method,
      );
    } finally {
      _isChooserOpen = false;
    }

    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    setState(() => updateExchange());
    handleFromText(controllerFrom.text, CommonsData.fromBox);

    final String newFromCode =
        isInitialized ? fromCur.currencyCode.toLowerCase() : '';
    if (prevFromCode != null && prevFromCode != newFromCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeBoxIfUnused(prevFromCode);
      });
    }
  }

  Widget buttonCurrency(String method) => Expanded(
    child: ListTile(
      title: Row(
        children: <Widget>[
          ElevatedButton.icon(
            style: ButtonStyle(
              elevation: WidgetStateProperty.all(0),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              ),
            ),
            onPressed: () => displayCurrencyChooser(method),
            icon: FlagIcon(
              flagURL: isInitialized
                  ? isFromMethod(method)
                      ? fromCur.flagURL
                      : toCur.flagURL
                  : '',
            ),
            label: Text(
              isInitialized
                  ? (isFromMethod(method)
                      ? fromCur.currencyCode
                      : toCur.currencyCode)
                  : '',
              style: TextStyle(
                height: 1,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.labelLarge?.color,
              ),
            ),
          ),
        ],
      ),
      subtitle: getTextField(method),
    ),
  );

  void handleFromText(String from, String method) {
    try {
      from = from.replaceAll(',', '');

      final bool isFrom = isFromMethod(method);
      final List<String> textArray = from.split('');

      if (textArray.isEmpty) {
        if (isFrom) {
          controllerTo.clear();
        } else {
          controllerFrom.clear();
        }
        return;
      }

      if (!helperFunctions.numbersList.contains(textArray.last)) {
        textArray.removeLast();
      }

      if (textArray.isNotEmpty && textArray.last == '.') {
        final int decimalOccurrence =
            textArray.where((element) => element == '.').length;

        if (decimalOccurrence > 1) textArray.removeLast();
      }

      from = textArray.join();
      final double? val = double.tryParse(from);

      if (val != null &&
          !textArray.contains('.') &&
          helperFunctions.isInteger(val)) {
        from = _formatCurrency.format(val);
      }

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
      } else {
        controllerTo.text = from;
        controllerTo.selection = controllerTo.selection.copyWith(
          baseOffset: from.length,
          extentOffset: from.length,
        );

        if (val != null && exchangeRate > 0) {
          controllerFrom.text =
              (val / exchangeRate).toStringAsFixed(decimalPlaces);
        } else {
          controllerFrom.clear();
        }
      }
    } catch (_) {}
  }

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
            parent: BouncingScrollPhysics(),
          ),
        ),
      ),
    ),
  );
}
