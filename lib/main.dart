// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/firebase_options.dart';
import 'package:relationship_bars/pages/sign_in_page.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/responsive/mobile_screen_layout.dart';
import 'package:relationship_bars/responsive/responsive_screen_layout.dart';
import 'package:relationship_bars/responsive/web_screen_layout.dart';
import 'package:relationship_bars/utils/theme_data.dart';

/*
TODO: Delete database data when delete account clicked.
TODO: Explain what magic link is on sign in screen. Login is two words when verb.
TODO: Show part of bottom slider to make it clear you can scroll.
TODO: Partners app has to be restarted when you connect to them.
TODO: Figure out why partners name doesn't show up on partners page and settings page.
TODO: Clean up code.
TODO: Accept/Reject incoming partner link request.
TODO: Order bars so that they are always shown in the same order for each person. Have some order field to support reordering.
TODO: Add loading indicators wherever awaiting async. Use listener.
TODO: Show no internet connection message when trying to connect to FireStore and no connection error is given.
TODO: When pulling partners bars from online database, check if still linked to partner. If not, delete partner id from local storage.
TODO: Pull down to refresh and refresh button on partners page.
TODO: Settings Screen - Login, Logout, Connect to partner (Display user code), Change display name, etc.
TODO: Allow convert an anonymous account to a permanent account https://firebase.google.com/docs/auth/android/anonymous-auth?authuser=0#convert-an-anonymous-account-to-a-permanent-account
TODO: Store anonymous account details in sharedprefs to allow signing back in to anon account.
TODO: Explain magic link better, and what happens if choose to skip login.
TODO: Have cancel/back button on magic link screens.
TODO: Beautify UI.
TODO: Optimization, only update widgets that need updating.
 */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ApplicationState.instance.init();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(const RelationshipBarsApp());
}

class RelationshipBarsApp extends StatelessWidget {
  const RelationshipBarsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ApplicationState>.value(value: ApplicationState.instance),
          ChangeNotifierProvider<UserInfoState>.value(value: UserInfoState.instance),
          ChangeNotifierProvider<PartnersInfoState>.value(value: PartnersInfoState.instance),
          ChangeNotifierProvider<YourBarsState>.value(value: YourBarsState.instance),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            showPerformanceOverlay: false,
            title: 'Relationship Bars',
            theme: themeData,
            home: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: SafeArea(
                child: StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          return const ResponsiveLayout(
                            mobileScreenLayout: MobileScreenLayout(),
                            webScreenLayout: WebScreenLayout(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return const SignInPage();
                    }),
              ),
            )));
  }
}
