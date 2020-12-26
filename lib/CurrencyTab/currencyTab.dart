import 'dart:math';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:calculator_lite/CurrencyTab/CardUI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:calculator_lite/fixedValues.dart';

class CurrencyTab extends StatefulWidget {
  @override
  _CurrencyTabState createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<CurrencyTab> {
  final _scrollController = new ScrollController();
  String lastUpdated = '';
  String src = '';
  String status = '';

  @override
  void dispose() {
    super.dispose();
    Hive.close();
  }

  int n = 0;
  CurrencyData currencyData = CurrencyData();

  Future<void> runData() async {
    await currencyData.getRemoteData(context);
    await Hive.openBox(CommonsData.fromBox);
    await Hive.openBox(CommonsData.toBox);
    await Hive.openBox(CommonsData.currencyListBox);
    await Hive.openBox(CommonsData.updatedDateBox);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: FixedValues.roundShapeLarge,
            child: InkWell(
              borderRadius: FixedValues.large,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Updated: ' + lastUpdated,
                            style: statusStyle(),
                          ),
                          Text(
                            'Status: ' + status,
                            style: statusStyle(),
                          ),
                          Text(
                            'Source: ' + src,
                            style: statusStyle(),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      shape: FixedValues.roundShapeBtns,
                      onPressed: () {
                        _formKey.currentState.reset();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.clear_all_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => addCurrencyCard(),
            iconSize: 30,
            icon: Icon(Icons.add_circle_rounded),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder(
              future: runData(),
              builder: (context, snapshot) {
                return AnimatedCrossFade(
                  crossFadeState:
                      (snapshot.connectionState == ConnectionState.done)
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  duration: CommonsData.dur1,
                  firstChild: widgetsData(snapshot),
                  secondChild: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void addCurrencyCard() async {
    final list = Hive.box(CommonsData.currencyListBox);
    if (list.length > 0) {
      Random random = Random();

      int t1 = random.nextInt(list.length);
      int t2 = random.nextInt(list.length);

      final fromBox = Hive.box(CommonsData.fromBox);
      await fromBox.add(list.getAt(t1));

      final toBox = Hive.box(CommonsData.toBox);
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

  TextStyle statusStyle() => TextStyle(
        fontWeight: FontWeight.w600,
        height: 1.8,
      );

  final _formKey = GlobalKey<FormState>();

  Widget widgetsData(AsyncSnapshot snapshot) => AnimatedCrossFade(
        crossFadeState: snapshot.connectionState == ConnectionState.done
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: CommonsData.dur1,
        secondChild: Center(
          child: CircularProgressIndicator(),
        ),
        firstChild: Form(
          key: _formKey,
          child: ValueListenableBuilder(
            valueListenable: Hive.box(CommonsData.toBox).listenable(),
            builder: (context, fromBox, widget) => AnimationLimiter(
              child: ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: fromBox.length,
                itemBuilder: (context, index) =>
                    AnimationConfiguration.staggeredList(
                  position: index,
                  duration: CommonsData.dur1,
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      duration: CommonsData.dur1,
                      child: CardUI(index: index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
