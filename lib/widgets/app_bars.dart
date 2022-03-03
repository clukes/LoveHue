import 'package:flutter/material.dart';

const double barsPageAppBarHeight = 70;

/// [SliverAppBar] for YourBars and PartnersBars pages.
class BarsPageAppBar extends StatefulWidget {
  const BarsPageAppBar({Key? key, required this.barTitleWidget}) : super(key: key);

  final Widget barTitleWidget;

  @override
  _BarsPageAppBarState createState() => _BarsPageAppBarState();
}

class _BarsPageAppBarState extends State<BarsPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: widget.barTitleWidget,
      centerTitle: false,
      floating: false,
      pinned: false,
      toolbarHeight: barsPageAppBarHeight,
      primary: true,
    );
  }
}
