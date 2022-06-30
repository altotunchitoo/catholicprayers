class CategoryModel {
  int id, order;
  String title, titleLa, titleMy, theme;
  List<int> prayerIds;

  CategoryModel({
    required this.id,
    required this.order,
    required this.title,
    required this.titleLa,
    required this.titleMy,
    required this.theme,
    required this.prayerIds,
  });

  int getTheme() {
    if (theme.trim().isNotEmpty) return int.parse(theme);
    return 0xff5c80bc;
  }
}
