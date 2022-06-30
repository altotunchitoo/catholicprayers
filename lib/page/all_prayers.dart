import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/widget/prayers_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllPrayers extends StatelessWidget {
  const AllPrayers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = context.watch<MainProvider>();
    ScrollController scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mainProvider.getPrayerText(),
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
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: PrayersListWidget(
            prayers: mainProvider.prayers,
            isCategory: false,
            scrollController: scrollController,
            isFav: false,
          ),
        ),
      ),
    );
  }
}
