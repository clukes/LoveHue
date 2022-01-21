import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/database/local_database_handler.dart';
import 'package:relationship_bars/database/secure_storage_handler.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/main.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:relationship_bars/widgets/bar_builders.dart';
import 'package:sqflite/sqflite.dart';

/* TODO: SHOW LINK WITH PARTNER CODE FORM WHEN NO PARTNER LINKED */

class PartnersBars extends StatefulWidget {
  const PartnersBars({Key? key}) : super(key: key);

  @override
  _PartnersBarsState createState() => _PartnersBarsState();
}

class _PartnersBarsState extends State<PartnersBars> {
  /* TODO: Use local variable to check partners ID. Only store in SecureStorage if changed when connecting to FireStore, and read from SecureStorage on app startup */
  // final RelationshipBarRepository barRepo = RelationshipBarRepository(partnersRelationshipBarsTableName);

  @override
  Widget build(BuildContext context) {
    print("BUILD PARTNERS");
    return Scaffold(
        appBar: AppBar(
          title: const Text('Partners Relationship Bars'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushYour,
              tooltip: 'Your Bars',
            ),
          ],
        ),
        body: Consumer<ApplicationState>(
          builder: (context, appState, _) => (appState.partnersID != null)
              ? barStreamBuilder(appState.partnersID!, nonInteractableBarBuilder)
              : Container(),
        ));
  }
  void _pushYour() {
    Navigator.pop(context);
  }
}
