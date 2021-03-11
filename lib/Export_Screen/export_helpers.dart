import 'package:intl/intl.dart';
import 'export_commons.dart';
import 'package:device_info/device_info.dart';

DateTime getDateTime(String dateText) =>
    DateFormat(CommonStrings.dateFormat).parse(dateText.trim());

Future<bool> isAboveOreo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.sdkInt >= 26;
}
