import 'package:flutter/material.dart';
import 'export_commons.dart';
import 'validate_functions.dart';
import 'text_field_custom.dart';
import 'package:intl/intl.dart';

class DateFieldCustom extends StatefulWidget {
  final TextEditingController dateController;
  final String dateText;

  const DateFieldCustom({@required this.dateController, this.dateText});

  @override
  _DateFieldCustomState createState() => _DateFieldCustomState();
}

class _DateFieldCustomState extends State<DateFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFieldCustom(
            title: widget.dateText ?? CommonStrings.dateTitle,
            controller: widget.dateController,
            validate: checkDateFormat,
            textInputType: TextInputType.datetime,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.date_range_outlined,
          ),
          onPressed: () => dateFunction(),
        ),
      ],
    );
  }

  void dateFunction() {
    FocusScope.of(context).unfocus();
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    ).then((value) {
      widget.dateController.text =
          DateFormat(CommonStrings.dateFormat).format(value);
    });
  }
}