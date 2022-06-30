import 'package:catholic_prayers/util/constant.dart';
import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Image.asset(
            Theme.of(context).scaffoldBackgroundColor == kBgColor
                ? "assets/images/prayers_black.png"
                : "assets/images/prayers.png",
            width: 200.0,
          ),
        ),
        Container(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
          width: double.infinity,
          height: double.infinity,
        ),
      ],
    );
  }
}
