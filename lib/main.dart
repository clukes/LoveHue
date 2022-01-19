// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/database/relationship_bar_model.dart';
import 'package:relationship_bars/models/bar_slider_model.dart';
import 'package:relationship_bars/Pages/partners_bars_page.dart';
import 'package:relationship_bars/Pages/your_bars_page.dart';
import 'package:relationship_bars/responsive/mobile_screen_layout.dart';
import 'package:relationship_bars/responsive/responsive_layout_screen.dart';
import 'package:relationship_bars/responsive/web_screen_layout.dart';
import 'package:relationship_bars/utils/colors.dart';

import 'Pages/login_page.dart';
import 'providers/application_state.dart';

/*
TODO: Bottom Navigation Bar
TODO: Settings Screen - Login, Logout, Connect to partner (Display user code), Change display name, etc.
TODO: Display name on your bars and partners name on partners bars.
TODO: Firebase implementation - account/auth, storing in server, updating from server
TODO: Allow convert an anonymous account to a permanent account https://firebase.google.com/docs/auth/android/anonymous-auth?authuser=0#convert-an-anonymous-account-to-a-permanent-account
 TODO: Beautify UI, don't leave as Instagram clone.
 TODO: Delete account option
 */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      ChangeNotifierProvider(
        create: (context) => ApplicationState(),
        builder: (context, _) => const RelationshipBarsApp(),
      )
  );
}

/* TODO: SHARED PREFERENCES IS BEST FOR STORING SETTINGS
*  TODO: STORE PARTNER USERID IN SHARED PREFERENCES
*/
class RelationshipBarsApp extends StatelessWidget {
  const RelationshipBarsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: false,
      title: 'Relationship Bars',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      initialRoute: '/yours',
      routes: {
        '/login': (context) => const LoginPage(),
        '/yours': (context) => const YourBars(),
        '/partners': (context) => const PartnersBars(),
      },
      home: const LoginPage(),
      // home: const ResponsiveLayout(
      //   mobileScreenLayout: MobileScreenLayout(),
      //   webScreenLayout: WebScreenLayout(),
      // ),
    );
  }
}

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
