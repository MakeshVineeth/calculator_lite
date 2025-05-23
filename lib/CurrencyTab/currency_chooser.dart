import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/flag_icon.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:hive_ce/hive.dart';

class CurrencyChooser extends StatelessWidget {
  final Box listBoxes = Hive.box(CommonsData.currencyListBox);
  final int boxIndex;
  final String method;

  CurrencyChooser({required this.boxIndex, required this.method, super.key});

  @override
  Widget build(BuildContext context) {
    List<CurrencyListItem> currencyListItems = List.castFrom(
      listBoxes.values.toList(),
    );

    List<CurrencyListItem> uniqueCurrencyListItems =
        currencyListItems
            .fold<Map<String, CurrencyListItem>>(
              {},
              (map, item) => map..putIfAbsent(item.currencyCode, () => item),
            )
            .values
            .toList();

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
              parent: BouncingScrollPhysics(),
            ),
            children: List.generate(uniqueCurrencyListItems.length, (index) {
              final CurrencyListItem currencyListItem = uniqueCurrencyListItems
                  .elementAt(index);

              return ListTile(
                shape: FixedValues.roundShapeLarge,
                onTap: () {
                  onTap(context, currencyListItem).then((value) {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context, rootNavigator: true).pop();
                  });
                },
                leading: FlagIcon(flagURL: currencyListItem.flagURL),
                title: Text(
                  '${currencyListItem.currencyName} (${currencyListItem.currencyCode})',
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> onTap(
    BuildContext context,
    CurrencyListItem currencyListItem,
  ) async {
    Box box = Hive.box(method);
    await box.putAt(boxIndex, currencyListItem);
    await Hive.openBox(currencyListItem.currencyCode.toLowerCase());
  }

  static Future<void> show({
    required BuildContext context,
    required int index,
    required String method,
  }) async => await showBlurDialog(
    child: CurrencyChooser(boxIndex: index, method: method),
    context: context,
  );
}
