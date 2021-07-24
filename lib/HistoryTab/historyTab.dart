import 'dart:io';
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
            icon: Icon(Icons.more_vert_rounded),
            onPressed: () => menuShow(),
          ),
        ),
        FutureBuilder(
          future: Hive.openBox(CommonsHistory.historyBox),
          builder: (context, AsyncSnapshot data) {
            if (data.connectionState == ConnectionState.done)
              return listWidget();
            else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Map<String, Function> getMenuList() {
    final Map<String, Function> menuList = {
      'Clear All': () => Future.delayed(
          CommonsData.dur1, () => Hive.box(CommonsHistory.historyBox).clear()),
      'Export': () {
        if (!Platform.isAndroid) return;
        Navigator.pushNamed(context, '/export');
      },
    };

    return menuList;
  }

  void menuShow() => showSlideUp(context: context, menuList: getMenuList());

  Widget listWidget() => ValueListenableBuilder(
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
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : Colors.amber.withOpacity(0.9),
                    size: 30,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your history will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey
                          : Colors.amber.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            );
        },
      );
}
