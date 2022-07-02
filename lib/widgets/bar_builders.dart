import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relationship_bar.dart';
import '../models/relationship_bar_document.dart';
import '../providers/user_info_state.dart';
import '../resources/data_formatting.dart';
import '../widgets/bar_sliders.dart';
import 'app_bars.dart';

/// Builder to build widgets for a [RelationshipBarDocument], including each [RelationshipBar].
class BarDocBuilder extends StatelessWidget {
  const BarDocBuilder({Key? key, this.barDoc, required this.itemBuilderFunction}) : super(key: key);

  final RelationshipBarDocument? barDoc;

  /// Function used to build a [RelationshipBar] widget.
  final Widget Function(BuildContext context, RelationshipBar bar) itemBuilderFunction;

  @override
  Widget build(BuildContext context) {
    if (barDoc != null) {
      List<RelationshipBar>? bars = barDoc!.barList ?? [];
      return Column(children: [
        if (barDoc?.timestamp != null)
          AppBar(
            primary: false,
            titleTextStyle: Theme.of(context).textTheme.subtitle2,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Last updated at: ${formatTimestamp(barDoc!.timestamp!)}",
                textScaleFactor: 1.1,
              ),
            ),
            centerTitle: false,
            toolbarHeight: barsPageAppBarHeight / 2,
          ),
        Expanded(
          child: ListView.builder(
            // kFloatingActionButtonMargin to give space at the bottom where floating action buttons don't overlap with bars.
            padding: const EdgeInsets.only(top: 4, bottom: kFloatingActionButtonMargin + 64),
            itemCount: bars.length,
            itemBuilder: (context, index) => itemBuilderFunction(context, bars[index]),
          ),
        )
      ]);
    }
    return const Center(child: CircularProgressIndicator());
  }
}

/// Builder for a non-disabled [RelationshipBar], e.g. on YourBars page.
Widget interactableBarBuilder(BuildContext context, RelationshipBar bar) {
  WidgetsBinding.instance.addPostFrameCallback((_) =>
      Provider.of<UserInfoState>(context, listen: false).barsReset = false
  );
  return InteractableBarSlider(relationshipBar: bar);
}

/// Builder for a disabled [RelationshipBar], e.g. on PartnersBars page.
Widget nonInteractableBarBuilder(BuildContext context, RelationshipBar bar) {
  return NonInteractableBarSlider(relationshipBar: bar);
}

/// Builds bars from given QuerySnapshot using the builder function.
Widget buildBars(BuildContext context, AsyncSnapshot<QuerySnapshot<RelationshipBarDocument>> snapshot,
    Widget Function(BuildContext context, RelationshipBar bar) itemBuilderFunction) {
  if (snapshot.hasError) {
    return Center(
      child: Text(snapshot.error.toString()),
    );
  }
  if (!snapshot.hasData) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    return const Center(child: Text("No bars found for partner."));
  }
  RelationshipBarDocument? latestBarDoc;
  List<RelationshipBarDocument> listBarDocs = RelationshipBarDocument.fromQuerySnapshot(snapshot.requireData);
  if (listBarDocs.isNotEmpty) {
    latestBarDoc = listBarDocs.first;
  }
  return BarDocBuilder(barDoc: latestBarDoc, itemBuilderFunction: itemBuilderFunction);
}
