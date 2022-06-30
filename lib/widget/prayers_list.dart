import 'dart:io';

import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/page/prayer_detail.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/log.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PrayersListWidget extends StatefulWidget {
  final bool isFav, isCategory;
  final List<PrayerModel> prayers;
  final ScrollController scrollController;

  const PrayersListWidget({
    Key? key,
    required this.prayers,
    required this.isCategory,
    required this.isFav,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<PrayersListWidget> createState() => _PrayersListWidgetState();
}

class _PrayersListWidgetState extends State<PrayersListWidget> {
  @override
  Widget build(BuildContext context) {
    return _phoneUI(context);
  }

  Widget _phoneUI(BuildContext context) {
    final MainProvider mainProvider = context.watch<MainProvider>();
    return Scrollbar(
      controller: widget.scrollController,
      child: ListView.separated(
        separatorBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Divider(
            height: 1.0,
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 7),
        shrinkWrap: false,
        primary: false,
        itemCount: widget.prayers.length,
        controller: widget.scrollController,
        itemBuilder: (context, index) {
          PrayerModel prayer = widget.prayers[index];
          return CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 15),
            alignment: AlignmentDirectional.centerStart,
            pressedOpacity: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mainProvider.getPrayerTitle(prayer),
                    style: mainProvider.getListTextStyle(
                      context,
                      prayer.id,
                      widget.isFav,
                      widget.isCategory,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5.0),
                mainProvider.getListTile(
                  context,
                  prayer.id,
                  widget.isFav,
                  widget.isCategory,
                ),
              ],
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              try {
                if (!widget.isCategory) {
                  context
                      .read<MainProvider>()
                      .setSelectedIndex(index, prayer.id, widget.isFav);
                }
                if (widget.isFav) {
                  Map<String, dynamic>? result =
                      await AppLib.getInstance().pushRoute(
                    context,
                    PrayerDetail(
                      current: index,
                      prayers: widget.prayers,
                      isFav: widget.isFav,
                      isCategory: widget.isCategory,
                    ),
                  );
                  if (result != null && result["status"] == "error") {
                    Log.e(result);
                  }
                } else {
                  AppLib.getInstance().pushRoute(
                    context,
                    PrayerDetail(
                      current: index,
                      prayers: widget.prayers,
                      isFav: widget.isFav,
                      isCategory: widget.isCategory,
                    ),
                  );
                }
              } on Error catch (e) {
                Log.e(e);
                if (Platform.isAndroid || Platform.isIOS) {
                  FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
                }
              }
            },
          );
        },
      ),
    );
  }
}
