import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  State<YourBars> createState() => _YourBarsState();
}

class _YourBarsState extends State<YourBars>
    with AutomaticKeepAliveClientMixin<YourBars> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      primary: false,
      body: NestedScrollView(
        // App bar title that hides when scrolling.
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            const BarsPageAppBar(barTitleWidget: Text("Your Bars")),
          ];
        },
        body: Consumer2<ApplicationState, UserInfoState>(
          builder: (context, applicationState, userInfoState, _) =>
              (applicationState.loginState == ApplicationLoginState.loggedIn &&
                      userInfoState.userExist)
                  ? BarDocBuilder(
                      barDoc: userInfoState.latestRelationshipBarDoc,
                      itemBuilderFunction: interactableBarBuilder)
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
        ),
      ),
      floatingActionButton: Consumer2<ApplicationState, UserInfoState>(
          builder: (context, applicationState, userInfoState, _) {
        if (applicationState.loginState != ApplicationLoginState.loggedIn ||
            userInfoState.latestRelationshipBarDoc == null ||
            !userInfoState.barsChanged) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BlurredCircle(
              child: FloatingActionButton(
                heroTag: "cancelButton",
                onPressed: () async {
                  await userInfoState.latestRelationshipBarDoc?.resetBars();
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
                onPressed: () async => setState(() async {
                  await userInfoState.saveBars();
                }),
                tooltip: 'Save',
                child: const Icon(Icons.save),
              ),
            ),
          ],
        );
      }),
    );
  }
}
