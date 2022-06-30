import 'package:catholic_prayers/model/Category.dart';
import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/widget/prayers_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class PrayerCategory extends StatelessWidget {
  final CategoryModel category;

  const PrayerCategory({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<PrayerModel> prayers = [];

    Future<void> _getPrayers(BuildContext context) async {
      prayers = await context
          .read<MainProvider>()
          .getCategoryPrayers(category.prayerIds);
    }

    final MainProvider mainProvider = context.watch<MainProvider>();

    final ScrollController scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mainProvider.getCategoryTitle(category),
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
        child: FutureBuilder(
          future: _getPrayers(context),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: (prayers.isEmpty)
                    ? Center(
                        child: Text(
                          "No Categories.",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color),
                        ),
                      )
                    : PrayersListWidget(
                        prayers: prayers,
                        isCategory: true,
                        scrollController: scrollController,
                        isFav: false,
                      ),
              );
            } else {
              return Center(
                child: SpinKitRipple(color: Theme.of(context).primaryColor),
              );
            }
          },
        ),
      ),
    );
  }
}
