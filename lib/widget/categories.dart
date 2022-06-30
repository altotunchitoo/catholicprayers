import 'package:catholic_prayers/model/Category.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/page/prayer_category.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/widget/clickable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    final ScrollController scrollController = ScrollController();
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            if (mainProvider.categories.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30),
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Colors.black12,
                  highlightColor: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .color!
                      .withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 8,
                        margin: const EdgeInsets.only(top: 24),
                        decoration: BoxDecoration(
                          color: kLogoTextTheme,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 8,
                        margin: const EdgeInsets.only(top: 15, right: 20),
                        decoration: BoxDecoration(
                          color: kLogoTextTheme,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 8,
                        margin: const EdgeInsets.symmetric(vertical: 10) +
                            const EdgeInsets.only(right: 40),
                        decoration: BoxDecoration(
                          color: kLogoTextTheme,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: kLogoTextTheme,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (mainProvider.categories.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                child: Text(
                  context.l10n.categories,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: theme.textTheme.bodyText1?.color,
                  ),
                ),
              ),
              BuildCategories(
                categories: mainProvider.categories,
                scrollController: scrollController,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BuildCategories extends StatelessWidget {
  final List<CategoryModel> categories;
  final ScrollController scrollController;

  const BuildCategories({
    Key? key,
    required this.categories,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    final Size size = MediaQuery.of(context).size;
    final bool tabletUI = (size.width >= 600);
    final double itemWidth = tabletUI ? (size.width / 4) : (size.width / 2);
    double itemHeight = itemWidth - (itemWidth / 2.5);
    if (itemHeight < 100) itemHeight = 100;
    if (tabletUI && itemHeight < 130) itemHeight = 140;

    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tabletUI ? 3 : 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: itemWidth / itemHeight,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        CategoryModel category = categories[i];
        return ClickableWidget(
          child: PhysicalModel(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.black,
            elevation: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 17.0, vertical: 18.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14.0),
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse(category.theme)),
                    Color(int.parse(category.theme)).withOpacity(0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.square_stack_3d_up,
                    color:
                        (Color(int.parse(category.theme)).computeLuminance() <
                                0.5)
                            ? Colors.white
                            : Colors.black,
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        mainProvider.getCategoryTitle(category),
                        style: mainProvider.getCategoryTextStyle().copyWith(
                              color: (Color(int.parse(category.theme))
                                          .computeLuminance() <
                                      0.5)
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.fade,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            AppLib.getInstance()
                .pushRoute(context, PrayerCategory(category: category));
          },
        );
      },
    );
  }
}
