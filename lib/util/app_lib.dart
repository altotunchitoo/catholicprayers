import 'dart:io';

import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';

class AppLib {
  static AppLib? _instance;

  static AppLib getInstance() {
    _instance ??= AppLib();
    return _instance!;
  }

  String theme = "system";

  Future setupTheme() async {
    final prefs = await SharedPreferences.getInstance();
    theme = prefs.getString("theme") ?? "system";
  }

  void showKToast({
    required BuildContext context,
    required String message,
    bool dismissAll = true,
  }) {
    if (dismissAll) ToastManager().dismissAll(showAnim: true);
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.slideFromBottom,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.bottom,
      animDuration: const Duration(milliseconds: 1000),
      duration: const Duration(milliseconds: 2500),
      curve: Curves.fastLinearToSlowEaseIn,
      reverseCurve: Curves.linear,
    );
  }

  void showSnack({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).textTheme.subtitle1?.color,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  void showAlert({
    required BuildContext context,
    String title = "Alert",
    required String message,
    CupertinoDialogAction? dismissAction,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Text(title),
        ),
        content: Text(message),
        actions: [
          if (dismissAction == null)
            CupertinoDialogAction(
              child: const Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          else
            dismissAction,
        ],
      ),
    );
  }

  void showConfirmBox({
    required BuildContext context,
    String title = "Alert",
    required String message,
    required CupertinoDialogAction action,
    CupertinoDialogAction? dismissAction,
    String dismiss = "Dismiss",
    bool dismissible = true,
  }) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Text(title),
        ),
        content: Text(message),
        actions: [
          if (dismissAction == null)
            CupertinoDialogAction(
              isDefaultAction: false,
              child: Text(dismiss),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          else
            dismissAction,
          action,
        ],
      ),
    );
  }

  Future<void> launchInBrowser({
    required BuildContext context,
    required String url,
    required String fallback,
    bool safariV = true,
  }) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        bool launched = await launchUrl(uri);
        if (!launched) {
          await launchUrl(Uri.parse(fallback));
        }
      } else {
        await launchUrl(Uri.parse(fallback));
      }
    } on PlatformException catch (e) {
      if (Platform.isAndroid || Platform.isIOS) {
        FirebaseCrashlytics.instance.recordError(e, null, printDetails: false);
      }
    }
  }

  Future<void> showLanguages({
    required BuildContext context,
  }) async {
    HapticFeedback.lightImpact();
    MainProvider mainProvider = context.read<MainProvider>();
    String lang = mainProvider.currentLocale.languageCode;
    var result =
        await _showLanguages(context: context, lang: lang, hideLang: "la");
    if (result != null && result != "cancel") {
      HapticFeedback.mediumImpact();
      mainProvider.currentLocale = Locale(result);
    }
  }

  Future<void> showLanguagesForPrayer({
    required BuildContext context,
  }) async {
    HapticFeedback.lightImpact();
    final MainProvider mainProvider = context.read<MainProvider>();
    final String lang = mainProvider.getLang(code: true);
    var result = await _showLanguages(context: context, lang: lang);
    if (result != null && result != "cancel") {
      HapticFeedback.lightImpact();
      mainProvider.setValue("language", result);
      mainProvider.splitLang = null;
    }
  }

  Future<dynamic> showSplitLanguage({required BuildContext context}) async {
    HapticFeedback.lightImpact();
    final MainProvider mainProvider = context.read<MainProvider>();
    final String lang = mainProvider.getLang(code: true);
    return await _showLanguages(
      context: context,
      lang: mainProvider.splitLang ?? "",
      hideLang: lang,
      showCloseSplitView: true,
    );
  }

  Future<dynamic> _showLanguages({
    required BuildContext context,
    required String lang,
    String? hideLang,
    bool showCancel = false,
    bool showCloseSplitView = false,
  }) async {
    final kDivider = Container(
      width: double.infinity,
      height: 1,
      margin: const EdgeInsets.only(left: 50, right: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(1),
      ),
    );
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.button?.color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Container(
                      width: 45,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    kSpacer,
                    if (hideLang != "en") ...[
                      _languageItem(
                        context,
                        "uk_flag",
                        'English',
                        "en",
                        lang == "en",
                        split: showCloseSplitView,
                      ),
                      kDivider,
                    ],
                    if (hideLang != "la")
                      _languageItem(
                        context,
                        "vatican_flag",
                        'Latin',
                        "la",
                        lang == "la",
                        split: showCloseSplitView,
                      ),
                    if (hideLang != "my") ...[
                      if (hideLang != "la") kDivider,
                      _languageItem(
                        context,
                        "myanmar_flag",
                        'မြန်မာစာ',
                        "my",
                        lang == "my",
                        split: showCloseSplitView,
                      ),
                    ],
                    if (showCancel) ...[
                      kSpacer,
                      CupertinoButton(
                        pressedOpacity: 1,
                        minSize: 20,
                        padding: EdgeInsets.zero,
                        child: Text(
                          context.l10n.cancel,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop("cancel"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String localizeNumber({
    required int? num,
    String? locale,
  }) {
    if (num == null) return "";
    return NumberFormat.decimalPattern(locale).format(num);
  }

  String removeMarkDown(String? text) {
    if (text == null) return "";
    String result = text;
    while (result.contains('[[')) {
      result = _rmMd(result);
    }
    return result;
  }

  String _rmMd(String text) {
    final int firstIndex = text.indexOf('[[');
    final int lastIndex = text.indexOf(']]');
    final String toRm = text.substring(firstIndex, lastIndex);
    return text.replaceAll("$toRm]]", "");
  }

  Future<dynamic> pushRoute(BuildContext context, Widget widget) async {
    Route<dynamic> route = MaterialPageRoute(builder: (context) => widget);
    if (Platform.isIOS) {
      route = CupertinoPageRoute(builder: (context) => widget);
    }
    return await Navigator.of(context).push(route);
  }

  Widget _languageItem(
    BuildContext context,
    String flag,
    String title,
    String action,
    bool selected, {
    bool split = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: CupertinoButton(
        pressedOpacity: 1,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/images/$flag.png",
              width: 27,
              height: 27,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lato(
                  color: Theme.of(context).textTheme.bodyText2?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.checkmark_alt,
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
            ),
          ],
        ),
        onPressed: () {
          Navigator.of(context).pop((selected && split) ? "cancel" : action);
        },
      ),
    );
  }
}

extension IsDarkMode on BuildContext {
  bool isDarkMode() {
    return (Theme.of(this).scaffoldBackgroundColor == kBgDarkColor);
  }
}
