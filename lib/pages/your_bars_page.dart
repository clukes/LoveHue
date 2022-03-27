import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relationship_bar_document.dart';
import '../providers/application_state.dart';
import '../providers/user_info_state.dart';
import '../widgets/app_bars.dart';
import '../widgets/bar_builders.dart';
import '../widgets/buttons.dart';

/// Your Bars page builder.
///
/// Uses [AutomaticKeepAliveClientMixin] for persistent scroll state.
class YourBars extends StatefulWidget {
  const YourBars({Key? key}) : super(key: key);

  @override
  _YourBarsState createState() => _YourBarsState();
}

class _YourBarsState extends State<YourBars> with AutomaticKeepAliveClientMixin<YourBars> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ApplicationState>(
        builder: (context, applicationState, _) => Scaffold(
              primary: false,
              body: NestedScrollView(
                // App bar title that hides when scrolling.
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    const BarsPageAppBar(barTitleWidget: Text("Your Bars")),
                  ];
                },
                body: Consumer<UserInfoState>(
                  builder: (context, userInfoState, _) =>
                      (applicationState.loginState == ApplicationLoginState.loggedIn && userInfoState.userExist)
                          ? BarDocBuilder(
                              barDoc: userInfoState.latestRelationshipBarDoc,
                              itemBuilderFunction: interactableBarBuilder)
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                ),
              ),
              floatingActionButton: Consumer<UserInfoState>(
                  builder: (context, userInfoState, _) => (applicationState.loginState ==
                              ApplicationLoginState.loggedIn &&
                          userInfoState.latestRelationshipBarDoc != null &&
                          userInfoState.barsChanged)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            BlurredCircle(
                              child: FloatingActionButton(
                                heroTag: "cancelButton",
                                onPressed: () async {
                                  userInfoState.latestRelationshipBarDoc =
                                      await userInfoState.latestRelationshipBarDoc?.resetBars(userInfoState.userID!);
                                  setState(() {
                                    userInfoState.resetBarChange();
                                    userInfoState.barsReset = true;
                                  });
                                },
                                tooltip: 'Cancel',
                                child: const Icon(Icons.cancel),
                              ),
                            ),
                            const SizedBox(width: 10),
                            BlurredCircle(
                              child: FloatingActionButton(
                                heroTag: "saveButton",
                                onPressed: () async {
                                  String? userID = userInfoState.userID;
                                  if (userID != null && userInfoState.barList != null) {
                                    RelationshipBarDocument barDoc =
                                        userInfoState.latestRelationshipBarDoc!.resetBarsChanged();
                                    userInfoState.resetBarChange();
                                    barDoc = await RelationshipBarDocument.firestoreAddBarList(
                                        userID, barDoc.barList!, userInfoState.firestore);
                                    setState(() {
                                      userInfoState.latestRelationshipBarDoc = barDoc;
                                    });
                                  }
                                },
                                tooltip: 'Save',
                                child: const Icon(Icons.save),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),
            ));
  }
}
