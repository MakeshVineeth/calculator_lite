import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meta/meta.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'dart:io' show Platform;

Future<void> setPrefs(String title, bool data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(title, data);
}

Future<bool> getPrefs(String title, dynamic defaultVal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(title) ?? defaultVal;
}

Future<void> setSecure(bool _disabled) async {
  if (Platform.isAndroid) {
    if (!_disabled)
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    else
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }
}

void launchUrl(
    {@required String url,
    bool forceWebView = false,
    bool enableJavaScript = false}) async {
  try {
    launch(url, forceWebView: forceWebView, enableJavaScript: enableJavaScript);
  } catch (e) {}
}
