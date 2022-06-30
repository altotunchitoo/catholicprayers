import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

const kMaxPrayerTextSize = 29;
const kMinPrayerTextSize = 11;
const kMinSplitView = 500;

const kAssetColor = Color(0xff3E7BFA);

const kLogoTheme = Color(0xff754a4a);
const kBackDrop = Color(0xff493434);
const kDarkBackDrop = Color(0xff21212f);
const kLogoTextTheme = Color(0xffEED6C4);
const kText = Color(0xfff2f2f2);

const kThemeColor = Color(0xff483434);
const kBgColor = Color(0xffEED6C4);

const kThemeDarkColor = Color(0xffFFF3E4);
const kBgDarkColor = Color(0xff1c1c27);
const kBgDarkSecColor = Color(0xff28293C);

const kGradient = LinearGradient(
  colors: [
    kLogoTheme,
    kThemeDarkColor,
  ],
);

const kHeroGradient = LinearGradient(
  colors: [
    Color(0xff754a4a),
    Color(0xee754a4a),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
);

const kDarkHeroGradient = LinearGradient(
  colors: [
    Color(0xff606177),
    Color(0xff4b4b5c),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
);

const kBoxShadow = [
  BoxShadow(
    color: Colors.black12,
    blurRadius: 7,
  ),
];
const kDrawerActiveTextStyle = TextStyle(fontFamily: 'Lato', color: kText);
const kDrawerTextStyle = TextStyle(fontFamily: 'Lato', color: Colors.white54);

const kDisabled = Color(0x55f2f2f2);
const kSpacer = SizedBox(height: 15.0);
const kSpacerH = SizedBox(width: 15.0);
const kSpacerSm = SizedBox(height: 5.0);

const kTextStyle = TextStyle(
  fontFamily: 'Lato',
  fontFamilyFallback: ['PyiDaungSu'],
  height: 1.7,
);

/// [kLightTheme] Light Theme for App
ThemeData kLightTheme = ThemeData.light().copyWith(
  primaryColor: kThemeColor,
  brightness: Brightness.light,
  scaffoldBackgroundColor: kBgColor,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  backgroundColor: kBgColor,
  dividerColor: CupertinoColors.systemGrey,
  hintColor: Colors.black87,
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    bodyText1: kTextStyle.copyWith(color: const Color(0xff050505)),
    bodyText2: const TextStyle(fontFamily: 'Lato', color: Color(0xff343434)),
    subtitle1: const TextStyle(fontFamily: 'Lato', color: kThemeColor),
    headline1: kTextStyle.copyWith(
        fontWeight: FontWeight.w500, color: CupertinoColors.black),
    headline2: const TextStyle(fontFamily: 'Lato', color: Colors.white),
    button: const TextStyle(color: Color(0xffFFF3E4)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kLogoTheme,
    elevation: 0.4,
    shadowColor: Colors.transparent,
    centerTitle: true,
    iconTheme: IconThemeData(color: kText),
    titleTextStyle: TextStyle(
      color: kText,
      fontSize: 19.0,
      fontWeight: FontWeight.w500,
    ),
  ),
);

/// [kDarkTheme] Dark Theme for App
ThemeData kDarkTheme = ThemeData.light().copyWith(
  primaryColor: kThemeDarkColor,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBgDarkColor,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  backgroundColor: kBgDarkColor,
  dividerColor: const Color(0xff4b4b5c),
  hintColor: const Color(0xff606177),
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    bodyText1: kTextStyle.copyWith(color: const Color(0xfffafafa)),
    bodyText2: const TextStyle(fontFamily: 'Lato', color: Color(0xFFb3b3b3)),
    subtitle1: const TextStyle(fontFamily: 'Lato', color: kThemeDarkColor),
    headline1: kTextStyle.copyWith(
        fontWeight: FontWeight.w500, color: CupertinoColors.white),
    headline2: const TextStyle(
        fontFamily: 'Lato', color: CupertinoColors.darkBackgroundGray),
    button: const TextStyle(color: kBgDarkSecColor),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBgDarkSecColor,
    elevation: 0.4,
    shadowColor: Colors.transparent,
    centerTitle: true,
    iconTheme: IconThemeData(color: kText),
    titleTextStyle: TextStyle(
      color: kText,
      fontSize: 19.0,
      fontWeight: FontWeight.w500,
    ),
  ),
);

///
const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
  'me.altotunchitoo.prayers', // id
  'Catholic Prayers', // title
  description: 'This channel is used for prayers notifications.',
  importance: Importance.high,
  enableVibration: true,
  playSound: true,
  showBadge: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

///
const kLocalizations = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];
