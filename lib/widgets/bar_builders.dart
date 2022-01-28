import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/widgets/bar_sliders.dart';

Widget buildBars(BuildContext context, AsyncSnapshot<QuerySnapshot<RelationshipBarDocument>> snapshot,
    Widget Function(BuildContext context, RelationshipBar bar) itemBuilderFunction) {
  print("Build");
  if (snapshot.hasError) {
    return Center(
      child: Text(snapshot.error.toString()),
    );
  }
  if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
  }
  RelationshipBarDocument? latestBarDoc;
  List<RelationshipBarDocument> listBars = RelationshipBarDocument.fromQuerySnapshot(snapshot.requireData);
  print(listBars);
  if (listBars.isNotEmpty) {
    latestBarDoc = listBars.first;
  }
  print(latestBarDoc);
  return BarDocBuilder(barDoc: latestBarDoc, itemBuilderFunction: itemBuilderFunction);
}

class BarDocBuilder extends StatelessWidget {
  final RelationshipBarDocument? barDoc;
  final Widget Function(BuildContext context, RelationshipBar bar) itemBuilderFunction;

  const BarDocBuilder({Key? key, this.barDoc, required this.itemBuilderFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("LISTBuilder");
    if (barDoc != null) {
      List<RelationshipBar>? bars = barDoc!.barList ?? [];
      return Column(children: [
        (barDoc?.timestamp != null)
            ? Center(
                child: Text("Last updated: ${formatTimestamp(barDoc!.timestamp!)}"),
              )
            : const SizedBox.shrink(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, kFloatingActionButtonMargin + 128),
            itemCount: bars.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) => itemBuilderFunction(context, bars[index]),
          ),
        )
      ]);
    }
    return const Center(child: Text("No Relationship Bars"));
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat.yMMMd().add_jm().format(timestamp.toDate().toLocal());
  }
}

Widget interactableBarBuilder(BuildContext context, RelationshipBar bar) {
  WidgetsBinding.instance?.addPostFrameCallback((_) => YourBarsState.instance.barsReset = false);
  return InteractableBarSlider(relationshipBar: bar);
}

Widget nonInteractableBarBuilder(BuildContext context, RelationshipBar bar) {
  print("BAR");

  return NonInteractableBarSlider(relationshipBar: bar);
}

Widget barStreamBuilder(String id, Widget Function(BuildContext context, RelationshipBar bar) itemBuilderFunction) {
  print("BUILDER");
  return StreamBuilder<QuerySnapshot<RelationshipBarDocument>>(
      stream: userBarsFirestoreRef(id).orderBy(RelationshipBarDocument.columnTimestamp, descending: true).snapshots(),
      builder: (context, snapshot) {
        return buildBars(context, snapshot, itemBuilderFunction);
      });
}
