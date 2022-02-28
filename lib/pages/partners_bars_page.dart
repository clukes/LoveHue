import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/widgets/app_bars.dart';
import 'package:relationship_bars/widgets/bar_builders.dart';
import 'package:relationship_bars/widgets/link_partner_screen.dart';

class PartnersBars extends StatefulWidget {
  const PartnersBars({Key? key}) : super(key: key);

  @override
  _PartnersBarsState createState() => _PartnersBarsState();
}

class _PartnersBarsState extends State<PartnersBars> with AutomaticKeepAliveClientMixin<PartnersBars> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    ValueListenableBuilder<String> listenableTitle = ValueListenableBuilder<String>(
        valueListenable: PartnersInfoState.instance.partnersName,
        builder: (BuildContext context, value, Widget? child) => FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("$value's Bars")));
    super.build(context);
    return Scaffold(
      primary: false,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            BarsPageAppBar(barTitleWidget: listenableTitle),
          ];
        },
        body: Consumer<PartnersInfoState>(builder: (BuildContext context, PartnersInfoState partnersInfoState, _) {
          if (partnersInfoState.partnerLinked) {
            print("Partner: " + (partnersInfoState.partnersInfo?.partnerID ?? ''));
            return barStreamBuilder(partnersInfoState.partnersID!, nonInteractableBarBuilder);
          }
          print("NOT LINKED");
          return LinkPartnerScreen(partnersInfoState: partnersInfoState);
        }),
      ),
    );
  }
}
