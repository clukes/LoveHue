import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/pages/sign_in_page.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/utils/app_info_class.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

typedef Callback = void Function(MethodCall call);

void setupCloudFirestoreMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

void main() {
  const appName = 'TEST_APP_NAME';
  const AppInfo appInfo = AppInfo(
    appName: appName,
    aboutText: 'TEST_ABOUT',
  );

  late MockApplicationState appState;
  late MockAuthenticationInfo authenticationInfo;
  late Widget testWidget;
  late Widget testWidgetBuild;

  setUpAll(() async {
    setupCloudFirestoreMocks();

    await Firebase.initializeApp();
  });

  setUp(() {
    appState = MockApplicationState();
    authenticationInfo = MockAuthenticationInfo();
    testWidget = const SignInPage();
    testWidgetBuild = MaterialApp(
        home: MultiProvider(
      providers: [
        ChangeNotifierProvider<ApplicationState>.value(value: appState),
      ],
      child: testWidget,
    ));
    when(appState.appInfo).thenReturn(appInfo);
    when(appState.authenticationInfo).thenReturn(authenticationInfo);
    when(authenticationInfo.signInAnonymously(any))
        .thenAnswer((_) => Future.value());
    when(authenticationInfo.providerConfigs).thenReturn([]);
  });

  testWidgets('displays app name', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    expect(find.textContaining(appName), findsWidgets);
  });

  testWidgets('skip login signs in anonymously', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Skip Login'));

    verify(authenticationInfo.signInAnonymously(any));
  });
}
