import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relationship_bar_document.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../widgets/app_bars.dart';
import '../widgets/bar_builders.dart';
import 'link_partner_screen.dart';

/// Partners Bars page builder.
///
/// Uses [AutomaticKeepAliveClientMixin] for persistent scroll state.
class PartnersBars extends StatefulWidget {
  const PartnersBars({Key? key, this.firestore}) : super(key: key);

  final FirebaseFirestore? firestore;

  @override
  _PartnersBarsState createState() => _PartnersBarsState();
}

class _PartnersBarsState extends State<PartnersBars> with AutomaticKeepAliveClientMixin<PartnersBars> {
  // Keeps page alive in background to save the scroll position.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Listener to update page title in app bar when partner's name changes.
    final ValueListenableBuilder<String> listenableTitle = ValueListenableBuilder<String>(
      valueListenable: Provider.of<PartnersInfoState>(context, listen: false).partnersName,
      builder: (BuildContext context, String partnersName, Widget? child) => FittedBox(
        // Scale text down if it becomes too big for app bar.
        fit: BoxFit.scaleDown,
        child: Text("$partnersName's Bars"),
      ),
    );

    super.build(context);

    return Scaffold(
      primary: false,
      body: NestedScrollView(
        // App bar title that hides when scrolling.
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            BarsPageAppBar(barTitleWidget: listenableTitle),
          ];
        },
        body: Consumer<PartnersInfoState>(builder: (BuildContext context, PartnersInfoState partnersInfoState, _) {
          if (Provider.of<UserInfoState>(context).partnerLinked) {
            debugPrint("_PartnersBarsState: Linked partner id: ${partnersInfoState.partnersInfo?.partnerID}");
            Query<RelationshipBarDocument> userBarsQuery = RelationshipBarDocument.getOrderedUserBarsFromID(partnersInfoState.partnersID!, widget.firestore);

            return StreamBuilder<QuerySnapshot<RelationshipBarDocument>>(
                stream: userBarsQuery.snapshots(),
                builder: (context, snapshot) => buildBars(context, snapshot, nonInteractableBarBuilder));
          }
          debugPrint("_PartnersBarsState: Not linked to a partner.");
          return const LinkPartnerScreen();
        }),
      ),
    );
  }
}
