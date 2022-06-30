import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/widget/clickable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd() {
    context.read<MainProvider>().introDone();
  }

  @override
  Widget build(BuildContext context) {
    final MainProvider provider = context.watch<MainProvider>();

    if (provider.showedIntro) return const SizedBox();

    final bodyStyle = GoogleFonts.notoSansMyanmar()
        .copyWith(fontSize: 19.0, color: Colors.black87);

    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.notoSansMyanmar().copyWith(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.transparent,
      imagePadding: EdgeInsets.zero,
      bodyAlignment: Alignment.center,
    );

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: IntroductionScreen(
            key: introKey,
            globalBackgroundColor: Colors.transparent,
            pages: [
              PageViewModel(
                titleWidget: Text(context.l10n.language,
                    style: GoogleFonts.notoSansMyanmar().copyWith(
                      color: Colors.black,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    )),
                bodyWidget: Text(
                  context.l10n.app_language_note,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.notoSansMyanmar().copyWith(
                    color: Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                footer: ClickableWidget(
                  onPressed: () {
                    AppLib.getInstance().showLanguages(context: context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.language, color: Colors.white),
                        kSpacerH,
                        Text(
                          context.l10n.change_language,
                          style: GoogleFonts.notoSansMyanmar().copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        kSpacerH,
                      ],
                    ),
                  ),
                ),
                decoration: pageDecoration.copyWith(
                  bodyFlex: 3,
                  imageFlex: 2,
                ),
              ),
              PageViewModel(
                titleWidget: Text(
                  context.l10n.lang_for_prayers,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.notoSansMyanmar().copyWith(
                    color: Colors.black,
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                body: provider.getPrayerLangNote(),
                footer: ClickableWidget(
                  onPressed: () {
                    AppLib.getInstance()
                        .showLanguagesForPrayer(context: context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.language, color: Colors.white),
                        kSpacerH,
                        Text(
                          context.l10n.choose_language,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        kSpacerH,
                      ],
                    ),
                  ),
                ),
                decoration: pageDecoration.copyWith(
                  bodyAlignment: Alignment.center,
                ),
              ),
            ],
            onDone: () => _onIntroEnd(),
            onSkip: () => _onIntroEnd(),
            showSkipButton: true,
            skipOrBackFlex: 1,
            nextFlex: 1,
            dotsFlex: 1,
            showBackButton: false,
            back: const Icon(Icons.arrow_back, color: Colors.black),
            skip: Text(
              context.l10n.skip,
              style: GoogleFonts.notoSansMyanmar().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            next: const Icon(Icons.arrow_forward, color: Colors.black),
            done: Text(
              context.l10n.done,
              style: GoogleFonts.notoSansMyanmar().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            curve: Curves.fastLinearToSlowEaseIn,
            controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            dotsDecorator: const DotsDecorator(
              size: Size(10.0, 10.0),
              color: Colors.black54,
              activeSize: Size(20.0, 10.0),
              activeColor: Colors.black87,
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
