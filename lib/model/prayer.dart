import 'package:catholic_prayers/service/database_helper.dart';

class PrayerModel {
  int id, order, favorite, categoryOrder;
  String title, content, titleLa, contentLa, titleMy, contentMy;

  PrayerModel({
    required this.id,
    required this.title,
    required this.content,
    required this.titleLa,
    required this.contentLa,
    required this.titleMy,
    required this.contentMy,
    required this.order,
    required this.favorite,
    required this.categoryOrder,
  });

  bool getFavorite() {
    return (favorite == 1);
  }

  static PrayerModel? fromMap(Map<String, Object>? map) {
    if (map == null) return null;
    PrayerModel? temp = PrayerModel(
      id: map[DatabaseHelper.columnPid] as int,
      title: map[DatabaseHelper.columnTen] as String,
      content: map[DatabaseHelper.columnCen] as String,
      titleLa: map[DatabaseHelper.columnTla] as String,
      contentLa: map[DatabaseHelper.columnCla] as String,
      titleMy: map[DatabaseHelper.columnTmy] as String,
      contentMy: map[DatabaseHelper.columnCmy] as String,
      order: map[DatabaseHelper.columnOrder] as int,
      favorite: map[DatabaseHelper.columnFavorite] as int,
      categoryOrder: 0,
    );
    return temp;
  }
}
