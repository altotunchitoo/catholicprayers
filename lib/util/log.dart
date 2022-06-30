// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

class Log {
  static bool showDebugLog = true;
  static bool showErrorLog = true;

  static void d(Object object) {
    if (kDebugMode && showDebugLog) {
      print(object);
    }
  }

  static void e(Object object) {
    if (kDebugMode && showErrorLog) {
      print(object);
    }
  }
}
