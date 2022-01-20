import 'package:flutter/material.dart';
import 'package:relationship_bars/database/local_database_handler.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/main.dart';
import 'package:relationship_bars/widgets/bar_builders.dart';
import 'package:sqflite/sqflite.dart';

/* TODO: SHOW LINK WITH PARTNER CODE FORM WHEN NO PARTNER LINKED */

const String partnersRelationshipBarsTableName = "PartnersRelationshipBars";

class PartnersBars extends StatefulWidget {
  const PartnersBars({Key? key}) : super(key: key);

  @override
  _PartnersBarsState createState() => _PartnersBarsState();
}

class _PartnersBarsState extends State<PartnersBars> {
  RelationshipBarRepository barRepo = RelationshipBarRepository(DatabaseHandler(), partnersRelationshipBarsTableName);

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
      body: FutureBuilder(
        future: barRepo.retrieveElements(),
        builder: (context, AsyncSnapshot<List<RelationshipBar>>snapshot) => buildBars(context, snapshot, nonInteractableBarBuilder, barRepo),
      ),
    );
  }

  void _pushYour() {
    Navigator.pop(context);
  }
}
