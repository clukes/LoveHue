import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/widgets/bar_sliders.dart';

Widget buildBars(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<RelationshipBarDocument>> snapshot,
    Widget Function(BuildContext context, RelationshipBar bar)
        itemBuilderFunction) {
  print("Build");
  if (snapshot.hasError) {
    return Center(
      child: Text(snapshot.error.toString()),
    );
  }
  if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
  }
  final RelationshipBarDocument latestBarDoc = RelationshipBarDocument.fromQuerySnapshot(snapshot.requireData)[0];
  final List<RelationshipBar>? bars = latestBarDoc.barList;

  return BarListBuilder(bars: bars, itemBuilderFunction: itemBuilderFunction);
}

class BarListBuilder extends StatelessWidget {
  final List<RelationshipBar>? bars;
  final Widget Function(BuildContext context, RelationshipBar bar) itemBuilderFunction;

  const BarListBuilder({Key? key, this.bars, required this.itemBuilderFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("LIST");
    if (bars != null) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kFloatingActionButtonMargin + 128),
        itemCount: bars!.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) =>
            itemBuilderFunction(context, bars![index]),
      );
    }
    return const Center(child: Text("No Relationship Bars"));
  }

}

Widget interactableBarBuilder(BuildContext context, RelationshipBar bar) {
  WidgetsBinding.instance?.addPostFrameCallback((_) => YourBarsState.instance.barsReset=false);
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
