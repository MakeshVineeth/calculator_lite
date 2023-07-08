import 'dart:io' show Platform;

import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> setPrefs(String title, bool data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(title, data);
}

Future<bool> getPrefs(String title, dynamic defaultVal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(title) ?? defaultVal;
}

Future<void> setSecure(bool disabled) async {
  try {
    if (Platform.isAndroid) {
      if (!disabled) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    }
  } catch (_) {}
}

Future<bool> isFirstLaunch() async {
  bool showTutorial = await getPrefs(FixedValues.firstLaunchPref, true);
  return showTutorial;
}

void showPlayStorePage() {
  try {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing();
  } catch (_) {}
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

    String? dateStr = prefs.getString(dateStrPrefs);
    DateTime now = DateTime.now();

    // If dateStr is null, it means there is no shared preference yet which should mean first time.
    if (dateStr == null) {
      await prefs.setString(dateStrPrefs, now.toString());
      return;
    }

    DateTime? dateCheck = DateTime.tryParse(dateStr);
    if (dateCheck == null) return;
    Duration difference = now.difference(dateCheck);

    if ((action && reviewAskedCount == 0) ||
        (difference.inMinutes >= 30 && reviewAskedCount == 0) ||
        difference.inHours >= 3) {
      final InAppReview inAppReview = InAppReview.instance;
      final bool isAvailable = await inAppReview.isAvailable();

      if (isAvailable) {
        Future.delayed(const Duration(seconds: 2), () async {
          await prefs.setInt(reviewCountPrefs, ++reviewAskedCount);
          await prefs.setString(dateStrPrefs, now.toString());
          await inAppReview.requestReview();
        });
      }
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
    Uri urlEncoded = Uri.tryParse(url)!;

    await launchUrl(
      urlEncoded,
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {}
}
