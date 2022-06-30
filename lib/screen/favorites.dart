import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/widget/prayers_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class Favorites extends StatelessWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final List<PrayerModel> prayers =
        context.watch<MainProvider>().favoritePrayers;
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: (prayers.isEmpty)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  'assets/lotties/no_result.json',
                  height: (size.height > 450) ? 300 : 150,
                ),
                Text(
                  context.l10n.nothing_here_fav,
                  style: GoogleFonts.lato(
                    color: Theme.of(context).textTheme.bodyText2?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                kSpacer,
                kSpacer,
              ],
            )
          : PrayersListWidget(
              prayers: prayers,
              isFav: true,
              scrollController: scrollController,
              isCategory: false,
            ),
    );
  }
}
