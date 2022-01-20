import 'package:flutter/material.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/widgets/bar_sliders.dart';

Widget buildBars(
    BuildContext context,
    AsyncSnapshot<List<RelationshipBar>> snapshot,
    Widget Function(BuildContext context, RelationshipBar bar, RelationshipBarRepository barRepo)
    itemBuilderFunction,
    RelationshipBarRepository barRepo) {
  print('buildingBars');
  print(snapshot);

  if (snapshot.hasData) {
    print('hasData');
    print(snapshot.data![1].prevValue);
    print(snapshot.data![1].changed);
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: snapshot.data!.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (context, index) =>
          itemBuilderFunction(context, snapshot.data![index], barRepo),
    );
  } else {
    return const Center(child: CircularProgressIndicator());
  }
}

Widget interactableBarBuilder(BuildContext context, RelationshipBar bar, RelationshipBarRepository barRepo) {
  return InteractableBarSlider(relationshipBar: bar, barRepo: barRepo);
}

Widget nonInteractableBarBuilder(BuildContext context, RelationshipBar bar, RelationshipBarRepository barRepo) {
  return NonInteractableBarSlider(relationshipBar: bar, barRepo: barRepo);
}
