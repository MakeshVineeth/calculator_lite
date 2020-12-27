import 'dart:math';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/copyData.dart';
import 'package:calculator_lite/CurrencyTab/CardUI.dart';
import 'package:calculator_lite/CurrencyTab/updateColumn.dart';
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

  @override
  void dispose() {
    super.dispose();
    Hive.close();
  }

  int n = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder(
        future: copyData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return Column(
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
                            child: UpdateColumn(),
                          ),
                          MaterialButton(
                            shape: FixedValues.roundShapeBtns,
                            onPressed: () {
                              setState(() {
                                _formKey.currentState.reset();
                              });
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
                  onPressed: () async => await addCurrencyCard(),
                  iconSize: 30,
                  icon: Icon(Icons.add_circle_rounded),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: widgetsData(),
                )
              ],
            );
          else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }

  Future<void> addCurrencyCard() async {
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

  final _formKey = GlobalKey<FormState>();

  Widget widgetsData() {
    final Box toBox = Hive.box(CommonsData.toBox);

    return Form(
      key: _formKey,
      child: ValueListenableBuilder(
        valueListenable: toBox.listenable(),
        builder: (context, fromBox, widget) => AnimationLimiter(
          child: ListView.builder(
            addAutomaticKeepAlives: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: _scrollController,
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
    );
  }
}
