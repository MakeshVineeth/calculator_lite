import 'package:calculator_lite/HistoryTab/edit_widget.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'commons_history.dart';
import 'history_item.dart';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/UIElements/slide_panel_item.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:flutter/services.dart';

class HistoryCard extends StatelessWidget {
  final int index;
  final HistoryItem historyItem;

  HistoryCard({Key key, @required this.index, @required this.historyItem})
      : super(key: key);

  final Box historyBox = Hive.box(CommonsHistory.historyBox);
  final HelperFunctions _helperFunctions = HelperFunctions();
  final snackBar = const SnackBar(content: Text('Copied to Clipboard!'));

  @override
  Widget build(BuildContext context) {
    final DateTime dateObj = historyItem.dateTime;
    final String date = _helperFunctions.getDate(dateObj);
    final String title = historyItem.title;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ClipRRect(
          borderRadius: FixedValues.large,
          child: Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: <SlidePanelItem>[
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
                  label: 'Edit',
                ),
                SlidePanelItem(
                  function: () => delete(),
                  icon: Icons.delete_outline,
                  label: 'Delete',
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3,
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  itemRow(
                    heading: 'EXP:',
                    text: historyItem.expression,
                    context: context,
                  ),
                  itemRow(
                    heading: 'VAL:',
                    text: historyItem.value,
                    context: context,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3,
                    ),
                    alignment: Alignment.centerRight,
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[350]
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void delete() =>
      Future.delayed(CommonsData.dur1, () => historyBox.deleteAt(index));

  Widget itemRow({
    @required String heading,
    @required text,
    @required BuildContext context,
  }) {
    return Expanded(
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.black45,
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Text(
              text,
              maxLines: 1,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: text))
                    .then((_) =>
                        ScaffoldMessenger.of(context).showSnackBar(snackBar)),
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
}
