import 'dart:io';

import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    final Color? color = Theme.of(context).textTheme.bodyText2?.color;
    final String? latest = mainProvider.getValue("latest_build") as String?;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.app_info,
          style: mainProvider.getTitleTextStyle(),
        ),
        leading: IconButton(
          splashRadius: 22.0,
          icon: const Icon(CupertinoIcons.arrow_left),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: "Back",
        ),
        centerTitle: true,
        actions: [
          if (int.parse(latest ?? "0") > int.parse(mainProvider.buildNumber))
            IconButton(
              onPressed: () {
                String link = "https://altotunchitoo.me/catholic-prayers";
                if (Platform.isAndroid) {
                  link += "?d=android";
                } else if (Platform.isIOS) {
                  link += "?d=ios";
                } else if (Platform.isMacOS) {
                  link += "?d=macos";
                }

                String appUrl = "market://details?id=me.altotunchitoo.prayers";
                AppLib.getInstance().launchInBrowser(
                  context: context,
                  url: Platform.isAndroid ? appUrl : link,
                  fallback: link,
                );
              },
              splashRadius: 22.0,
              iconSize: 26,
              icon: const Icon(Icons.arrow_circle_up),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
                child: Column(
                  children: [
                    ...[
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/images/app_logo_resized.png",
                            width: 170,
                          ),
                        ),
                      ),
                      Text(
                        "Catholic Prayers",
                        style: GoogleFonts.montserrat().copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${context.l10n.version}  ${mainProvider.version}",
                        style: kTextStyle,
                      ),
                    ],
                    kSpacerSm,
                    kSpacer,
                    ...[
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          context.l10n.reference,
                          style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          context.l10n.reference_content,
                          style: kTextStyle,
                        ),
                      ),
                    ],
                    kSpacerSm,
                    kSpacer,
                    ...[
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          context.l10n.developer,
                          style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RichText(
                          text: TextSpan(
                            style: kTextStyle.copyWith(color: color),
                            children: [
                              TextSpan(text: context.l10n.alto),
                              TextSpan(
                                text: "  (https://altotunchitoo.me)",
                                style: kTextStyle.copyWith(
                                  color: kAssetColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    HapticFeedback.mediumImpact();
                                    AppLib.getInstance().launchInBrowser(
                                      context: context,
                                      url: "https://altotunchitoo.me",
                                      fallback: "https://altotunchitoo.me",
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    kSpacerSm,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
