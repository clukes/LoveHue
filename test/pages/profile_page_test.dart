import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:lovehue/pages/profile_page.dart';
import 'package:lovehue/pages/settings_page.dart';
import 'package:lovehue/pages/sign_in_page.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/widgets/profile_page_widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.dart';
import '../mocker.mocks.dart';

void main() {
  const displayName = 'TEST_DISPLAY_NAME';
  const partnerDisplayName = 'TEST_PARTNER_DISPLAY_NAME';

  late MockApplicationState appState;
  late MockPartnersInfoState partnersInfoState;
  late MockUserInfoState userInfoState;
  late Widget testWidget;
  late Widget testWidgetBuild;
  late MockFirebaseAuth auth;

  setUpAll(() {
    setupMockFirebaseApp();
  });

  setUp(() {
    appState = MockApplicationState();
    partnersInfoState = MockPartnersInfoState();
    userInfoState = MockUserInfoState();
    auth = MockFirebaseAuth(
        signedIn: true, mockUser: MockUser(displayName: displayName));
    testWidget = const ProfilePage();
    testWidgetBuild = MultiProvider(
      providers: [
        ChangeNotifierProvider<ApplicationState>.value(value: appState),
        ChangeNotifierProvider<PartnersInfoState>.value(
            value: partnersInfoState),
        ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
      ],
      builder: (context, _) => MaterialApp(home: testWidget),
    );
    when(appState.auth).thenReturn(auth);
    when(partnersInfoState.partnerExist).thenReturn(false);

    var authenticationInfo = MockAuthenticationInfo();
    when(authenticationInfo.providers).thenReturn([]);

    var appInfo = MockAppInfo();
    when(appInfo.appName).thenReturn("Test");

    when(appState.appInfo).thenReturn(appInfo);
    when(appState.loginState).thenReturn(ApplicationLoginState.loggedOut);
    when(appState.authenticationInfo).thenReturn(authenticationInfo);
  });

  testWidgets('username is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    expect(find.textContaining(displayName), findsOneWidget);
  });

  testWidgets('partners username is displayed', (WidgetTester tester) async {
    MockUserInformation partnerInfo = MockUserInformation();
    when(partnersInfoState.partnerExist).thenReturn(true);
    when(partnersInfoState.partnerPending).thenReturn(false);
    when(partnersInfoState.partnersInfo).thenReturn(partnerInfo);
    when(partnerInfo.displayName).thenReturn(partnerDisplayName);
    when(userInfoState.userPending).thenReturn(false);

    await tester.pumpWidget(testWidgetBuild);
    expect(find.textContaining(partnerDisplayName), findsOneWidget);
  });

  testWidgets('no partner username displays placeholder',
      (WidgetTester tester) async {
    when(partnersInfoState.partnerExist).thenReturn(true);
    when(partnersInfoState.partnerPending).thenReturn(false);
    when(partnersInfoState.partnersInfo).thenReturn(null);
    when(userInfoState.userPending).thenReturn(false);

    await tester.pumpWidget(testWidgetBuild);
    expect(find.textContaining(partnerNamePlaceholder), findsOneWidget);
  });

  testWidgets('displays unlink dialog', (WidgetTester tester) async {
    when(partnersInfoState.partnerExist).thenReturn(true);
    when(partnersInfoState.partnerPending).thenReturn(false);
    when(partnersInfoState.partnersInfo).thenReturn(null);
    when(partnersInfoState.linkCode).thenReturn('1');
    when(userInfoState.userPending).thenReturn(false);

    await tester.pumpWidget(testWidgetBuild);
    await tester.tap(find.text('Unlink Partner'));
    await tester.pumpAndSettle();
    expect(find.text(UnlinkAlertDialog.yesButtonText), findsOneWidget);
    expect(find.text(UnlinkAlertDialog.noButtonText), findsOneWidget);
  });

  testWidgets('sign out button signs out and navigates to sign in page',
      (WidgetTester tester) async {
    expect(auth.currentUser, isNotNull);

    await tester.pumpWidget(testWidgetBuild);
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(auth.currentUser, isNull);
    expect(find.byType(SignInPage), findsOneWidget);
  });

  testWidgets('sign in with email button shows email link sign in view',
      (WidgetTester tester) async {
    auth = MockFirebaseAuth(
        mockUser: MockUser(displayName: displayName, isAnonymous: true));
    when(appState.auth).thenReturn(auth);

    final authInfo = MockAuthenticationInfo();
    when(appState.authenticationInfo).thenReturn(authInfo);
    when(authInfo.providers).thenReturn([
      EmailLinkAuthProvider(actionCodeSettings: ActionCodeSettings(url: ''))
    ]);

    await auth.signInAnonymously();

    await tester.pumpWidget(testWidgetBuild);
    await tester.tap(find.text('Sign In With Email'));
    await tester.pumpAndSettle();

    expect(find.byType(EmailLinkSignInView), findsOneWidget);
  });

  testWidgets('settings button opens settings page',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
