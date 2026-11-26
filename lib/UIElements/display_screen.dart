import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charcode/charcode.dart' as charcode;
import 'package:calculator_lite/UIElements/edit_text.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen(
      {required this.calculationString, required this.mainValue, super.key});

  final List<String> calculationString;
  final double mainValue;

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();

  static String formatNumber(double value) {
    if (value == -0) value = 0; // For Cos90 = -0
    if (value.isNaN) return 'Invalid Input';
    const String infinity = 'Infinity';
    final String infinitySymbol = String.fromCharCode(charcode.$infin);
    if (value.isInfinite) {
      return value.isNegative ? '-$infinitySymbol' : infinitySymbol;
    }

    const int precision = 10;
    String valueStr = '';
    if (value % 1 == 0 && value.abs() < 1e15) {
      valueStr = value.toStringAsFixed(0);
    } else if (value.abs() >= 1e15 || (value.abs() > 0 && value.abs() < 1e-7)) {
      valueStr = value.toString();
    } else {
      valueStr = value.toStringAsFixed(precision);
      valueStr = valueStr
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }

    return valueStr.replaceAll(infinity, infinitySymbol);
  }

  static bool isDoubleValid(double? val) {
    if (val == null) return false;

    if (val.isNaN) return false;

    return true;
  }
}

class _DisplayScreenState extends State<DisplayScreen> {
  final myController = TextEditingController();
  final ScrollController outputScrollController = ScrollController();

  @override
  void dispose() {
    myController.dispose();
    outputScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    runInitial();
    final bool isCompact = MediaQuery.sizeOf(context).height < 450 ||
        HelperFunctions().isLandScape(context);
    return Expanded(
      flex: 2,
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isCompact ? 1 : 2,
          ),
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Expression Area (flexible top with scrollbar & auto-scroll)
              Expanded(
                child: TextFieldCalc(
                  calculationString: widget.calculationString,
                ),
              ),
              SizedBox(height: isCompact ? 1 : 4),
              // Result Output Area (anchored bottom right with scrollbar and tap-to-copy)
              GestureDetector(
                onTap: () => _copyResultToClipboard(context),
                onLongPress: () => _copyResultToClipboard(context),
                child: RawScrollbar(
                  controller: outputScrollController,
                  thumbVisibility: true,
                  interactive: true,
                  thickness: 3.5,
                  radius: const Radius.circular(3),
                  thumbColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  child: AutoSizeTextField(
                    textAlign: TextAlign.right,
                    controller: myController,
                    scrollController: outputScrollController,
                    minLines: 1,
                    maxLines: isCompact ? 1 : 2,
                    readOnly: true,
                    showCursor: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    ),
                    style: mainValueStyle.copyWith(
                      fontSize: isCompact ? 22.0 : 40.0,
                    ),
                    scrollPhysics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyResultToClipboard(BuildContext context) {
    final text = myController.text.trim();
    if (text.isNotEmpty && text != 'Invalid Input') {
      Clipboard.setData(ClipboardData(text: text));
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied "$text" to clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static bool _isExpressionComplete(List<String> calcStr) {
    if (calcStr.isEmpty) return false;
    final last = calcStr.last;
    if (last == '.' ||
        last == FixedValues.decimalChar ||
        last.endsWith('.') ||
        last == '(' ||
        last.endsWith('(') ||
        HelperFunctions().operations.contains(last)) {
      return false;
    }
    return true;
  }

  void runInitial() {
    if (mounted) {
      if (DisplayScreen.isDoubleValid(widget.mainValue)) {
        myController.text = DisplayScreen.formatNumber(widget.mainValue);
      } else if (widget.mainValue.isNaN &&
          _isExpressionComplete(widget.calculationString)) {
        myController.text = 'Invalid Input';
      } else {
        myController.clear();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (outputScrollController.hasClients) {
          outputScrollController.animateTo(
            outputScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  TextStyle mainValueStyle = const TextStyle(
    letterSpacing: 1.0,
    fontWeight: FontWeight.w800,
  );
}
