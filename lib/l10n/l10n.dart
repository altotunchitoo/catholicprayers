import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('my'),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'my':
        return '🇲🇲';
      case 'en':
      default:
        return '🇬🇧';
    }
  }
}
