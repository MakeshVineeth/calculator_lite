import 'package:calculator_lite/HistoryTab/historyCard.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'commonsHistory.dart';
import 'package:calculator_lite/UIElements/showSlideUp.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';

class HistoryTab extends StatefulWidget {
  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  PurchaseStatusProvider _purchaseStatusProvider;

  @override
  Widget build(BuildContext context) {
    _purchaseStatusProvider = Provider.of<PurchaseStatusProvider>(context);

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

  getMenuList() {
    Map<String, Function> menuList = {
      'Clear All': () => Future.delayed(
          CommonsData.dur1, () => Hive.box(CommonsHistory.historyBox).clear()),
      'Export': () {
        if (_purchaseStatusProvider.hasPurchased)
          Navigator.pushNamed(context, '/export');
        else
          Navigator.pushNamed(context, FixedValues.buyRoute);
      },
    };

    return menuList;
  }

  void menuShow() => showSlideUp(context: context, menuList: getMenuList());

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
