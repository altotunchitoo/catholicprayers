import 'dart:async';
import 'dart:ui';
import 'package:catholic_prayers/model/prayer.dart';
import 'package:catholic_prayers/provider/main_provider.dart';
import 'package:catholic_prayers/provider/prayer_screen_provider.dart';
import 'package:catholic_prayers/util/app_lib.dart';
import 'package:catholic_prayers/util/constant.dart';
import 'package:catholic_prayers/util/log.dart';
import 'package:catholic_prayers/widget/fav.dart';
import 'package:catholic_prayers/widget/prayer_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class PrayerDetail extends StatefulWidget {
  final List<PrayerModel> prayers;
  final int current;
  final bool isFav;
  final bool isCategory;

  const PrayerDetail({
    Key? key,
    required this.prayers,
    required this.current,
    required this.isFav,
    required this.isCategory,
  }) : super(key: key);

  @override
  State<PrayerDetail> createState() => _PrayerDetailState();
}

class _PrayerDetailState extends State<PrayerDetail>
    with SingleTickerProviderStateMixin {
  late PrayerScreenProvider _prayerScreenProvider;
  int _prayerIndex = -1;
  int _textSize = 19;
  late PageController _pageController;
  late AnimationController _toolbarAnimationController;
  late Animation<Offset> _toolbarAnimationOffset;
  bool _showToolbar = false;
  bool _checkingFavError = false;
  Timer? _timer;

  late MainProvider _mainReader;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void _init() {
    _mainReader = context.read<MainProvider>();
    _prayerScreenProvider = context.read<PrayerScreenProvider>();
    if (widget.current >= 0 && widget.current < widget.prayers.length) {
      _prayerScreenProvider.currentPrayerMute = widget.prayers[widget.current];
      setState(() {
        _prayerIndex = widget.current;
        _pageController = PageController(initialPage: widget.current);
        _textSize = _mainReader.textSize;
      });
    }

    _toolbarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _toolbarAnimationOffset = Tween<Offset>(
      end: Offset.zero,
      begin: const Offset(0.0, 2),
    ).animate(_toolbarAnimationController);
  }

  @override
  Widget build(BuildContext context) {
    final MainProvider mainWatcher = context.watch<MainProvider>();
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _prayerScreenProvider.getCurrentPrayerTitle(
            language: _mainReader.getLang(code: true),
          ),
          overflow: TextOverflow.ellipsis,
          style: mainWatcher.getTitleTextStyle(),
        ),
        leading: IconButton(
          splashRadius: 22.0,
          icon: const Icon(CupertinoIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: "Back",
        ),
        centerTitle: false,
        actions: [
          if (size.width > kMinSplitView)
            IconButton(
              tooltip: "Split View",
              iconSize: 25.0,
              splashRadius: 22.0,
              onPressed: () async {
                var result = await AppLib.getInstance()
                    .showSplitLanguage(context: context);
                if (result != null) {
                  _mainReader.splitLang = (result == "cancel" ? null : result);
                }
              },
              icon: const Icon(CupertinoIcons.book),
            ),
          IconButton(
            tooltip: "Tool bar",
            iconSize: 24.0,
            splashRadius: 22.0,
            onPressed: _toggleToolbar,
            icon: Icon(
              _showToolbar
                  ? CupertinoIcons.slider_horizontal_below_rectangle
                  : CupertinoIcons.rectangle_dock,
            ),
          ),
          FavWidget(isFav: widget.isFav),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              scrollDirection: Axis.horizontal,
              itemCount: widget.prayers.length,
              itemBuilder: (context, index) {
                return PrayerPageViewItemWidget(
                  prayer: widget.prayers[index],
                  isFav: widget.isFav,
                  checkFavError: _checkFavError,
                );
              },
            ),
            SlideTransition(
              position: _toolbarAnimationOffset,
              child: SizedBox(
                height: 74,
                width: 330,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 15),
                        color:
                            context.isDarkMode() ? kBgDarkSecColor : kLogoTheme,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                _adjustTextSize(_textSize - 1);
                              },
                              padding: EdgeInsets.zero,
                              color: (_textSize == kMinPrayerTextSize)
                                  ? kDisabled
                                  : kText,
                              iconSize: 22.0,
                              splashRadius: 22.0,
                              tooltip: "Smaller Text",
                              icon: const Icon(CupertinoIcons.minus_circled),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_prayerIndex != 0) {
                                  _switchPage(_prayerIndex - 1);
                                }
                              },
                              padding: EdgeInsets.zero,
                              color: (_prayerIndex != 0) ? kText : kDisabled,
                              iconSize: 20.0,
                              splashRadius: 22.0,
                              tooltip: "Previous",
                              icon: const Icon(CupertinoIcons.arrow_left),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text(
                                  AppLib.getInstance().localizeNumber(
                                    num: (_prayerIndex + 1),
                                    locale:
                                        mainWatcher.currentLocale.languageCode,
                                  ),
                                  style: GoogleFonts.lato(
                                    color: kText,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if ((_prayerIndex + 1) !=
                                    widget.prayers.length) {
                                  _switchPage(_prayerIndex + 1);
                                }
                              },
                              padding: EdgeInsets.zero,
                              color:
                                  ((_prayerIndex + 1) != widget.prayers.length)
                                      ? kText
                                      : kDisabled,
                              tooltip: "Next",
                              iconSize: 20.0,
                              splashRadius: 22.0,
                              icon: const Icon(CupertinoIcons.arrow_right),
                            ),
                            IconButton(
                              onPressed: () {
                                _adjustTextSize(_textSize + 1);
                              },
                              padding: EdgeInsets.zero,
                              color: (_textSize == kMaxPrayerTextSize)
                                  ? kDisabled
                                  : kText,
                              tooltip: "Larger Text",
                              iconSize: 22.0,
                              splashRadius: 22.0,
                              icon: const Icon(CupertinoIcons.plus_circled),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleToolbar() {
    HapticFeedback.mediumImpact();
    if (_showToolbar) {
      _toolbarAnimationController.reverse();
      if (_timer != null) _timer?.cancel();
    } else {
      _toolbarAnimationController.forward();
      if (_timer != null) _timer?.cancel();
      _timer = Timer(
        const Duration(milliseconds: 10000),
        () {
          if (mounted) {
            _toolbarAnimationController.reverse();
            setState(() => _showToolbar = false);
            _timer = null;
          }
        },
      );
    }
    setState(() => _showToolbar = !_showToolbar);
  }

  Future<void> _checkFavError() async {
    if (widget.isFav && !_checkingFavError) {
      _checkingFavError = true;
      Log.d("Checking Fav Error");
      if (!const DeepCollectionEquality()
          .equals(widget.prayers, _mainReader.favoritePrayers)) {
        Navigator.of(context).pop({
          "status": "error",
        });
      }
      _checkingFavError = false;
    }
  }

  void _onPageChanged(int index) async {
    if (index >= 0 && index < widget.prayers.length) {
      if (widget.isFav && !(index < _mainReader.favoritePrayers.length)) {
        await _checkFavError();
      }
      if (mounted) {
        PrayerModel temp = widget.prayers[index];
        if (!widget.isCategory) {
          _mainReader.setSelectedIndex(index, temp.id, widget.isFav);
        }
        _prayerScreenProvider.currentPrayer = temp;
        setState(() {
          _prayerIndex = index;
        });
      }
    }
  }

  void _switchPage(int index) {
    HapticFeedback.mediumImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _adjustTextSize(int index) async {
    if (index <= kMaxPrayerTextSize && index >= kMinPrayerTextSize) {
      HapticFeedback.mediumImpact();
      await _mainReader.setValue("text_size", index.toString());
      setState(() => _textSize = index);
    }
  }
}
