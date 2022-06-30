import 'dart:io';
import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/extension.dart';
import 'package:catholic_prayers/util/log.dart';
import 'package:catholic_prayers/widget/clickable.dart';
import 'package:catholic_prayers/widget/prayer_detail.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class PrayerPageViewItemWidget extends StatefulWidget {
  final PrayerModel prayer;
  final bool isFav;
  final Function checkFavError;

  const PrayerPageViewItemWidget(
      {Key? key,
      required this.prayer,
      required this.isFav,
      required this.checkFavError})
      : super(key: key);

  @override
  State<PrayerPageViewItemWidget> createState() =>
      _PrayerPageViewItemWidgetState();
}

class _PrayerPageViewItemWidgetState extends State<PrayerPageViewItemWidget> {
  late MainProvider _mainReader;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainReader = context.read<MainProvider>();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainProvider watcher = context.watch<MainProvider>();
    try {
      if (watcher.splitLang == null) {
        return Scrollbar(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            children: [
              if (widget.isFav)
                GestureDetector(
                  onTapDown: (_) => widget.checkFavError(),
                  child: PrayerDetailWidget(
                    prayer: widget.prayer,
                    lang: _mainReader.getLang(code: true),
                  ),
                )
              else
                PrayerDetailWidget(
                  prayer: widget.prayer,
                  lang: _mainReader.getLang(code: true),
                ),
            ],
          ),
        );
      }
      return NotificationListener(
        onNotification: _onNotification,
        child: widget.isFav
            ? GestureDetector(
                onTapDown: (_) => widget.checkFavError(),
                child: _buildSplitView(),
              )
            : _buildSplitView(),
      );
    } on Error catch (e) {
      if (Platform.isAndroid || Platform.isIOS) {
        FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
      }
      return const SizedBox.shrink();
    }
  }

  bool _onNotification(ScrollNotification sn) {
    if (sn is UserScrollNotification) {
      try {
        final bool isScroller1 = (_scrollController1.position.maxScrollExtent ==
            sn.metrics.maxScrollExtent);
        final bool isScroller2 = (_scrollController2.position.maxScrollExtent ==
            sn.metrics.maxScrollExtent);
        if (isScroller1) {
          // Scrolling controller 1
          final double percent = (_scrollController1.offset /
                  _scrollController1.position.maxScrollExtent) *
              100;
          final double scrollTo =
              (percent * _scrollController2.position.maxScrollExtent) / 100;
          if (_scrollController2.hasClients) {
            _scrollController2.animateTo(
              scrollTo,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          }
        } else if (isScroller2) {
          // Scrolling controller 2
          final double percent = (_scrollController2.offset /
                  _scrollController2.position.maxScrollExtent) *
              100;
          final double scrollTo =
              (percent * _scrollController1.position.maxScrollExtent) / 100;
          if (_scrollController1.hasClients) {
            _scrollController1.animateTo(
              scrollTo,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          }
        }
      } on Error catch (e) {
        if (Platform.isAndroid || Platform.isIOS) {
          FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
        }
        Log.e(e);
      }
    }
    return false;
  }

  Widget _buildSplitView() {
    final MediaQueryData mqData = MediaQuery.of(context);
    if (mqData.size.width < kMinSplitView) {
      return Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset("assets/lotties/rotate.json", width: 200),
            Text(
              context.l10n.rotate_device,
              style: kTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            ClickableWidget(
              child: SizedBox(
                width: 200,
                child: Text(
                  context.l10n.turn_split_view_off,
                  style: GoogleFonts.notoSansMyanmar()
                      .copyWith(color: kAssetColor),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                _mainReader.splitLang = null;
              },
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ListView(
            controller: _scrollController1,
            children: [
              PrayerDetailWidget(
                prayer: widget.prayer,
                lang: _mainReader.getLang(code: true),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView(
            controller: _scrollController2,
            children: [
              PrayerDetailWidget(
                prayer: widget.prayer,
                lang: _mainReader.splitLang ?? "",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
