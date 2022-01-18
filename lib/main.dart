// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:relationship_bars/Database/relationship_bar_model.dart';
import 'package:relationship_bars/bar_slider_model.dart';
import 'package:relationship_bars/partners_bars_page.dart';
import 'package:relationship_bars/your_bars_page.dart';

/*
TODO: Second screen for partners bars
TODO: Firebase implementation - account/auth, storing in server, updating from server
 */

void main() async {
  runApp(const RelationshipBarsApp());
}

/*TODO: SHARED PREFERENCES IS BEST FOR STORING SETTINGS*/
class RelationshipBarsApp extends StatelessWidget {
  const RelationshipBarsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relationship Bars',
      initialRoute: '/yours',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/yours': (context) => const YourBars(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/partners': (context) => const PartnersBars(),
      },
    );
  }
}

Widget buildBars(
    BuildContext context,
    AsyncSnapshot<List<RelationshipBar>> snapshot,
    Widget Function(BuildContext context, RelationshipBar bar, RelationshipBarRepository barRepo)
        itemBuilderFunction,
    RelationshipBarRepository barRepo) {
  if (snapshot.hasData) {
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
