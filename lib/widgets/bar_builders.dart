import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/widgets/bar_sliders.dart';

Widget buildBars(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<RelationshipBar>> snapshot,
    Widget Function(BuildContext context, RelationshipBar bar)
        itemBuilderFunction) {
  if (snapshot.hasError) {
    return Center(
      child: Text(snapshot.error.toString()),
    );
  }
  if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
  }
  final QuerySnapshot<RelationshipBar> data = snapshot.requireData;

  return ListView.separated(
    padding: const EdgeInsets.all(16.0),
    itemCount: data.size,
    separatorBuilder: (BuildContext context, int index) => const Divider(),
    itemBuilder: (context, index) =>
        itemBuilderFunction(context, data.docs[index].data()),
  );
}

Widget interactableBarBuilder(BuildContext context, RelationshipBar bar) {
  return InteractableBarSlider(relationshipBar: bar);
}

Widget nonInteractableBarBuilder(BuildContext context, RelationshipBar bar) {
  return NonInteractableBarSlider(relationshipBar: bar);
}

Widget barStreamBuilder(String id, Widget Function(BuildContext context, RelationshipBar bar) itemBuilderFunction) {
  return StreamBuilder<QuerySnapshot<RelationshipBar>>(
      stream: userBarsFirestoreRef(id).snapshots(),
      builder: (context, snapshot) {
        return buildBars(context, snapshot, itemBuilderFunction);
      });
}
