import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'commonsHistory.dart';
import 'historyItem.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/Backend/helperFunctions.dart';

class HistoryCard extends StatelessWidget {
  final int index;
  HistoryCard({@required this.index});
  final Box historyBox = Hive.box(CommonsHistory.historyBox);
  final HelperFunctions _helperFunctions = HelperFunctions();

  @override
  Widget build(BuildContext context) {
    HistoryItem historyItem = historyBox.getAt(index);
    String date = _helperFunctions.getDate(historyItem.dateTime);
    String title = historyItem.title;

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
              itemRow(heading: 'EXP:', text: historyItem.expression),
              itemRow(heading: 'VAL:', text: historyItem.value),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                alignment: Alignment.centerRight,
                child: Text(
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemRow({@required String heading, @required text}) => Card(
        elevation: 0.7,
        shape: FixedValues.roundShapeLarge,
        child: ListTile(
          leading: Text(
            heading,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.copy_rounded,
              size: 20,
            ),
          ),
        ),
      );
}