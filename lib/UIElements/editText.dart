import 'package:flutter/material.dart';

class TextFieldCalc extends StatefulWidget {
  const TextFieldCalc({@required this.calculationString});

  final List<String> calculationString;
  @override
  _TextFieldCalcState createState() => _TextFieldCalcState();
}

class _TextFieldCalcState extends State<TextFieldCalc> {
  final myController = TextEditingController();
  final myFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocus.addListener(onFocusChange);
  }

  void onFocusChange() {
    print('hasFocus: ${myFocus.hasFocus}');
  }

  @override
  void dispose() {
    myController.dispose();
    myFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myController.value = TextEditingValue(
        text: this.widget.calculationString.join(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: this.widget.calculationString.join().length),
        ));
    return TextField(
      style: completeStringStyle(),
      controller: myController,
      decoration: null,
      readOnly: true,
      showCursor: true,
      focusNode: myFocus,
      onChanged: (text) {},
      onTap: onTapFunction,
    );
  }

  void onTapFunction() {
    var i = myController.selection;
    String char;
    if (i.start != -1) char = myController.text[i.start];
    print('char: $char');
  }

  TextStyle completeStringStyle() => TextStyle(
        fontSize: 40,
        letterSpacing: 1.5,
      );
}
