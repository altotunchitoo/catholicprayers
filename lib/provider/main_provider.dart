import 'dart:convert';
import 'dart:io';
import 'package:catholic_prayers/model/days.dart';
import 'package:catholic_prayers/service/third_party_api.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/timeago_my_messages.dart';
import 'package:catholic_prayers/model/Category.dart';
import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/model/image.dart';
import 'package:catholic_prayers/service/api.dart';
import 'package:catholic_prayers/service/cache.dart';
import 'package:catholic_prayers/service/database_helper.dart';
import 'package:catholic_prayers/util/log.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../l10n/l10n.dart';

class MainProvider extends ChangeNotifier {
  ///
  int _index = 0;

  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  ///
  String _version = "Loading", _lang = "en", _theme = "system";
  String? _versionName = "Loading", _buildNumber = "Loading";
  String? _verseTitle, _verseContent, _lastSync, _splitLang;
  bool _firstTimeAndError = false;
  int _homeSelectedIndex = -1,
      _favSelectedIndex = -1,
      _homeSelectedId = -1,
      _favSelectedId = -1,
      _textSize = 19;
  List<PrayerModel> _prayers = [], _favoritePrayers = [];
  List<int> _favoriteIndex = [];
  List<ImageModel> _banners = [];
  List<CategoryModel> _categories = [];
  final _dbHelper = DatabaseHelper.instance;
  final Cache _cache = Cache();
  Locale? _currentLocale = const Locale('en');
  late SharedPreferences prefs;
  bool _showedIntro = true;
  bool _subscribeVerse = true;
  final API _api = API();
  final ThirdPartyApi _thirdApi = ThirdPartyApi();
  Days? _days;

  MainProvider() {
    _theme = AppLib.getInstance().theme;
  }

  // Initialize the whole app

  void initApp(BuildContext context) async {
    timeago.setLocaleMessages('my', MyMessages());
    prefs = await SharedPreferences.getInstance();
    final String? locale = prefs.getString("localization");
    final String? tempDailyVerse = prefs.getString("daily_verse");
    if (tempDailyVerse != null && tempDailyVerse == "no") {
      _subscribeVerse = false;
    } else {
      _subscribeVerse = true;
    }
    if (locale != null && locale == "my") {
      _currentLocale = const Locale('my');
    } else {
      _currentLocale = const Locale('en');
    }
    // to stop lagging in switching theme, I called notifyListeners() first. :P
    notifyListeners();
    _verseTitle = prefs.getString("verse_title");
    _verseContent = prefs.getString("verse_content");
    _lang = prefs.getString("language") ?? "en";
    _textSize = int.parse(prefs.getString("text_size") ?? "19");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = "${packageInfo.version} (${packageInfo.buildNumber})";
    _versionName = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    await _migrateAndHandleFavPrayers(prefs);
    _showedIntro = prefs.getBool("showedIntro") ?? false;
    // SHOW CACHED DAILY READINGS
    final String? cachedDailyReadings =
        await _cache.getCached("daily_readings");
    if (cachedDailyReadings != null && cachedDailyReadings.trim().isNotEmpty) {
      try {
        final Days tempDays = Days.fromJson(json.decode(cachedDailyReadings));
        _days = tempDays;
      } catch (e) {
        if (Platform.isAndroid || Platform.isIOS) {
          FirebaseCrashlytics.instance.recordError(e, null);
        }
      }
    }
    notifyListeners();
    await _getPrayerCategory();
    await _getAllPrayers();
    await _getVerse();
    await _getDays();
  }

  void introDone() {
    prefs.setBool("showedIntro", true);
    showedIntro = true;
  }

  Locale get currentLocale => _currentLocale ?? const Locale('en');

  set currentLocale(Locale value) {
    if (!L10n.all.contains(value)) return;
    _currentLocale = value;
    prefs.setString('localization', value.languageCode);
    notifyListeners();
  }

