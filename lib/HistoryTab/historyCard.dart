import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'commonsHistory.dart';
import 'historyItem.dart';

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

    return ListTile(
      title: Text(historyItem.title),
      isThreeLine: true,
      subtitle: Column(
        children: [
          Row(
            children: [
              Text('Exp'),
              TextField(
                controller: exp,
              ),
            ],
          ),
          Row(
            children: [
              Text('Value'),
              TextField(
                controller: value,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
