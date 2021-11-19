import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/UIElements/dialog_text_btn.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/HistoryTab/Backend/history_functions.dart';

class EditWidget extends StatefulWidget {
  final int index;
  final String title;
  final DateTime date;

  const EditWidget(
      {@required this.index,
      @required this.title,
      @required this.date,
      Key key})
      : super(key: key);

  @override
  _EditWidgetState createState() => _EditWidgetState();
}

class _EditWidgetState extends State<EditWidget> {
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myController.text = widget.title;
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        shape: FixedValues.roundShapeLarge,
        title: const Text('Change Title', style: FixedValues.appTitleStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              shape: FixedValues.roundShapeLarge,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: myController,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
          ],
        ),
        actions: [
          DialogTextBtn(function: () => changeTitle(true), title: 'DEFAULT'),
          DialogTextBtn(function: () => changeTitle(false), title: 'OK'),
        ],
      ),
    );
  }

  void changeTitle(bool date) async {
    final box = Hive.box(CommonsHistory.historyBox);
    final HistoryItem historyItem = box.getAt(widget.index);

    String newTitle = myController.text.trim() ?? widget.title;
    if (newTitle.isEmpty) newTitle = widget.title;
    if (date) newTitle = getFormattedTitle(widget.date);

    final newHistoryItem = HistoryItem(
      dateTime: historyItem.dateTime,
      expression: historyItem.expression,
      metrics: historyItem.metrics,
      value: historyItem.value,
      title: newTitle,
    );

    await box.putAt(widget.index, newHistoryItem);
    Navigator.pop(context);
  }
}
