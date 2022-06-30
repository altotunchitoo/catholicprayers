import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerDetailWidget extends StatelessWidget {
  final PrayerModel prayer;
  final String lang;

  const PrayerDetailWidget({Key? key, required this.prayer, required this.lang})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainProvider provider = context.watch<MainProvider>();
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.getPrayerTitle(prayer, lang: lang),
            style:
                Theme.of(context).textTheme.headline1?.copyWith(fontSize: 27.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            provider.getPrayerContent(prayer, lang: lang),
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontSize: provider.textSize.toDouble(),
                  fontWeight: FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
