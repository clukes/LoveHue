import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lovehue/services/notification_service.dart';
import 'package:lovehue/utils/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../models/relationship_bar_document.dart';
import '../providers/application_state.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../widgets/app_bars.dart';
import '../widgets/bar_builders.dart';
import '../widgets/buttons.dart';
import 'link_partner_screen.dart';

/// Partners Bars page builder.
///
/// Uses [AutomaticKeepAliveClientMixin] for persistent scroll state.
class PartnersBars extends StatefulWidget {
  const PartnersBars({Key? key, this.firestore}) : super(key: key);

  final FirebaseFirestore? firestore;

  @override
  State<PartnersBars> createState() => _PartnersBarsState();
}

class _PartnersBarsState extends State<PartnersBars>
    with AutomaticKeepAliveClientMixin<PartnersBars> {
  // Keeps page alive in background to save the scroll position.
  @override
  bool get wantKeepAlive => true;

  Future<void> clickSendNudge(ApplicationState appState) async {
    NudgeResult result =
        await withLoaderOverlay(() => appState.sendNudgeNotification());
    if (!mounted) return;
    if (result.successful) {
      showSnackbar("Nudge notification sent to partner.");
      return;
    }
    showSnackbar(result.errorMessage ?? "Error sending nudge notification.");
  }

  void showSnackbar(String text, {int seconds = 2}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: seconds),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Listener to update page title in app bar when partner's name changes.
    final ValueListenableBuilder<String> listenableTitle =
        ValueListenableBuilder<String>(
      valueListenable:
          Provider.of<PartnersInfoState>(context, listen: false).partnersName,
      builder: (BuildContext context, String partnersName, Widget? child) =>
          FittedBox(
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
        body: Consumer<PartnersInfoState>(builder:
            (BuildContext context, PartnersInfoState partnersInfoState, _) {
          if (Provider.of<UserInfoState>(context).partnerLinked) {
            debugPrint(
                "_PartnersBarsState: Linked partner id: ${partnersInfoState.partnersInfo?.partnerID}");
            Query<RelationshipBarDocument> userBarsQuery =
                RelationshipBarDocument.getOrderedUserBarsFromID(
                    partnersInfoState.partnersID!, widget.firestore);

            return StreamBuilder<QuerySnapshot<RelationshipBarDocument>>(
                stream: userBarsQuery.snapshots(),
                builder: (context, snapshot) =>
                    buildBars(context, snapshot, nonInteractableBarBuilder));
          }
          debugPrint("_PartnersBarsState: Not linked to a partner.");
          return const LinkPartnerScreen();
        }),
      ),
      floatingActionButton: Consumer2<UserInfoState, ApplicationState>(
          builder: (context, userInfoState, appState, _) {
        if (!userInfoState.partnerLinked ||
            !appState.canSendNudgeNotification()) {
          return const SizedBox.shrink();
        }
        return BlurredCircle(
          child: FloatingActionButton(
            heroTag: "nudgeButton",
            onPressed: () async => await clickSendNudge(appState),
            tooltip: 'Nudge',
            child: const Icon(Icons.notification_add),
          ),
        );
      }),
    );
  }
}
