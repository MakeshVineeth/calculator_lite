import 'package:calculator_lite/fixedValues.dart';
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
  static String list = 'sicotao⁻¹mngl';
  List<String> lists = list.split('');

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
    try {
      TextSelection i = myController.selection;
      String myText = myController.text;
      int start = i.start;

      if (myText[start].contains(FixedValues.root) &&
          myText.length > 1 &&
          myText[start - 1].contains(FixedValues.sup3)) start -= 1;

      int count = start - 1;
      for (; count >= 0; count--) {
        if (!lists.contains(myText[count])) {
          count += 1;
          break;
        }
      }

      TextSelection textSelection =
          TextSelection(baseOffset: count, extentOffset: count);
      myController.selection = textSelection;
    } catch (e) {}
  }

  TextStyle completeStringStyle() => TextStyle(
        fontSize: 40,
        letterSpacing: 1.5,
      );
}
