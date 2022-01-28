import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/widgets/bar_builders.dart';
import 'package:relationship_bars/widgets/link_partner_screen.dart';

class PartnersBars extends StatefulWidget {
  const PartnersBars({Key? key}) : super(key: key);

  @override
  _PartnersBarsState createState() => _PartnersBarsState();
}

class _PartnersBarsState extends State<PartnersBars> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<PartnersInfoState>(builder: (context, partnersInfoState, _) {
          String title = "Partner Link";
          if (partnersInfoState.partnerLinked) {
            String name = partnersInfoState.partnersInfo?.displayName ?? "Partner";
            title = "$name's Bars";
          }
          return Text(title);
        }),
      ),
      body: Consumer<PartnersInfoState>(builder: (context, partnersInfoState, _) {
        if (partnersInfoState.partnerLinked) {
          print("Partner: " + (partnersInfoState.partnersInfo?.partnerID ?? ''));
          return barStreamBuilder(partnersInfoState.partnersID!, nonInteractableBarBuilder);
        }
        return LinkPartnerScreen(partnersInfoState: partnersInfoState);
      }),
    );
  }
}
