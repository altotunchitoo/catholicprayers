import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/provider/prayer_screen_provider.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FavWidget extends StatelessWidget {
  final bool isFav;

  const FavWidget({Key? key, required this.isFav}) : super(key: key);

  void _onFavClick({
    required BuildContext context,
    required PrayerModel prayer,
  }) async {
    HapticFeedback.lightImpact();
    final MainProvider mainReader = context.read<MainProvider>();
    final PrayerScreenProvider prayerScreenProvider =
        context.read<PrayerScreenProvider>();
    prayer.favorite = prayer.getFavorite() ? 0 : 1;
    await mainReader.toggleFavorite(prayerItem: prayer, isFav: isFav);
    final String title = prayerScreenProvider.getCurrentPrayerTitle(
        language: mainReader.currentLocale.languageCode);
    if (isFav && !prayer.getFavorite()) {
      Navigator.pop(context);
      AppLib.getInstance().showKToast(
        context: context,
        message: "[ $title ]  ${context.l10n.removed_from_fav}",
      );
    } else {
      AppLib.getInstance().showKToast(
        context: context,
        message: prayer.getFavorite()
            ? "[ $title ]  ${context.l10n.added_to_fav}"
            : "[ $title ]  ${context.l10n.removed_from_fav}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final PrayerScreenProvider provider = context.watch<PrayerScreenProvider>();
    final MainProvider mainProvider = context.read<MainProvider>();
    PrayerModel currentPrayer = provider.currentPrayer!;
    if (provider.currentPrayer == null) return const SizedBox();
    final bool isFav = mainProvider.isFav(id: currentPrayer.id);
    currentPrayer.favorite = isFav ? 1 : 0;
    final Color iconNormalColor =
        (Theme.of(context).appBarTheme.iconTheme?.color ?? kThemeColor);
    final Color iconColor =
        context.isDarkMode() ? kAssetColor : iconNormalColor;
    return IconButton(
      tooltip: "Favorite",
      iconSize: 24.0,
      splashRadius: 22.0,
      onPressed: () => _onFavClick(context: context, prayer: currentPrayer),
      icon: Icon(
        isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        color: isFav ? iconColor : iconNormalColor,
      ),
    );
  }
}
