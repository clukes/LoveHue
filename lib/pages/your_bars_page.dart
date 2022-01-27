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
        title: const Text('Your Bars'),
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => (appState.userID != null)
            ? BarDocBuilder(
                barDoc: YourBarsState.instance.latestRelationshipBarDoc,
                itemBuilderFunction: interactableBarBuilder)
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      floatingActionButton: Consumer<YourBarsState>(
          builder: (context, yourBarsState, _) => (ApplicationState
                          .instance.loginState ==
                      ApplicationLoginState.loggedIn &&
                  yourBarsState.latestRelationshipBarDoc != null &&
                  yourBarsState.barsChanged)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: "cancelButton",
                      onPressed: () async {
                        yourBarsState.latestRelationshipBarDoc =
                            await yourBarsState.latestRelationshipBarDoc
                                ?.resetBars();
                        setState(() {
                          yourBarsState.resetBarChange();
                          yourBarsState.barsReset = true;
                        });
                      },
                      tooltip: 'Cancel',
                      child: const Icon(Icons.cancel),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: "saveButton",
                      onPressed: () async {
                        if (ApplicationState.instance.userID != null &&
                            yourBarsState.barList != null) {
                          RelationshipBarDocument barDoc = yourBarsState
                              .latestRelationshipBarDoc!
                              .resetBarsChanged();
                          yourBarsState.resetBarChange();
                          barDoc =
                              await RelationshipBarDocument.firestoreAddBarList(
                                  ApplicationState.instance.userID!,
                                  barDoc.barList!);
                          setState(() {
                            yourBarsState.latestRelationshipBarDoc = barDoc;
                          });
                        }
                      },
                      tooltip: 'Save',
                      child: const Icon(Icons.save),
                    ),
                  ],
                )
              : const SizedBox.shrink()),
    );
  }
}
