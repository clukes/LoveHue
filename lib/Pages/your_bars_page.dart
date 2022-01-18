import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/Database/database_handler.dart';
import 'package:relationship_bars/Database/relationship_bar_model.dart';
import 'package:relationship_bars/main.dart';

import '../application_state.dart';
import '../authentication.dart';

const String yourRelationshipBarsTableName = 'YourRelationshipBars';

class YourBars extends StatefulWidget {
  const YourBars({Key? key}) : super(key: key);

  @override
  _YourBarsState createState() => _YourBarsState();
}

class _YourBarsState extends State<YourBars> {
  RelationshipBarRepository barRepo = RelationshipBarRepository(
      DatabaseHandler(), yourRelationshipBarsTableName);

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
      body: FutureBuilder(
        future: barRepo.retrieveElements(),
        builder: (context, AsyncSnapshot<List<RelationshipBar>> snapshot) =>
            buildBars(context, snapshot, interactableBarBuilder, barRepo),
      ),
      /* TODO: FIX BUTTON SO IT DOESN'T OVERLAP SLIDERS. CHOOSE BETTER ICON (FLOPPY DISK) */
      floatingActionButton: Consumer<ApplicationState>(
        builder: (context, appState, _) => Container(
          child:
          (appState.loginState == ApplicationLoginState.loggedIn) ?
              FloatingActionButton(
                onPressed: () async => appState.updateBarsInOnlineDatabase(
                    await barRepo.retrieveElements()),
                /* TODO: SAVE BAR VALUES IN SERVER */ /* TODO: ONLY SHOW SAVE BUTTON WHEN VALUES CHANGED, ALSO HAVE CANCEL */
                tooltip: 'Save',
                child: const Icon(Icons.add),
              ) : null
        ),
      ),
    );
  }

  void _pushPartners() {
    Navigator.pushNamed(context, '/partners');
  }
}
