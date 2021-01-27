import 'package:calculator_lite/HistoryTab/editWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'commonsHistory.dart';
import 'historyItem.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/UIElements/slidePanelItem.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/UIElements/showBlurDialog.dart';

class HistoryCard extends StatelessWidget {
  final int index;
  HistoryCard({@required this.index});

  final Box historyBox = Hive.box(CommonsHistory.historyBox);
  final HelperFunctions _helperFunctions = HelperFunctions();

  @override
  Widget build(BuildContext context) {
    HistoryItem historyItem = historyBox.getAt(index);
    DateTime dateObj = historyItem.dateTime;
    String date = _helperFunctions.getDate(dateObj);
    String title = historyItem.title;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: FixedValues.roundShapeLarge,
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: [
            SlidePanelItem(
              function: () => showBlurDialog(
                context: context,
                child: EditWidget(
                  index: index,
                  title: title,
                  date: dateObj,
                ),
              ),
              icon: Icons.edit_outlined,
              light: Colors.green[400],
            ),
            SlidePanelItem(
              function: () => delete(),
              icon: Icons.delete_outline,
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                itemRow(
                    heading: 'EXP:',
                    text: historyItem.expression,
                    context: context),
                itemRow(
                    heading: 'VAL:', text: historyItem.value, context: context),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                  alignment: Alignment.centerRight,
                  child: Text(
                    date,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[350]
                            : Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void delete() =>
      Future.delayed(CommonsData.dur1, () => historyBox.deleteAt(index));

  Widget itemRow(
          {@required String heading,
          @required text,
          @required BuildContext context}) =>
      Expanded(
        child: Card(
          elevation: 0.7,
          shape: FixedValues.roundShapeLarge,
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  heading,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Text(
                text,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
