import 'package:flutter/material.dart';
import 'export_commons.dart';
import 'validate_functions.dart';
import 'text_field_custom.dart';
import 'package:intl/intl.dart';

class DateFieldCustom extends StatefulWidget {
  final TextEditingController dateController;
  final String? dateText;
  final bool ignoreValidation;

  const DateFieldCustom(
      {required this.dateController,
      this.dateText,
      this.ignoreValidation = false,
      super.key});

  @override
  State<DateFieldCustom> createState() => _DateFieldCustomState();
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
            ignoreValidation: widget.ignoreValidation,
          ),
        ),
        IconButton(
          icon: const Icon(
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
          DateFormat(CommonStrings.dateFormat).format(value!);
    });
  }
}
