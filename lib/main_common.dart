// TODO: Setup new email and developer name
// Copyright (C) 2022 Conner Lukes <clukes@icloud.com>
// All rights reserved.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../pages/sign_in_page.dart';
import '../providers/application_state.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../providers/your_bars_state.dart';
import '../responsive/responsive_screen_layout.dart';
import '../utils/theme_data.dart';
import 'utils/app_info_class.dart';

late final AppInfo appInfo;

/// Entry point with initializers.
void mainCommon(FirebaseOptions firebaseOptions, AppInfo flavorAppInfo) async {
  appInfo = flavorAppInfo;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  await ApplicationState.instance.init();

  // Add licenses for the fonts.
  LicenseRegistry.addLicense(() async* {
    String license = await rootBundle.loadString('assets/google_fonts/DMSansOFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    license = await rootBundle.loadString('assets/google_fonts/PoppinsOFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  // Only uses the bundled google fonts, prevents fetching from online.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const RelationshipBarsApp());
}

/// Initial widget for the app.
class RelationshipBarsApp extends StatelessWidget {
  const RelationshipBarsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Setup providers for states.
      providers: [
        ChangeNotifierProvider<ApplicationState>.value(value: ApplicationState.instance),
        ChangeNotifierProvider<UserInfoState>.value(value: UserInfoState.instance),
        ChangeNotifierProvider<PartnersInfoState>.value(value: PartnersInfoState.instance),
        ChangeNotifierProvider<YourBarsState>.value(value: YourBarsState.instance),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        title: appInfo.appName, //TODO: Set to correct name.
        // Currently there is only one theme, a light one.
        theme: lightThemeData,
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          // Ensures that the status bar stays dark with light text.
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
                },
            ),
          ),
        ),
      ),
    );
  }
}
