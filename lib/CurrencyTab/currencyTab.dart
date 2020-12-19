import 'dart:math';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:calculator_lite/CurrencyTab/CardUI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CurrencyTab extends StatefulWidget {
  @override
  _CurrencyTabState createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<CurrencyTab> {
  final _scrollController = new ScrollController();

  @override
  void dispose() {
    super.dispose();
    Hive.close();
  }

  int n = 0;

  Future<void> runData() async {
    CurrencyData currencyData = CurrencyData();
    await currencyData.getRemoteData(context);

    await Hive.openBox(CommonsData.fromBox);
    await Hive.openBox(CommonsData.toBox);
    await Hive.openBox(CommonsData.currencyListBox);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Row(
              children: [
                Text('Last Updated:'),
                MaterialButton(
                  onPressed: () {
                    _formKey.currentState.reset();
                  },
                  child: Icon(
                    Icons.clear_all_outlined,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => addCurrencyCard(),
            icon: Icon(
              Icons.add_circle_rounded,
              size: 35,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder(
              future: runData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                  return widgetsData(snapshot);
                else
                  return Center(child: CircularProgressIndicator());
              },
            ),
          )
        ],
      ),
    );
  }

  void addCurrencyCard() async {
    final list = await Hive.openBox(CommonsData.currencyListBox);
    if (list.length > 0) {
      Random random = Random();

      int t1 = random.nextInt(list.length);
      int t2 = random.nextInt(list.length);

      final fromBox = await Hive.openBox(CommonsData.fromBox);
      await fromBox.add(list.getAt(t1));

      final toBox = await Hive.openBox(CommonsData.toBox);
      await toBox.add(list.getAt(t2));

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  Widget widgetsData(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (!snapshot.hasError) {
        final box = Hive.box(CommonsData.fromBox);
        return Form(
          key: _formKey,
          child: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, fromBox, widget) => AnimationLimiter(
              child: ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: fromBox.length,
                itemBuilder: (context, index) =>
                    AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 800),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            duration: const Duration(milliseconds: 800),
                            child: CardUI(index: index),
                          ),
                        )),
              ),
            ),
          ),
        );
      } else
        return Text('Error'); // for error receiving.
    } else
      return Center(child: CircularProgressIndicator());
  }
}
