// TODO: Setup new email and developer name
// Copyright (C) 2022 Conner Lukes <clukes@me.com>
// All rights reserved.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lovehue/services/database_service.dart';
import 'package:lovehue/services/notification_service.dart';
import 'package:lovehue/services/shared_preferences_service.dart';
import 'package:lovehue/utils/configs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/sign_in_page.dart';
import 'providers/application_state.dart';
import 'providers/partners_info_state.dart';
import 'providers/user_info_state.dart';
import 'resources/authentication_info.dart';
import 'responsive/responsive_screen_layout.dart';
import 'utils/app_info_class.dart';
import 'utils/theme_data.dart';

/// Entry point with initializers.
Future<void> mainCommon(FirebaseOptions firebaseOptions, AppInfo flavorAppInfo,
    {PackageInfo? packageInfo,
    AppRunner? appRunner,
    FirebaseApp? firebaseApp,
    FirebaseAuth? firebaseAuth,
    NotificationService? notificationService}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppInfo appInfo = flavorAppInfo;
  packageInfo ??= await PackageInfo.fromPlatform();

  firebaseApp ??= await Firebase.initializeApp(options: firebaseOptions);
  final FirebaseFirestore firestore =
      FirebaseFirestore.instanceFor(app: firebaseApp);

  final AuthenticationInfo authenticationInfo = AuthenticationInfo(packageInfo);
  FirebaseUIAuth.configureProviders(authenticationInfo.providers);

  // Add licenses for the fonts.
  LicenseRegistry.addLicense(() async* {
    String license =
        await rootBundle.loadString('assets/google_fonts/DMSansOFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    license = await rootBundle.loadString('assets/google_fonts/PoppinsOFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  // Only uses the bundled google fonts, prevents fetching from online.
  GoogleFonts.config.allowRuntimeFetching = false;

  if (notificationService == null) {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService(sharedPreferences);
    final DatabaseService databaseService = DatabaseService(firestore);
    final NotificationsConfig notificationsConfig =
        await NotificationsConfig.initialize();
    notificationService = NotificationService(
        sharedPreferencesService, databaseService, notificationsConfig);
  }

  final PartnersInfoState partnersInfoState =
      PartnersInfoState(notificationService);
  final UserInfoState userInfoState =
      UserInfoState(firestore, partnersInfoState);
  final ApplicationState applicationState = ApplicationState(
    userInfoState: userInfoState,
    partnersInfoState: partnersInfoState,
    firestore: firestore,
    authenticationInfo: authenticationInfo,
    auth: firebaseAuth ?? FirebaseAuth.instance,
    appInfo: appInfo,
    notificationService: notificationService,
  );

  final List<ChangeNotifierProvider<ChangeNotifier>> providers = [
    ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
    ChangeNotifierProvider<PartnersInfoState>.value(value: partnersInfoState),
    ChangeNotifierProvider<ApplicationState>.value(value: applicationState),
  ];

  appRunner ??= AppRunner(
    widget: RelationshipBarsApp(providers: providers),
    runMethod: runApp,
  );
  appRunner.run();
}

class AppRunner {
  AppRunner({
    required this.widget,
    required this.runMethod,
  });

  final Widget widget;
  final Function(Widget) runMethod;

  void run() => runMethod(widget);
}

/// Initial widget for the app.
class RelationshipBarsApp extends StatelessWidget {
  const RelationshipBarsApp({Key? key, required this.providers})
      : super(key: key);

  final List<ChangeNotifierProvider<ChangeNotifier>> providers;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Setup providers for states.
      providers: providers,
      builder: (context, child) => GlobalLoaderOverlay(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: false,
          title: Provider.of<ApplicationState>(context, listen: false)
              .appInfo
              .appName,
          // Currently there is only one theme, a light one.
          theme: lightThemeData,
          home: AnnotatedRegion<SystemUiOverlayStyle>(
            // Ensures that the status bar stays dark with light text.
            value: SystemUiOverlayStyle.dark
                .copyWith(statusBarIconBrightness: Brightness.light),
            child: SafeArea(
              child: StreamBuilder(
                stream: Provider.of<ApplicationState>(context, listen: false)
                    .auth
                    .authStateChanges(),
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
      ),
    );
  }
}
