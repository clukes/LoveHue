import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/database/local_database_handler.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/database/firestore_database_handler.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
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
    return Scaffold(
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
          body: Consumer<ApplicationState>(
              builder: (context, appState, _) =>(appState.userID != null)
              ? BarListBuilder(bars: YourBarsState.instance.yourRelationshipBars, itemBuilderFunction: interactableBarBuilder)
              : const Center(
                  child: Text("Not logged in"),
                ),
          ),
          // /* TODO: FIX BUTTON SO IT DOESN'T OVERLAP SLIDERS. CHOOSE BETTER ICON (FLOPPY DISK) */
          floatingActionButton: Consumer<YourBarsState>(
              builder: (context, yourBarsState, _) =>
              (ApplicationState.instance.loginState == ApplicationLoginState.loggedIn && yourBarsState.yourRelationshipBars != null && yourBarsState.barsChanged)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          heroTag: "cancelButton",
                          onPressed: () {
                            setState(() {
                              yourBarsState.yourRelationshipBars = RelationshipBar.resetBars(yourBarsState.yourRelationshipBars!);
                              yourBarsState.resetBarChange();
                              yourBarsState.barsReset = true;
                            });
                          },
                          /* TODO: CANCEL CHANGES, RESET TO ONLINE DATABASE VALUES */
                          tooltip: 'Cancel',
                          child: const Icon(Icons.cancel),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          heroTag: "saveButton",
                          onPressed: () async {
                            setState(() {
                              yourBarsState.yourRelationshipBars = RelationshipBar.resetBarsChanged(yourBarsState.yourRelationshipBars!);
                              yourBarsState.resetBarChange();
                            });
                            if (ApplicationState.instance.userID != null) {
                              await RelationshipBar.firestoreSetList(
                                  ApplicationState.instance.userID!, yourBarsState.yourRelationshipBars!);
                            }
                          },
                          /* TODO: ONLY SHOW SAVE BUTTON WHEN VALUES CHANGED. USE SOME ANYCHANGED VARIABLE SET TO TRUE WHEN DISPLAYING UNDO BUTTONS. */
                          tooltip: 'Save',
                          child: const Icon(Icons.save),
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),
    );
  }

  void _pushPartners() {
    Navigator.pushReplacementNamed(context, '/partners');
  }
}
