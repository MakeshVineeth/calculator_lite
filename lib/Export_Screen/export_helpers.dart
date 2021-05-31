import 'package:intl/intl.dart';
import 'export_commons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

DateTime getDateTime(String dateText) =>
    DateFormat(CommonStrings.dateFormat).parse(dateText.trim());

Future<bool> isAboveOreo() async {
  if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 26;
  } else
    return false;
}
