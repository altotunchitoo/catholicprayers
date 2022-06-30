import 'package:catholic_prayers/model/days.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/screen/daily_readings.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/widget/clickable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DailyReadingWidget extends StatelessWidget {
  const DailyReadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    final ThemeData theme = Theme.of(context);
    final Days? days = mainProvider.days;
    final DateTime dateTime = DateTime.now();
    final currentDate = DateFormat('yyyy-MM-dd').format(dateTime);

    if (days != null && currentDate == days.data.date) {
      return ClickableWidget(
        onPressed: () {
          HapticFeedback.lightImpact();
          AppLib.getInstance().pushRoute(context, const DailyReadingsScreen());
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20),
                      child: Text(
                        context.l10n.daily_readings,
                        overflow: TextOverflow.fade,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyText1?.color,
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 3),
                      child: Text(
                        days.data.liturgicTitle ??
                            days.data.dateDisplayed ??
                            days.data.date,
                        style: GoogleFonts.montserrat().copyWith(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyText1?.color,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    if (days.data.commentary != null) ...[
                      Text(
                        days.data.commentary?.title ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.montserrat().copyWith(
                          fontSize: 14.0,
                          color: theme.textTheme.bodyText2?.color,
                        ),
                      ),
                    ],
                    kSpacerSm,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        CupertinoIcons.arrow_right_circle,
                        size: 33,
                        color: theme.textTheme.bodyText1?.color,
                      ),
                    ),
                  ],
                ),
              ),
              kSpacerSm,
              kSpacerSm,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const Divider(),
              ),
              kSpacer,
              kSpacerSm,
            ],
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20) +
            const EdgeInsets.only(top: 30, bottom: 30),
        width: double.infinity,
        child: Shimmer.fromColors(
          baseColor: Colors.black12,
          highlightColor: theme.textTheme.bodyText2!.color!.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 8,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                decoration: BoxDecoration(
                  color: kLogoTextTheme,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: double.infinity,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: kLogoTextTheme,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: double.infinity,
                height: 8,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                decoration: BoxDecoration(
                  color: kLogoTextTheme,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 200,
                height: 8,
                decoration: BoxDecoration(
                  color: kLogoTextTheme,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 70,
                  height: 8,
                  margin: const EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    color: kLogoTextTheme,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
