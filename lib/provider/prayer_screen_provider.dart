import 'package:catholic_prayers/model/prayer.dart';
import 'package:flutter/cupertino.dart';

class PrayerScreenProvider extends ChangeNotifier {
  PrayerModel? _currentPrayer;

  PrayerModel? get currentPrayer => _currentPrayer;

  set currentPrayer(PrayerModel? value) {
    _currentPrayer = value;
    notifyListeners();
  }

  set currentPrayerMute(PrayerModel? value) {
    _currentPrayer = value;
  }

  String getCurrentPrayerTitle({required String language}) {
    if (_currentPrayer == null) return "";
    switch (language) {
      case "la":
        return _currentPrayer!.titleLa;
      case "my":
        return _currentPrayer!.titleMy;
      default:
        return _currentPrayer!.title;
    }
  }
}
