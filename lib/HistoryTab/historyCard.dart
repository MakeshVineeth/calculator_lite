import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'commonsHistory.dart';
import 'historyItem.dart';
import 'package:calculator_lite/fixedValues.dart';

class HistoryCard extends StatefulWidget {
  final int index;

  HistoryCard({@required this.index});

  @override
  _HistoryCardState createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard>
    with AutomaticKeepAliveClientMixin {
  final Box historyBox = Hive.box(CommonsHistory.historyBox);
  HistoryItem historyItem;
  TextEditingController exp;
  TextEditingController value;

  @override
  void initState() {
    super.initState();
    historyItem = historyBox.getAt(widget.index);
    exp = TextEditingController(text: historyItem.expression);
    value = TextEditingController(text: historyItem.value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: FixedValues.roundShapeLarge,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(historyItem.title),
              itemRow('Expression:', exp),
              itemRow('Value:', value),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemRow(String heading, TextEditingController textEditingController) {
    return Row(
      children: [
        Text(heading),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            readOnly: true,
            showCursor: true,
            controller: textEditingController,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
