import 'dart:io' show Platform;
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

Future<void> setPrefs(String title, bool data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(title, data);
}

Future<bool> getPrefs(String title, bool defaultVal) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(title) ?? defaultVal;
}

Future<void> setSecure(bool disabled) async {
  try {
    if (Platform.isAndroid) {
      if (!disabled) {
        await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
      } else {
        await FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
      }
    }
  } catch (_) {}
}

Future<bool> isFirstLaunch() async {
  final bool showTutorial = await getPrefs(FixedValues.firstLaunchPref, true);
  return showTutorial;
}

void showPlayStorePage() {
  launchThisUrl(url: FixedValues.playStoreLink);
}

Future<void> askForReview({bool action = false}) async {
  try {
    if (!Platform.isAndroid) {
      return;
    }

    const String reviewCountPrefs = 'review_count';
    const String dateStrPrefs = 'review_date';

    final prefs = await SharedPreferences.getInstance();
    int reviewAskedCount = prefs.getInt(reviewCountPrefs) ?? 0;

    if (reviewAskedCount > 2) return;

    final String? dateStr = prefs.getString(dateStrPrefs);
    final DateTime now = DateTime.now();

    // If dateStr is null, it means there is no shared preference yet which should mean first time.
    if (dateStr == null) {
      await prefs.setString(dateStrPrefs, now.toString());
      return;
    }

    final DateTime? dateCheck = DateTime.tryParse(dateStr);
    if (dateCheck == null) return;
    final Duration difference = now.difference(dateCheck);

    if ((action && reviewAskedCount == 0) ||
        (difference.inMinutes >= 30 && reviewAskedCount == 0) ||
        difference.inHours >= 3) {
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          final bool? flowCompleted = await const MethodChannel(
            'kotlin.flutter.dev',
          ).invokeMethod<bool>('requestReview');
          if (flowCompleted ?? false) {
            await prefs.setInt(reviewCountPrefs, ++reviewAskedCount);
            await prefs.setString(dateStrPrefs, now.toString());
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      });
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> launchThisUrl({
  required String url,
  bool forceWebView = false,
  bool enableJavaScript = false,
}) async {
  try {
    final Uri? urlEncoded = Uri.tryParse(url);
    if (urlEncoded == null || urlEncoded.scheme != 'https') return;

    await launchUrl(
      urlEncoded,
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {}
}
