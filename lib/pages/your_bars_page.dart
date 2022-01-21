import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/database/local_database_handler.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/database/firestore_database_handler.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:relationship_bars/widgets/bar_builders.dart';

import '../main.dart';
import '../providers/application_state.dart';
import '../resources/authentication.dart';

class YourBars extends StatefulWidget {
  const YourBars({Key? key}) : super(key: key);

  @override
  _YourBarsState createState() => _YourBarsState();
}

class _YourBarsState extends State<YourBars> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Your Relationship Bars'),
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: _pushPartners,
                tooltip: 'Partners Bars',
              ),
            ],
          ),
          body: (appState.userID != null)
              ? barStreamBuilder(appState.userID!, interactableBarBuilder)
              : const Center(
                  child: Text("Not logged in"),
                ),
          // /* TODO: FIX BUTTON SO IT DOESN'T OVERLAP SLIDERS. CHOOSE BETTER ICON (FLOPPY DISK) */
          // floatingActionButton:
          //     (appState.loginState != ApplicationLoginState.loggedIn)
          //         ? Row(
          //             children: [
          //               FloatingActionButton(
          //                 heroTag: "saveButton",
          //                 onPressed: () async {
          //                   List<RelationshipBar> bars =
          //                       await barRepo.retrieveElements();
          //                   setState(() {
          //                     bars = RelationshipBar.resetBarsChanged(bars);
          //                   });
          //                   if (appState.userID != null) {
          //                     await RelationshipBar.firestoreSetList(
          //                         appState.userID!, bars);
          //                   }
          //                 },
          //                 /* TODO: ONLY SHOW SAVE BUTTON WHEN VALUES CHANGED. USE SOME ANYCHANGED VARIABLE SET TO TRUE WHEN DISPLAYING UNDO BUTTONS. */
          //                 tooltip: 'Save',
          //                 child: const Icon(Icons.save),
          //               ),
          //               FloatingActionButton(
          //                 heroTag: "cancelButton",
          //                 onPressed: () async {
          //                   setState(() {
          //                     bars = RelationshipBar.resetBarsChanged(bars);
          //                   });
          //                 },
          //                 /* TODO: CANCEL CHANGES, RESET TO ONLINE DATABASE VALUES */
          //                 tooltip: 'Cancel',
          //                 child: const Icon(Icons.cancel),
          //               ),
          //             ],
          //           )
          //         : const SizedBox.shrink()),
    )
    );
  }

  void _pushPartners() {
    Navigator.pushNamed(context, '/profile');
  }
}
