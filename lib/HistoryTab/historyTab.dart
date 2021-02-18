import 'package:calculator_lite/HistoryTab/Backend/export_function.dart';
import 'package:calculator_lite/HistoryTab/historyCard.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'commonsHistory.dart';
import 'package:calculator_lite/UIElements/showSlideUp.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';

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
              icon: Icon(Icons.more_vert_rounded), onPressed: () => menuShow()),
        ),
        FutureBuilder(
          future: Hive.openBox(CommonsHistory.historyBox),
          builder: (context, AsyncSnapshot data) {
            if (data.connectionState == ConnectionState.done) {
              final Box box = data.data;
              return listWidget(box);
            } else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Map<String, Function> menuList = {
    'Clear All': () => Future.delayed(
        CommonsData.dur1, () => Hive.box(CommonsHistory.historyBox).clear()),
    'Export': () {
      ExportFunction exportFunction = ExportFunction();
      exportFunction.export();
    },
  };

  void menuShow() => showSlideUp(context: context, menuList: menuList);

  Widget listWidget(final Box box) => ValueListenableBuilder(
        valueListenable: Hive.box(CommonsHistory.historyBox).listenable(),
        builder: (context, Box listener, child) {
          if (listener.isNotEmpty)
            return Expanded(
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                itemCount: listener.length,
                itemExtent: 200,
                cacheExtent: 2000,
                itemBuilder: (context, index) => HistoryCard(index: index),
              ),
            );
          else
            return Expanded(child: Center(child: Text('Empty')));
        },
      );
}