  Future<void> refresh() async {
    _firstTimeAndError = false;
    _verseContent = null;
    _prayers = [];
    _banners = [];
    _categories = [];
    notifyListeners();
    await _getPrayerCategory();
    await _getAllPrayers();
    await _getVerse();
    await _getDays();
  }

  // Getting prayers from Server via API

  Future<void> _getAllPrayers() async {
    List<PrayerModel> tempPrayers = [];
    final Response? res = await _api.getAllPrayers();
    if (res != null && res.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(res.data);
      if (response["status"] == "ok") {
        await _cache.saveCached(
          "prayers",
          res.data.toString(),
        ); // cache json data
        tempPrayers = _handlePrayers(response);
      }
    } else {
      tempPrayers = await _loadPrayersCached();
    }
    _prayers = tempPrayers;
    _filterFavPrayers(notify: false);
    Log.d("_getAllPrayers : ${_prayers.length}");
    notifyListeners();
  }

  Future<void> _getPrayerCategory() async {
    List<CategoryModel> tempCategories = [];
    final Response? res = await _api.getPrayerCategory();
    if (res != null && res.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(res.data);
      if (response["status"] == "ok") {
        await _cache.saveCached(
          "categories",
          res.data.toString(),
        ); // cache json data
        tempCategories = _handleCategories(response);
      }
    } else {
      tempCategories = await _loadCategoriesCached();
    }
    _categories = tempCategories;
    Log.d("_getPrayerCategory : ${_categories.length}");
    notifyListeners();
  }

  Future<void> _getVerse() async {
    final Response? res = await _api.getVerse();
    if (res != null && res.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(res.data);
      if (response["status"] == "ok") {
        _verseTitle = response['verse']['title'];
        _verseContent = response['verse']['content'];
        prefs.setString("verse_title", _verseTitle ?? "");
        prefs.setString("verse_content", _verseContent ?? "");
        Log.d("_getVerse : ${_verseTitle ?? ""}");
      }
    } else {
      _verseTitle = prefs.getString("verse_title");
      _verseContent = prefs.getString("verse_content");
      _firstTimeAndError = (_lastSync == null);
    }
    notifyListeners();
  }

  Future<void> _getDays() async {
    final Response? res = await _thirdApi.getRomanOrdinaryCalenderDays();
    if (res != null) {
      try {
        final Days temp = Days.fromJson(res.data);
        _days = temp;
        await _cache.saveCached('daily_readings', json.encode(res.data));
      } catch (e) {
        _days = null;
        if (Platform.isAndroid || Platform.isIOS) {
          FirebaseCrashlytics.instance.recordError(e, null);
        }
      }
      notifyListeners();
    }
  }

  void _filterFavPrayers({bool notify = true}) {
    List<PrayerModel> temp =
        _prayers.where((element) => (element.favorite == 1)).toList();
    if (notify) {
      favoritePrayers = temp;
    } else {
      _favoritePrayers = temp;
    }
  }

  Future<void> toggleFavorite({
    required PrayerModel prayerItem,
    required isFav,
  }) async {
    if (prayerItem.getFavorite()) {
      _favoriteIndex.add(prayerItem.id);
    } else {
      _favoriteIndex.remove(prayerItem.id);
    }
    for (int i = 0; i < _prayers.length; i++) {
      if (_prayers[i].id == prayerItem.id) {
        _prayers[i] = prayerItem;
        break;
      }
    }
    _filterFavPrayers();
    _cache.saveCached("fav_indexes", _favoriteIndex.join(','));
    if (isFav) _favSelectedIndex = -1;
  }

  Future<List<PrayerModel>> _loadPrayersCached() async {
    String? result = await _cache.getCached("prayers");
    if (result == null) return [];
    Map<String, dynamic> response = jsonDecode(result);
    if (response["status"] == "ok") return _handlePrayers(response);
    return [];
  }

