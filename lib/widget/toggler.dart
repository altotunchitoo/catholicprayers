import 'package:flutter/cupertino.dart';

class TogglerWidget extends StatelessWidget {
  final Function onChanged;
  final bool active;

  const TogglerWidget({
    Key? key,
    required this.onChanged,
    required this.active,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: active,
      onChanged: (_) => onChanged(_),
    );
  }
}
