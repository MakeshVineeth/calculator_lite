import 'package:intl/intl.dart';

String getFormattedTitle(DateTime now) => 'Titled, ' + DateFormat.yMMMMd('en_US').add_Hms().format(now);