  Future<List<CategoryModel>> _loadCategoriesCached() async {
    String? result = await _cache.getCached("categories");
    if (result == null) return [];
    Map<String, dynamic> response = jsonDecode(result);
    if (response["status"] == "ok") return _handleCategories(response);
    return [];
  }

  List<PrayerModel> _handlePrayers(Map<String, dynamic> response) {
    List<PrayerModel> temp = [];
    _lastSync = response["last_updated"];
    response["prayers"].forEach((item) async {
      PrayerModel prayer = PrayerModel(
        id: item["id"],
        title: item["title"],
        content: item["content"],
        titleLa: item["title_la"],
        contentLa: item["content_la"],
        titleMy: item["title_my"],
        contentMy: item["content_my"],
        order: item["order"],
        favorite: 0,
        categoryOrder: -1,
      );
      prayer.favorite = (_favoriteIndex.contains(prayer.id)) ? 1 : 0;
      temp.add(prayer);
    });
    return temp;
  }

  List<CategoryModel> _handleCategories(Map<String, dynamic> response) {
    List<CategoryModel> tempCategories = [];
    response["categories"].forEach((item) async {
      List<int> prayerIds = [];
      item["prayers"].forEach((prayer) => prayerIds.add(prayer["prayer"]));
      CategoryModel category = CategoryModel(
        id: item["id"],
        order: item["order"],
        title: item["title"],
        titleLa: item["title_la"],
        titleMy: item["title_my"],
        theme: item["theme"],
        prayerIds: prayerIds,
      );
      tempCategories.add(category);
    });
    return tempCategories;
  }

  Future<void> _migrateAndHandleFavPrayers(SharedPreferences prefs) async {
    bool? temp = prefs.getBool("migrations_13");
    if (temp == null || !temp) {
      List<PrayerModel> temp = await _queryFav();
      List<int> tempIndex = [];
      for (var element in temp) {
        tempIndex.add(element.id);
      }
      _favoriteIndex = tempIndex;
      _cache.saveCached("fav_indexes", tempIndex.join(','));
      prefs.setBool("migrations_13", true);
      Log.d("Migrated favorite indexes : ${tempIndex.length}");
    } else {
      String? tempFavString = await _cache.getCached("fav_indexes");
      _favoriteIndex =
          (tempFavString != null && tempFavString.trim().isNotEmpty)
              ? tempFavString.split(',').map(int.parse).toList()
              : [];
    }
  }

  Future<List<PrayerModel>> getCategoryPrayers(List<int> prayerIds) async {
    List<PrayerModel> tempPrayers = [];
    for (var tempPrayer in _prayers) {
      for (var id in prayerIds) {
        if (tempPrayer.id == id) {
          tempPrayer.categoryOrder = prayerIds.indexOf(tempPrayer.id);
          tempPrayers.add(tempPrayer);
        }
      }
    }
    tempPrayers.sort((a, b) => a.categoryOrder.compareTo(b.categoryOrder));
    return tempPrayers;
  }

  bool isFav({required int id}) {
    return _favoriteIndex.contains(id);
  }

  // Getters and Setters

  TextStyle getCategoryTextStyle() {
    if (_lang == "my") {
      return const TextStyle(
        fontFamily: 'PyiDaungSu',
        fontWeight: FontWeight.normal,
        height: 1.7,
      );
    } else {
      return GoogleFonts.roboto();
    }
  }

  TextStyle getTitleTextStyle() => (_lang == "my")
      ? const TextStyle(fontFamily: 'PyiDaungSu')
      : const TextStyle();

