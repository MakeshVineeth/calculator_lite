import 'package:calculator_lite/HistoryTab/commonsHistory.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/HistoryTab/historyItem.dart';
import 'package:hive/hive.dart';

class EditWidget extends StatefulWidget {
  final int index;
  final String title;

  const EditWidget({@required this.index, @required this.title});

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
    return AlertDialog(
      buttonPadding: EdgeInsets.all(10),
      shape: FixedValues.roundShapeLarge,
      title: Text('Change Title'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            shape: FixedValues.roundShapeLarge,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: myController,
                style: TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
      actions: [
        MaterialButton(
          shape: FixedValues.roundShapeLarge,
          onPressed: () => changeTitle(),
          child: Text(
            'OK',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void changeTitle() async {
    final box = Hive.box(CommonsHistory.historyBox);
    HistoryItem historyItem = box.getAt(widget.index);

    String newTitle = myController.text.trim() ?? widget.title;
    if (newTitle.isEmpty) newTitle = widget.title;

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
