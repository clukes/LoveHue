import 'package:flutter/material.dart';

import '../utils/colors.dart';

const double appBarHeight = 40;
const appBarColor = blueColor;

class BarsPageAppBar extends StatefulWidget {
  final Widget barTitleWidget;
  const BarsPageAppBar({Key? key, required this.barTitleWidget}) : super(key: key);

  @override
  _BarsPageAppBarState createState() => _BarsPageAppBarState();
}

class _BarsPageAppBarState extends State<BarsPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: widget.barTitleWidget,
      centerTitle: true,
      floating: false,
      pinned: false,
      toolbarHeight: appBarHeight,
      backgroundColor: appBarColor,
    );
  }
}
