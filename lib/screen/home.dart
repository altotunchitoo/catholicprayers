import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/page/all_prayers.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/widget/categories.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/widget/clickable.dart';
import 'package:catholic_prayers/widget/daily_reading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final Function onRefresh;

  const Home({Key? key, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: RefreshIndicator(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        color: kText,
        onRefresh: () async {
          await onRefresh();
        },
        child: SingleChildScrollView(
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (mainProvider.firstTimeAndError) ...[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          kSpacer,
                          Center(
                            child: LottieBuilder.asset(
                              "assets/lotties/disconnect.json",
                              width: 240,
                            ),
                          ),
                          kSpacer,
                          Text(
                            context.l10n.something_wrong,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          kSpacerSm,
                          Text(
                            context.l10n.lost_connection,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          kSpacer,
                          kSpacer,
                          Align(
                            alignment: Alignment.center,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).textTheme.button!.color,
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: kBoxShadow,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      context.l10n.try_again,
                                      style: GoogleFonts.lato(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .color,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                  ],
                                ),
                              ),
                              onPressed: () => onRefresh(),
                            ),
                          ),
                          kSpacer,
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const DailyReadingWidget(),
                if (mainProvider.prayers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: ClickableWidget(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 17.0, vertical: 17.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14.0),
                            gradient: context.isDarkMode()
                                ? kDarkHeroGradient
                                : kHeroGradient,
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 80,
                                child: Image.asset(
                                  "assets/images/prayers.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      mainProvider.getPrayerText(),
                                      style: mainProvider
                                          .getCategoryTextStyle()
                                          .copyWith(
                                            color: kText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "${mainProvider.prayers.length} +",
                                    style: mainProvider
                                        .getCategoryTextStyle()
                                        .copyWith(
                                          color: kText.withOpacity(0.5),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          AppLib.getInstance()
                              .pushRoute(context, const AllPrayers());
                        },
                      ),
                    ),
                  ),
                const Categories(),
                kSpacer,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
