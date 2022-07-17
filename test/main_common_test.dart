import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/main_common.dart';
import 'package:lovehue/pages/sign_in_page.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/responsive/responsive_screen_layout.dart';
import 'package:lovehue/utils/app_info_class.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'mocker.dart';
import 'mocker.mocks.dart';

void main() {
  test('mainCommon calls AppRunner', () async {
    var mockAppRunner = MockAppRunner();
    await mainCommon(
      const FirebaseOptions(apiKey: '', projectId: '', messagingSenderId: '', appId: ''),
      const AppInfo(appName: '', aboutText: ''),
      packageInfo: PackageInfo(appName: '', packageName: '', version: '', buildNumber: ''),
      appRunner: mockAppRunner,
      firebaseApp: FakeFirebaseApp(),
      firebaseAuth: MockFirebaseAuth(),
    );
    verify(mockAppRunner.run());
  });

  test('AppRunner run calls runMethod with widget', () {
    var widget = const Text("");
    var mockFunction = MockFunction();
    var subject = AppRunner(widget: widget, runMethod: (_) => mockFunction.call());
    subject.run();
    verify(mockFunction.call());
  });

  group('RelationshipBarApp', () {
    late RelationshipBarsApp testWidget;
    late ApplicationState appState;
    late UserInfoState userInfoState;
    late PartnersInfoState partnersInfoState;
    late FirebaseAuth firebaseAuth;
    const appInfo = AppInfo(appName: "Test-App-Name", aboutText: '');

    setUp(() {
      appState = MockApplicationState();
      userInfoState = MockUserInfoState();
      partnersInfoState = MockPartnersInfoState();
      firebaseAuth = MockFirebaseAuth();
      var providers = [
        ChangeNotifierProvider<ApplicationState>.value(value: appState),
        ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
        ChangeNotifierProvider<PartnersInfoState>.value(value: partnersInfoState),
      ];
      testWidget = RelationshipBarsApp(providers: providers);

      when(appState.auth).thenReturn(firebaseAuth);
      when(appState.appInfo).thenReturn(appInfo);
      when(appState.loginState).thenReturn(ApplicationLoginState.loggedOut);
    });

    testWidgets("navigates to responsive layout on sign in", (WidgetTester tester) async {
      await firebaseAuth.signOut();
      await tester.pumpWidget(testWidget);
      await tester.pump();
      expect(find.byType(SignInPage), findsOneWidget);
      await firebaseAuth.signInAnonymously();
      await tester.pump();
      expect(find.byType(ResponsiveLayout), findsOneWidget);
    });

    testWidgets("navigates to sign out page on sign out", (WidgetTester tester) async {
      await firebaseAuth.signInAnonymously();
      await tester.pumpWidget(testWidget);
      await tester.pump();
      expect(find.byType(ResponsiveLayout), findsOneWidget);
      await firebaseAuth.signOut();
      await tester.pump();
      expect(find.byType(SignInPage), findsOneWidget);
    });
  });
}

class MockAppRunner extends Mock implements AppRunner {}

class FakeFirebaseApp extends Fake implements FirebaseApp {
  @override
  String get name => 'test';
}
