import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relationship_bar_model.dart';
import '../providers/application_state.dart';
import '../providers/user_info_state.dart';
import '../providers/your_bars_state.dart';
import '../widgets/app_bars.dart';
import '../widgets/bar_builders.dart';
import '../widgets/buttons.dart';

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
    return Scaffold(
      primary: false,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            const BarsPageAppBar(barTitleWidget: Text("Your Bars")),
          ];
        },
        body: Consumer<UserInfoState>(
          builder: (context, appState, _) =>
              (ApplicationState.instance.loginState == ApplicationLoginState.loggedIn && appState.userExist)
                  ? BarDocBuilder(
                      barDoc: YourBarsState.instance.latestRelationshipBarDoc,
                      itemBuilderFunction: interactableBarBuilder)
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
        ),
      ),
      floatingActionButton: Consumer<YourBarsState>(
          builder: (context, yourBarsState, _) => (ApplicationState.instance.loginState ==
                      ApplicationLoginState.loggedIn &&
                  yourBarsState.latestRelationshipBarDoc != null &&
                  yourBarsState.barsChanged)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BlurredCircle(
                      child: FloatingActionButton(
                        heroTag: "cancelButton",
                        onPressed: () async {
                          yourBarsState.latestRelationshipBarDoc =
                              await yourBarsState.latestRelationshipBarDoc?.resetBars();
                          setState(() {
                            yourBarsState.resetBarChange();
                            yourBarsState.barsReset = true;
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
                          String? userID = UserInfoState.instance.userID;
                          if (userID != null && yourBarsState.barList != null) {
                            RelationshipBarDocument barDoc = yourBarsState.latestRelationshipBarDoc!.resetBarsChanged();
                            yourBarsState.resetBarChange();
                            barDoc = await RelationshipBarDocument.firestoreAddBarList(userID, barDoc.barList!);
                            setState(() {
                              yourBarsState.latestRelationshipBarDoc = barDoc;
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
    );
  }
}
