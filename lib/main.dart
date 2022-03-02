// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../pages/sign_in_page.dart';
import '../providers/application_state.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../providers/your_bars_state.dart';
import '../responsive/responsive_screen_layout.dart';
import '../utils/theme_data.dart';

/*
TODO: Explain what magic link is on sign in screen. Login is two words when verb.
TODO: Show part of bottom slider to make it clear you can scroll.
TODO: Clean up code.
TODO: Add loading indicators wherever awaiting async. Use listener.
TODO: Show no internet connection message when trying to connect to FireStore and no connection error is given.
TODO: When pulling partners bars from online database, check if still linked to partner. If not, delete partner id from local storage.
TODO: Pull down to refresh and refresh button on partners page.
TODO: Settings Screen - Login, Logout, Connect to partner (Display user code), Change display name, etc.
TODO: Allow convert an anonymous account to a permanent account https://firebase.google.com/docs/auth/android/anonymous-auth?authuser=0#convert-an-anonymous-account-to-a-permanent-account
TODO: Store anonymous account details in sharedprefs to allow signing back in to anon account.
TODO: Explain magic link better, and what happens if choose to skip login.
TODO: Have cancel/back button on magic link screens.
TODO: Optimization, only update widgets that need updating.
 */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ApplicationState.instance.init();
  LicenseRegistry.addLicense(() async* {
    String license = await rootBundle.loadString('assets/google_fonts/DMSansOFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    license = await rootBundle.loadString('assets/google_fonts/PoppinsOFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  // Only use the included google fonts, don't fetch from online
  GoogleFonts.config.allowRuntimeFetching = false;
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
              value: SystemUiOverlayStyle.dark.copyWith(statusBarIconBrightness: Brightness.light),
              child: SafeArea(
                child: StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          return responsiveLayout;
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
