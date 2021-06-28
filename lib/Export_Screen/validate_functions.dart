import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'export_commons.dart';

String emptyValidator(TextEditingController controller) =>
    controller.text.isEmpty ? 'Type a proper value.' : null;

String checkDateFormat(TextEditingController controller) {
  String error = 'Check format of the date.';

  try {
    DateTime dateTime =
        DateFormat(CommonStrings.dateFormat).parse(controller.text.trim());
    return dateTime == null
        ? error
        : null; // Validator accepts a null if the value is indeed correct, else an error String msg.
  } catch (_) {
    return error;
  }
}
