import 'dart:io';
import 'package:catholic_prayers/firebase_options.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/provider/prayer_screen_provider.dart';
import 'package:catholic_prayers/screen/app.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/custom_scroll_behavior.dart';
import 'package:catholic_prayers/util/log.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/l10n.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _setupFirebaseServices() async {
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        if (!Platform.isMacOS) {
          FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;
        }
        // Start FCM
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: false,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: false,
          sound: true,
        );
        // End FCM
      }
    }
  } catch (e) {
    Log.e(e);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );
  await AppLib.getInstance().setupTheme();
  await _setupFirebaseServices();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<MainProvider>(create: (_) => MainProvider()),
      ChangeNotifierProvider<PrayerScreenProvider>(
        create: (_) => PrayerScreenProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    return MaterialApp(
      title: "Catholic Prayers",
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      themeMode: mainProvider.getTheme(),
      supportedLocales: L10n.all,
      locale: mainProvider.currentLocale,
      localizationsDelegates: kLocalizations,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: child ?? const SizedBox(),
        );
      },
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
