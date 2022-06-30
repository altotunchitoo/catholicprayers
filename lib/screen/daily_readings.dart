import 'package:catholic_prayers/model/days.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DailyReadingsScreen extends StatelessWidget {
  const DailyReadingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    final Days? days = mainProvider.days;
    final Color? color1 = Theme.of(context).textTheme.bodyText1?.color;
    final Color? color2 = Theme.of(context).textTheme.bodyText2?.color;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          days?.data.liturgicTitle ??
              days?.data.dateDisplayed ??
              days?.data.date ??
              "",
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
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: days?.data.readings?.length ?? 0,
          separatorBuilder: (_, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Divider(
              height: 1.0,
              color: Theme.of(context).dividerColor.withOpacity(0.9),
            ),
          ),
          itemBuilder: (context, index) {
            final Readings readings = days!.data.readings![index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kSpacerSm,
                  Text(
                    "${readings.bookType?.toUpperCase() ?? "-"} (${readings.readingCode ?? "-"})",
                    style: GoogleFonts.montserrat().copyWith(
                      fontSize: 14,
                      color: color2 ?? kText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 10),
                    child: Text(
                      readings.title ?? "-",
                      style: GoogleFonts.lato().copyWith(
                        fontSize: 27,
                        color: color1?.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    AppLib.getInstance().removeMarkDown(readings.text),
                    style: GoogleFonts.lato().copyWith(
                      color: color1?.withOpacity(0.8) ?? kText,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  kSpacerSm,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