  TextStyle getListTextStyle(
    BuildContext context,
    int id,
    bool isFav,
    bool isCategory,
  ) {
    Color? color = Theme.of(context).textTheme.bodyText2?.color;
    if (_lang == "my") {
      return TextStyle(
        fontFamily: 'PyiDaungSu',
        color: color,
        fontWeight: FontWeight.normal,
        height: 1.7,
      );
    } else {
      return GoogleFonts.roboto().copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      );
    }
  }

  String get version => _version;

  String getLogo(BuildContext context) {
    if (Theme.of(context).textTheme.bodyText2?.color == CupertinoColors.white) {
      return "assets/images/logo_only_white.png";
    }
    return "assets/images/logo_only.png";
  }

  String getLang({bool code = false}) {
    if (code) return _lang;
    switch (_lang) {
      case "my":
        return "မြန်မာစာ";
      case "la":
        return "Latin";
      default:
        return "English";
    }
  }

  String getPrayerLangNote() {
    switch (_lang) {
      case "my":
        return "ခမည်းတော်၊ သားတော်၊ သန့်ရှင်းသော ဝိညာဉ်တော်၏ နာမတော်မြတ်နှင့်၊ \nအာမင်။";
      case "la":
        return "In nómine Patris, et Fílii, et Spíritus Sancti. \nAmén.";
      default:
        return "In the name of the Father, and of the Son, and of the Holy Spirit. \nAmen.";
    }
  }

  String getLocale({bool code = false}) {
    if (code) return _currentLocale?.languageCode ?? "en";
    switch (_currentLocale?.languageCode ?? "en") {
      case "my":
        return "မြန်မာစာ";
      default:
        return "English";
    }
  }

  String getLangFlag() {
    switch (_lang) {
      case "my":
        return "assets/images/myanmar_flag.png";
      case "la":
        return "assets/images/vatican_flag.png";
      default:
        return "assets/images/uk_flag.png";
    }
  }

  set lang(String value) {
    _lang = value;
    notifyListeners();
  }

  String get theme => _theme;

  set theme(String value) {
    _theme = value;
    AppLib.getInstance().theme = value;
    notifyListeners();
  }

  ThemeMode getTheme() {
    switch (_theme) {
      case "day":
        return ThemeMode.light;
      case "night":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String getActiveTheme({bool code = false}) {
    if (code) return _theme;
    switch (_theme) {
      case "day":
        return "Light Theme";
      case "night":
        return "Dark Theme";
      default:
        return "Follow System";
    }
  }

  Icon getItemFav(bool isFav, Color color) {
    PrayerModel? temp = isFav
        ? ((_favSelectedIndex != -1)
            ? _favoritePrayers[_favSelectedIndex]
            : null)
        : ((_homeSelectedIndex != -1) ? _prayers[_homeSelectedIndex] : null);
    bool isFavorite = temp != null && temp.getFavorite();
    return Icon(
      isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      color: color,
    );
  }

  int getSelectedIndex(bool isFav) =>
      isFav ? _favSelectedIndex : _homeSelectedIndex;

  void setSelectedIndex(int index, int id, bool isFav) {
    if (isFav) {
      _favSelectedIndex = index;
      _favSelectedId = id;
    } else {
      _homeSelectedIndex = index;
      _homeSelectedId = id;
    }
    notifyListeners();
  }

  int getSelectedPrayerId(bool isFav) =>
      isFav ? _favSelectedId : _homeSelectedId;

  Widget getListTile(
    BuildContext context,
    int id,
    bool isFav,
    bool isCategory,
  ) {
    bool active = (isFav
        ? (_favSelectedId == id ? true : false)
        : (_homeSelectedId == id ? true : false));
    return Icon(
      (isCategory || !active)
          ? CupertinoIcons.chevron_right
          : CupertinoIcons.flag,
      color: Theme.of(context).textTheme.bodyText2?.color,
      size: 23.0,
    );
  }

  Color? getListItemColor(
    BuildContext context,
    int id,
    bool isFav,
    bool isCategory,
  ) {
    return isCategory
        ? Theme.of(context).textTheme.bodyText2?.color
        : (isFav
            ? (_favSelectedId == id
                ? Theme.of(context).textTheme.subtitle1?.color
                : Theme.of(context).textTheme.bodyText2?.color)
            : (_homeSelectedId == id
                ? Theme.of(context).textTheme.subtitle1?.color
                : Theme.of(context).textTheme.bodyText2?.color));
  }

  bool get showedIntro => _showedIntro;

  set showedIntro(bool value) {
    _showedIntro = value;
    notifyListeners();
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return _lang == "la"
          ? "Bonum mane"
          : (_lang == "my" ? "မင်္ဂလာနံနက်ခင်းပါ" : "Good Morning");
    }
    if (hour < 17) {
      return _lang == "la"
          ? "Bona dies"
          : (_lang == "my" ? "မင်္ဂလာနေ့လည်ခင်းပါ" : "Good Afternoon");
    }
    return _lang == "la"
        ? "Bonum vesperam"
        : (_lang == "my" ? "မင်္ဂလာညနေခင်းပါ" : "Good Evening");
  }

  Future<void> setValue(String key, String value) async {
    await prefs.setString(key, value);
    switch (key) {
      case "language":
        lang = value;
        break;
      case "theme":
        theme = value;
        break;
      case "text_size":
        _textSize = int.parse(value);
        break;
    }
  }

  Object? getValue(String key) {
    return prefs.get(key);
  }

  String getPrayerTitle(PrayerModel prayer, {String? lang}) {
    switch (lang ?? _lang) {
      case "la":
        return prayer.titleLa;
      case "my":
        return prayer.titleMy;
      default:
        return prayer.title;
    }
  }

  String getPrayerText() {
    switch (_lang) {
      case "la":
        return "Catholicae Preces";
      case "my":
        return "ဆုတောင်းမေတ္တာများ";
      default:
        return "Catholic Prayers";
    }
  }

  String getCategoryTitle(CategoryModel category) {
    switch (_lang) {
      case "la":
        return category.titleLa;
      case "my":
        return category.titleMy;
      default:
        return category.title;
    }
  }

  String getPrayerContent(PrayerModel prayer, {String? lang}) {
    switch (lang ?? _lang) {
      case "la":
        return prayer.contentLa;
      case "my":
        return prayer.contentMy;
      default:
        return prayer.content;
    }
  }

  int get textSize => _textSize;

  List<PrayerModel> get prayers => _prayers;

  get favoritePrayers => _favoritePrayers;

  set favoritePrayers(value) {
    _favoritePrayers = value;
    notifyListeners();
  }

  bool get firstTimeAndError => _firstTimeAndError;

  List<CategoryModel> get categories => _categories;

  List<ImageModel> get banners => _banners;

  String? get verseContent => _verseContent;

  String? get verseTitle => _verseTitle;

  get lastSync => _lastSync;

  get buildNumber => _buildNumber;

  String? get versionName => _versionName;

  String? get splitLang => _splitLang;

  set splitLang(String? value) {
    _splitLang = value;
    notifyListeners();
  }

  bool get subscribeVerse => _subscribeVerse;

  set subscribeVerse(bool value) {
    _subscribeVerse = value;
    prefs.setString("daily_verse", (value ? "yes" : "no"));
    notifyListeners();
  }

  Days? get days => _days;

  Future<List<PrayerModel>> _queryFav() async {
    final allRows = await _dbHelper.queryAllFavoriteRows();
    List<PrayerModel> prayers = [];
    if (allRows != null) {
      for (var item in allRows) {
        PrayerModel temp = PrayerModel(
          id: item[DatabaseHelper.columnPid],
          title: item[DatabaseHelper.columnTen],
          content: item[DatabaseHelper.columnCen],
          titleLa: item[DatabaseHelper.columnTla],
          contentLa: item[DatabaseHelper.columnCla],
          titleMy: item[DatabaseHelper.columnTmy],
          contentMy: item[DatabaseHelper.columnCmy],
          order: item[DatabaseHelper.columnOrder],
          favorite: item[DatabaseHelper.columnFavorite],
          categoryOrder: -1,
        );
        prayers.add(temp);
      }
    }
    return prayers;
  }
}
