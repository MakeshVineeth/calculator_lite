import 'package:calculator_lite/HistoryTab/historyCard.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'commonsHistory.dart';
import 'historyMenu.dart';

class HistoryTab extends StatefulWidget {
  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: IconButton(
              icon: Icon(Icons.more_vert_rounded),
              onPressed: () => showHistoryMenu(context)),
        ),
        FutureBuilder(
          future: Hive.openBox(CommonsHistory.historyBox),
          builder: (context, AsyncSnapshot data) {
            if (data.connectionState == ConnectionState.done)
              return listWidget(data.data);
            else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget listWidget(final Box box) => ValueListenableBuilder(
        valueListenable: Hive.box(CommonsHistory.historyBox).listenable(),
        builder: (context, listener, child) => Expanded(
          child: ListView.builder(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: box.length,
            itemExtent: 200,
            cacheExtent: 2000,
            itemBuilder: (context, index) => HistoryCard(index: index),
          ),
        ),
      );
}
