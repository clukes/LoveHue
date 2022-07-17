import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/pages/partners_bars_page.dart';
import 'package:lovehue/pages/profile_page.dart';
import 'package:lovehue/pages/your_bars_page.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/responsive/screen_layout.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

class TestScreenLayout {
  static void testNavigation(ScreenLayout testWidget) {
    late MaterialApp testWidgetBuild;

    setUp(() {
      var appState = MockApplicationState();
      var userInfoState = MockUserInfoState();
      var partnersInfoState = MockPartnersInfoState();

      testWidgetBuild = MaterialApp(
          home: MultiProvider(
        providers: [
          ChangeNotifierProvider<ApplicationState>.value(value: appState),
          ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
          ChangeNotifierProvider<PartnersInfoState>.value(
              value: partnersInfoState),
        ],
        child: testWidget,
      ));
      when(appState.loginState).thenReturn(ApplicationLoginState.loggedIn);
      when(userInfoState.userExist).thenReturn(true);
      when(userInfoState.latestRelationshipBarDoc).thenReturn(null);
      when(partnersInfoState.partnersName).thenReturn(ValueNotifier(""));
      when(appState.auth).thenReturn(MockFirebaseAuth());
      when(userInfoState.partnerLinked).thenReturn(false);
      when(partnersInfoState.partnerExist).thenReturn(false);
      when(userInfoState.userPending).thenReturn(false);
      when(partnersInfoState.partnerPending).thenReturn(false);
      when(userInfoState.linkCode).thenReturn(null);
    });

    testWidgets('can navigate to YourBars page', (WidgetTester tester) async {
      _testPage(YourBars, Icons.person, tester, testWidget, testWidgetBuild);
    });

    testWidgets('can navigate to PartnerBars page',
        (WidgetTester tester) async {
      _testPage(
          PartnersBars, Icons.favorite, tester, testWidget, testWidgetBuild);
    });

    testWidgets('can navigate to Profile page', (WidgetTester tester) async {
      _testPage(ProfilePage, Icons.manage_accounts, tester, testWidget,
          testWidgetBuild);
    });
  }

  static void _testPage(Type pageType, IconData icon, WidgetTester tester,
      Widget testWidget, Widget testWidgetBuild) async {
    var navItemFinder = find.byIcon(icon);

    await tester.pumpWidget(testWidgetBuild);
    expect(find.byWidget(testWidget), findsOneWidget);
    expect(navItemFinder, findsOneWidget);

    await tester.tap(navItemFinder);
    await tester.pump();

    expect(find.byType(pageType), findsOneWidget);
  }
}
