import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/CurrencyTab/FlagIcon.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/showBlurDialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive/hive.dart';

class CurrencyChooser extends StatelessWidget {
  final Box listBoxes = Hive.box(CommonsData.currencyListBox);

  final boxIndex;
  final method;

  CurrencyChooser({@required this.boxIndex, @required this.method});

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        shape: FixedValues.roundShapeLarge,
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width / 2,
          child: AnimationLimiter(
            child: ListView.builder(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: listBoxes.values.length,
              itemBuilder: (context, index) {
                CurrencyListItem currencyListItem =
                    listBoxes.values.elementAt(index);

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 20.0,
                    child: FadeInAnimation(
                      duration: const Duration(milliseconds: 500),
                      child: ListTile(
                        shape: FixedValues.roundShapeLarge,
                        onTap: () {
                          Box box = Hive.box(method);
                          box.putAt(boxIndex, currencyListItem);
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        leading: FlagIcon(
                          flagURL: currencyListItem.flagURL,
                        ),
                        title: Text(
                          currencyListItem.currencyName +
                              ' (${currencyListItem.currencyCode})',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> show({
    @required BuildContext context,
    @required int index,
    @required String method,
  }) async {
    await showBlurDialog(
      child: CurrencyChooser(
        boxIndex: index,
        method: method,
      ),
      context: context,
    );
  }
}
