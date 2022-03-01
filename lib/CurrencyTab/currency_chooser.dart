import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/flag_icon.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:hive/hive.dart';

class CurrencyChooser extends StatelessWidget {
  final Box listBoxes = Hive.box(CommonsData.currencyListBox);
  final int boxIndex;
  final String method;

  CurrencyChooser({@required this.boxIndex, @required this.method, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        shape: FixedValues.roundShapeLarge,
        content: SizedBox(
          height: MediaQuery.of(context).size.height / 1.4,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            addAutomaticKeepAlives: true,
            cacheExtent: 1000,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            children: List.generate(
              listBoxes.values.length,
              (index) {
                final CurrencyListItem currencyListItem =
                    listBoxes.values.elementAt(index);

                return ListTile(
                  shape: FixedValues.roundShapeLarge,
                  onTap: () => onTap(context, currencyListItem),
                  leading: FlagIcon(flagURL: currencyListItem.flagURL),
                  title: Text(
                    currencyListItem.currencyName +
                        ' (${currencyListItem.currencyCode})',
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void onTap(BuildContext context, CurrencyListItem currencyListItem) async {
    Box box = Hive.box(method);
    await box.putAt(boxIndex, currencyListItem);
    await Hive.openBox(currencyListItem.currencyCode.toLowerCase());
    FocusScope.of(context).unfocus();
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<void> show({
    @required BuildContext context,
    @required int index,
    @required String method,
  }) async =>
      await showBlurDialog(
        child: CurrencyChooser(
          boxIndex: index,
          method: method,
        ),
        context: context,
      );
}
