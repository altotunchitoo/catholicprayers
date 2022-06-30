import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:catholic_prayers/provider/main_provider.dart';

class AppDrawerWidget extends StatelessWidget {
  final AdvancedDrawerController? advancedDrawerController;

  const AppDrawerWidget({Key? key, this.advancedDrawerController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTabletUI = (size.width > 600 && size.height > 500);
    if (isTabletUI) return _tabletUI(context);
    return _phoneUI(context);
  }

  Widget _tabletUI(BuildContext context) {
    final MainProvider provider = context.watch<MainProvider>();
    return Container(
      color: context.isDarkMode() ? kDarkBackDrop : kBackDrop,
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(20.0),
                    width: double.infinity,
                    child: Text(
                      context.l10n.catholic_prayers,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: kText,
                        fontSize: (provider.currentLocale.languageCode == 'en')
                            ? 40
                            : 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _drawerItem(
                    title: context.l10n.home,
                    iconData: Icons.home,
                    active: provider.index == 0,
                    onPressed: () => provider.index = 0,
                    context: context,
                  ),
                  _drawerItem(
                    title: context.l10n.favourites,
                    iconData: Icons.favorite,
                    active: provider.index == 1,
                    onPressed: () => provider.index = 1,
                    context: context,
                  ),
                  _drawerItem(
                    title: context.l10n.settings,
                    iconData: Icons.settings,
                    active: provider.index == 2,
                    onPressed: () => provider.index = 2,
                    context: context,
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      AppLib.getInstance().launchInBrowser(
                        context: context,
                        url: "https://altotunchitoo.me/privacy",
                        fallback: "https://altotunchitoo.me/privacy",
                      );
                    },
                    child: Text(
                      context.l10n.privacy_policy,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: kText,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneUI(BuildContext context) {
    final MainProvider provider = context.watch<MainProvider>();
    return Container(
      color: context.isDarkMode() ? kDarkBackDrop : kBackDrop,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                child: Text(
                  context.l10n.catholic_prayers,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.notoSansMyanmar().copyWith(
                    color: const Color(0xfffafafa),
                    fontSize:
                        provider.currentLocale.languageCode == "en" ? 35 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _drawerItem(
                title: context.l10n.home,
                iconData: Icons.home,
                active: provider.index == 0,
                onPressed: () => provider.index = 0,
                context: context,
              ),
              _drawerItem(
                title: context.l10n.favourites,
                iconData: Icons.favorite,
                active: provider.index == 1,
                onPressed: () => provider.index = 1,
                context: context,
              ),
              _drawerItem(
                title: context.l10n.settings,
                iconData: Icons.settings,
                active: provider.index == 2,
                onPressed: () => provider.index = 2,
                context: context,
              ),
              const Spacer(),
              CupertinoButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  AppLib.getInstance().launchInBrowser(
                    context: context,
                    url: "https://altotunchitoo.me/privacy",
                    fallback: "https://altotunchitoo.me/privacy",
                  );
                },
                child: Text(
                  context.l10n.privacy_policy,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: kText,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required String title,
    required IconData iconData,
    bool active = false,
    required Function onPressed,
    required BuildContext context,
  }) {
    final Color color = active
        ? kText.withOpacity(0.8)
        : (context.isDarkMode()
            ? const Color(0xff606177)
            : const Color(0xff6B4F4F));
    return CupertinoButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        advancedDrawerController?.hideDrawer();
        onPressed();
      },
      padding: EdgeInsets.zero,
      pressedOpacity: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22) +
                const EdgeInsets.only(bottom: 3),
            child: Icon(iconData, color: color),
          ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.fade,
              maxLines: 1,
              style: GoogleFonts.notoSansMyanmar().copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
