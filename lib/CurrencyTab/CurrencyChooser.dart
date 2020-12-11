import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/showBlurDialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:hive/hive.dart';

class CurrencyChooser extends StatelessWidget {
  final Box listBoxes = Hive.box(CommonsData.currencyListBox);

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        shape: FixedValues.roundShapeLarge,
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width / 2,
          child: ListView.builder(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: listBoxes.values.length,
            itemBuilder: (context, index) {
              CurrencyListItem currencyListItem =
                  listBoxes.values.elementAt(index);

              return ListTile(
                shape: FixedValues.roundShapeLarge,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                leading: ClipOval(
                  child: Image.asset(
                    currencyListItem.flagURL,
                    width: 25,
                    height: 25,
                    fit: BoxFit.fill,
                    package: 'country_icons',
                  ),
                ),
                title: Text(currencyListItem.currencyName),
              );
            },
          ),
        ),
      ),
    );
  }

  static void show({@required BuildContext context}) {
    showBlurDialog(
      child: CurrencyChooser(),
      context: context,
    );
  }
}
