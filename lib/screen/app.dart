import 'dart:convert';
import 'dart:io';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/screen/favorites.dart';
import 'package:catholic_prayers/screen/home.dart';
import 'package:catholic_prayers/screen/intro.dart';
import 'package:catholic_prayers/screen/settings.dart';
import 'package:catholic_prayers/service/api.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/util/log.dart';
import 'package:catholic_prayers/widget/app_widgets.dart';
import 'package:catholic_prayers/widget/support_dev.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  final AdvancedDrawerController _advancedDrawerController =
      AdvancedDrawerController();
  final AppLib _appLib = AppLib.getInstance();
  bool _activeTabletDrawer = false;
  late MainProvider _mainReadProvider;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _mainReadProvider = context.read<MainProvider>();
    _mainReadProvider.initApp(context);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _advancedDrawerController.addListener(() {
      if (_advancedDrawerController.value == AdvancedDrawerValue.visible()) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    _handleFCM();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _advancedDrawerController.dispose();
  }

  void _handleFCM() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      FirebaseMessaging.instance.subscribeToTopic('app').onError(
        (error, stackTrace) {
          if (Platform.isAndroid || Platform.isMacOS) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
          }
        },
      );
      _firebaseCloudMessagingListeners(context);
    }
    await _checkUpdates();
  }

  Future<void> _checkUpdates() async {
    final API api = API();
    final Response? res = await api.getLatestVersionCode();
    if (res != null && res.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(res.data);
      if (response["status"] == "ok") {
        final String? code = response["code"];
        await _mainReadProvider.setValue("latest_build", code ?? "0");
        final current = _mainReadProvider.buildNumber;
        if (code != null) {
          final int latest = int.parse(code);
          final int app = int.parse(current);
          if (app < latest) {
            _appLib.showConfirmBox(
              context: context,
              dismissible: false,
              title: context.l10n.new_version,
              message: context.l10n.pls_update_to_latest,
              dismiss: context.l10n.cancel,
              action: CupertinoDialogAction(
                child: Text(context.l10n.update),
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchAppStore();
                },
              ),
            );
          }
        }
      }
    }
  }

  void _launchAppStore() {
    HapticFeedback.lightImpact();
    String link = "https://altotunchitoo.me/catholic-prayers";
    if (Platform.isAndroid) {
      link += "?d=android";
    } else if (Platform.isIOS) {
      link += "?d=ios";
    } else if (Platform.isMacOS) {
      link += "?d=macos";
    }

    _appLib.launchInBrowser(
      context: context,
      url: Platform.isAndroid
          ? "market://details?id=me.altotunchitoo.prayers"
          : link,
      fallback: link,
    );
  }

  Future<void> _onRefresh() async {
    Log.d("_onRefresh");
    HapticFeedback.mediumImpact();
    await _mainReadProvider.refresh();
  }

  void _supportDev() async {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
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
              padding: const EdgeInsets.all(20),
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
                    const SupportDevWidget(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_advancedDrawerController.value.visible) {
      _advancedDrawerController.hideDrawer();
      return false;
    }
    if (_mainReadProvider.index != 0) {
      _mainReadProvider.index = 0;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (size.width > 600 && size.height > 500) return _tabletUI(context);
    return _phoneUI(context);
  }

  Widget _tabletUI(BuildContext context) {
    final MainProvider provider = context.watch<MainProvider>();
    final List<String> titles = [
      context.l10n.home,
      context.l10n.favourites,
      context.l10n.settings,
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _activeTabletDrawer ? 300 : 0,
                  height: double.infinity,
                  child: const AppDrawerWidget(),
                ),
                Expanded(
                  child: Scaffold(
                    extendBody: true,
                    appBar: AppBar(
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                      leading: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _activeTabletDrawer = !_activeTabletDrawer;
                            if (_activeTabletDrawer) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          });
                        },
                        splashRadius: 22,
                        splashColor: Colors.transparent,
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.menu_arrow,
                          progress: _animationController,
                          color: kText,
                        ),
                      ),
                      title: Text(
                        provider.index == 0
                            ? provider.getGreeting()
                            : titles[provider.index],
                        style: GoogleFonts.lato().copyWith(
                          color: kText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        if (provider.index != 2)
                          IconButton(
                            onPressed: () => _appLib.showLanguagesForPrayer(
                                context: context),
                            splashColor: Colors.transparent,
                            icon: Container(
                              decoration: const BoxDecoration(
                                boxShadow: kBoxShadow,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                provider.getLangFlag(),
                                width: 23,
                                height: 23,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: _supportDev,
                            tooltip: "Support developer",
                            splashColor: Colors.transparent,
                            icon: Container(
                              decoration: const BoxDecoration(
                                boxShadow: kBoxShadow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.code_rounded),
                            ),
                          ),
                        const SizedBox(width: 2),
                      ],
                    ),
                    body: SafeArea(
                      child: IndexedStack(
                        index: provider.index,
                        children: [
                          Home(onRefresh: _onRefresh),
                          const Favorites(),
                          const Settings(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const IntroScreen(),
          ],
        ),
      ),
    );
  }

  Widget _phoneUI(BuildContext context) {
    final MainProvider provider = context.watch<MainProvider>();
    final List<String> titles = [
      context.l10n.home,
      context.l10n.favourites,
      context.l10n.settings,
    ];
    final Size size = MediaQuery.of(context).size;
    final double openRatio = (size.width > size.height) ? 0.8 : 0.75;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          AdvancedDrawer(
            controller: _advancedDrawerController,
            drawer: AppDrawerWidget(
                advancedDrawerController: _advancedDrawerController),
            animationCurve: Curves.easeInOut,
            backdropColor: context.isDarkMode() ? kDarkBackDrop : kBackDrop,
            animationDuration: const Duration(milliseconds: 300),
            animateChildDecoration: true,
            openRatio: openRatio,
            childDecoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Scaffold(
              extendBody: true,
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _advancedDrawerController.showDrawer();
                  },
                  splashRadius: 22,
                  splashColor: Colors.transparent,
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_arrow,
                    progress: _animationController,
                    color: kText,
                  ),
                ),
                title: Text(
                  provider.index == 0
                      ? provider.getGreeting()
                      : titles[provider.index],
                  style: GoogleFonts.lato().copyWith(
                    color: kText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  if (provider.index != 2)
                    IconButton(
                      onPressed: () =>
                          _appLib.showLanguagesForPrayer(context: context),
                      splashColor: Colors.transparent,
                      icon: Container(
                        decoration: const BoxDecoration(
                          boxShadow: kBoxShadow,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          provider.getLangFlag(),
                          width: 23,
                          height: 23,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _supportDev,
                      tooltip: "Support developer",
                      splashColor: Colors.transparent,
                      icon: Container(
                        decoration: const BoxDecoration(
                          boxShadow: kBoxShadow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.code_rounded),
                      ),
                    ),
                  const SizedBox(width: 2),
                ],
              ),
              body: SafeArea(
                child: IndexedStack(
                  index: provider.index,
                  children: [
                    Home(onRefresh: _onRefresh),
                    const Favorites(),
                    const Settings(),
                  ],
                ),
              ),
            ),
          ),
          const IntroScreen(),
        ],
      ),
    );
  }

  // FCM
  void _firebaseCloudMessagingListeners(BuildContext context) {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      // opened app from terminated
      if (message != null) {
        _appLib.showAlert(
          context: context,
          title: message.notification?.title ?? "",
          message: message.notification?.body ?? "",
        );
      }
    });
    FirebaseMessaging.onMessage.listen((message) {
      // foreground message
      _appLib.showAlert(
        context: context,
        title: message.notification?.title ?? "",
        message: message.notification?.body ?? "",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // background state (not terminated)
      _appLib.showAlert(
        context: context,
        title: message.notification?.title ?? "",
        message: message.notification?.body ?? "",
      );
    });
  }
}
