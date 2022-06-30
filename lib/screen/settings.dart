import 'dart:io';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/screen/about.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/util/log.dart';
import 'package:catholic_prayers/util/secret.dart';
import 'package:catholic_prayers/widget/toggler.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late MainProvider _mainReader;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mainReader = context.read<MainProvider>();
    if (_mainReader.subscribeVerse) _subscribe();
  }

  Future _subscribe() async {
    await FirebaseMessaging.instance.subscribeToTopic('verse').onError(
      (error, stackTrace) {
        if (Platform.isAndroid || Platform.isMacOS) {
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
        }
      },
    );
    Log.d("Subscribed");
  }

  Future _unSubscribe() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('verse').onError(
      (error, stackTrace) {
        if (Platform.isAndroid || Platform.isMacOS) {
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
        }
      },
    );
    Log.d("unSubscribed");
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MainProvider mainWatcher = context.watch<MainProvider>();
    final kDivider = Container(
      margin: const EdgeInsets.only(left: 51, right: 13, top: 2, bottom: 2),
      color: themeData.dividerColor.withOpacity(0.3),
      width: double.infinity,
      height: 1,
    );
    return Container(
      color: themeData.scaffoldBackgroundColor,
      child: ListView(
        primary: false,
        physics: const BouncingScrollPhysics(),
        children: [
          kSpacer,
          kSpacer,
          SettingContainerWidget(
            title: context.l10n.appearance,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.device_phone_portrait,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Expanded(
                        child: Text(
                          context.l10n.follow_sys,
                          style: GoogleFonts.lato(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      TogglerWidget(
                        onChanged: (_) async {
                          HapticFeedback.lightImpact();
                          await _mainReader.setValue(
                            "theme",
                            _ ? "system" : "day",
                          );
                        },
                        active:
                            mainWatcher.getActiveTheme(code: true) == "system",
                      ),
                    ],
                  ),
                ),
                if (mainWatcher.getActiveTheme(code: true) != "system") ...[
                  kDivider,
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.moon_stars,
                          color: themeData.textTheme.bodyText2?.color,
                        ),
                        kSpacerH,
                        Expanded(
                          child: Text(
                            context.l10n.night_theme,
                            style: GoogleFonts.lato(
                              fontSize: 17.0,
                              color: themeData.textTheme.bodyText2?.color,
                            ),
                          ),
                        ),
                        TogglerWidget(
                          active:
                              mainWatcher.getActiveTheme(code: true) == "night",
                          onChanged: (_) async {
                            if (_mainReader.getActiveTheme(code: true) !=
                                "system") {
                              HapticFeedback.lightImpact();
                              await _mainReader.setValue(
                                "theme",
                                _ ? "night" : "day",
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SettingContainerWidget(
            title: context.l10n.notification,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.bell,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Expanded(
                        child: Text(
                          context.l10n.daily_verse,
                          style: GoogleFonts.lato(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: _isLoading
                            ? const Center(
                                child: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: CupertinoActivityIndicator(),
                              ))
                            : TogglerWidget(
                                onChanged: (_) async {
                                  HapticFeedback.lightImpact();
                                  setState(() => _isLoading = true);
                                  if (_mainReader.subscribeVerse) {
                                    await _unSubscribe();
                                    _mainReader.subscribeVerse = false;
                                    AppLib.getInstance().showKToast(
                                      context: context,
                                      message: context.l10n.unsubscribe_verse,
                                    );
                                  } else {
                                    await _subscribe();
                                    _mainReader.subscribeVerse = true;
                                    AppLib.getInstance().showKToast(
                                      context: context,
                                      message: context.l10n.subscribe_verse,
                                    );
                                  }
                                  setState(() => _isLoading = false);
                                },
                                active: mainWatcher.subscribeVerse,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SettingContainerWidget(
            title: context.l10n.languages,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoButton(
                  pressedOpacity: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language_outlined,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Expanded(
                        child: Text(
                          context.l10n.language,
                          style: TextStyle(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: themeData.textTheme.bodyText2?.color,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () =>
                      AppLib.getInstance().showLanguages(context: context),
                ),
                kDivider,
                CupertinoButton(
                  pressedOpacity: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.book,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Text(
                        mainWatcher.getLang(),
                        style: TextStyle(
                          fontSize: 17.0,
                          color: themeData.textTheme.bodyText2?.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.l10n.lang_for_prayers,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: themeData.textTheme.bodyText2?.color,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () => AppLib.getInstance()
                      .showLanguagesForPrayer(context: context),
                ),
              ],
            ),
          ),
          SettingContainerWidget(
            title: context.l10n.about_catholic_prayers,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[
                  CupertinoButton(
                    pressedOpacity: 1,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 3),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync,
                          color: themeData.textTheme.bodyText2?.color,
                        ),
                        kSpacerH,
                        Text(
                          context.l10n.last_sync,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                        Expanded(
                          child: Timeago(
                            builder: (context, text) {
                              return Text(
                                text,
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.end,
                                style: GoogleFonts.lato(
                                  fontSize: 15.0,
                                  color: themeData.textTheme.bodyText2?.color!
                                      .withOpacity(0.7),
                                ),
                              );
                            },
                            locale: mainWatcher.currentLocale.languageCode,
                            date: DateTime.parse(
                                mainWatcher.lastSync ?? "0000-00-00"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  kDivider,
                ],
                CupertinoButton(
                  pressedOpacity: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Expanded(
                        child: Text(
                          context.l10n.app_info,
                          style: GoogleFonts.lato(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: themeData.textTheme.bodyText2?.color,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    AppLib.getInstance()
                        .pushRoute(context, const AboutScreen());
                  },
                ),
                kDivider,
                CupertinoButton(
                  pressedOpacity: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.contact_support_outlined,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Expanded(
                        child: Text(
                          context.l10n.contact,
                          style: GoogleFonts.lato(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: themeData.textTheme.bodyText2?.color,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    String fbProtocolUrl;
                    if (Platform.isIOS) {
                      fbProtocolUrl = 'fb://profile/$FB_PAGE_ID';
                    } else if (Platform.isAndroid) {
                      fbProtocolUrl = 'fb://page/$FB_PAGE_ID';
                    } else {
                      fbProtocolUrl =
                          "https://www.facebook.com/TheCatholicPrayers";
                    }
                    AppLib.getInstance().launchInBrowser(
                      context: context,
                      url: fbProtocolUrl,
                      fallback: "https://www.facebook.com/TheCatholicPrayers",
                      safariV: false,
                    );
                  },
                ),
                kDivider,
                CupertinoButton(
                  pressedOpacity: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Expanded(
                        child: Text(
                          context.l10n.rate_app,
                          style: GoogleFonts.lato(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: themeData.textTheme.bodyText2?.color,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    String link = "https://altotunchitoo.me/catholic-prayers";
                    if (Platform.isAndroid) {
                      link += "?d=android&a=rate";
                    } else if (Platform.isIOS) {
                      link += "?d=ios&a=rate";
                    } else if (Platform.isMacOS) {
                      link += "?d=macos&a=rate";
                    }

                    String appUrl =
                        "market://details?id=me.altotunchitoo.prayers";
                    AppLib.getInstance().launchInBrowser(
                      context: context,
                      url: Platform.isAndroid ? appUrl : link,
                      fallback: link,
                    );
                  },
                ),
                kDivider,
                CupertinoButton(
                  pressedOpacity: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.share,
                        color: themeData.textTheme.bodyText2?.color,
                      ),
                      kSpacerH,
                      Expanded(
                        child: Text(
                          context.l10n.share_app,
                          style: GoogleFonts.lato(
                            fontSize: 17.0,
                            color: themeData.textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: themeData.textTheme.bodyText2?.color,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    String link = "https://altotunchitoo.me/catholic-prayers";
                    if (Platform.isAndroid) {
                      link += "?d=android";
                    } else if (Platform.isIOS) {
                      link += "?d=ios";
                    } else if (Platform.isMacOS) {
                      link += "?d=macos";
                    }

                    await Share.share(
                      "Catholic Prayers in Myanmar, English and Latin languages.\n\n$link",
                      subject: "Catholic Prayers Application",
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              context.l10n.may_god_bless,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingContainerWidget extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingContainerWidget(
      {Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 17.0),
          width: double.infinity,
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 10.0,
              color: themeData.hintColor,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: themeData.textTheme.button?.color,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.symmetric(vertical: 3),
          width: double.infinity,
          child: child,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
