import 'dart:io';

import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportDevWidget extends StatelessWidget {
  const SupportDevWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              "Support",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 27,
                color: Theme.of(context).textTheme.bodyText1!.color!,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          kSpacer,
          SizedBox(
            width: double.infinity,
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyText2!.color!,
                ),
                children: [
                  const TextSpan(
                    text:
                        "Hello, I'm Alto Tun Chit Oo and the developer of Catholic Prayers app. "
                        "Although there are server and publishing costs for this app, "
                        "you can use it at no costs.\n\nFor more apps, please visit to my ",
                  ),
                  TextSpan(
                    text: "website",
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: CupertinoColors.systemBlue,
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
                  const TextSpan(
                    text: ". You can also get in touch from my facebook page ",
                  ),
                  TextSpan(
                    text: "@fb/altocs",
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: CupertinoColors.systemBlue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        HapticFeedback.mediumImpact();
                        String id = "108697621546747";
                        String fbProtocolUrl;
                        if (Platform.isIOS) {
                          fbProtocolUrl = 'fb://profile/$id';
                        } else if (Platform.isAndroid) {
                          fbProtocolUrl = 'fb://page/$id';
                        } else {
                          fbProtocolUrl = "https://www.facebook.com/altocs";
                        }
                        AppLib.getInstance().launchInBrowser(
                          context: context,
                          url: fbProtocolUrl,
                          fallback: "https://www.facebook.com/altocs",
                          safariV: false,
                        );
                      },
                  ),
                  const TextSpan(
                    text: ". If you want to support me, "
                        "you can buy me a cup of coffee!\n",
                  ),
                ],
              ),
            ),
          ),
          kSpacer,
          Align(
            alignment: Alignment.center,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.mediumImpact();
                AppLib.getInstance().launchInBrowser(
                  context: context,
                  url: "https://www.buymeacoffee.com/alto",
                  fallback: "https://altotunchitoo.me",
                );
              },
              child: Image.asset(
                "assets/images/buy_me_a_coffee.png",
                width: 200,
              ),
            ),
          ),
          kSpacerSm,
        ],
      ),
    );
  }
}
