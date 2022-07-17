import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar.dart';
import 'package:lovehue/models/relationship_bar_document.dart';
import 'package:lovehue/pages/your_bars_page.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

void main() {
  late MockApplicationState appState;
  late MockUserInfoState userInfoState;
  late MockPartnersInfoState partnersInfoState;
  late Widget testWidget;
  late Widget testWidgetBuild;

  setUp(() {
    appState = MockApplicationState();
    userInfoState = MockUserInfoState();
    partnersInfoState = MockPartnersInfoState();
    testWidget = const YourBars();
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
    when(userInfoState.barsChanged).thenReturn(false);
    when(userInfoState.barsReset).thenReturn(false);
  });

  group('displaying bars', () {
    testWidgets('users bars are displayed', (WidgetTester tester) async {
      List<RelationshipBar> bars = [];
      for (int i = 0; i < 5; i++) {
        bars.add(RelationshipBar(order: i, label: 'Bar_$i'));
      }

      RelationshipBarDocument barDoc = RelationshipBarDocument(
          id: '1',
          userID: '1234',
          barList: bars,
          firestore: FakeFirebaseFirestore());
      when(userInfoState.latestRelationshipBarDoc).thenReturn(barDoc);

      await tester.pumpWidget(testWidgetBuild);
      for (RelationshipBar bar in bars) {
        expect(find.textContaining(bar.label), findsOneWidget);
      }
    });

    testWidgets('loading indicator is displayed when user not logged in',
        (WidgetTester tester) async {
      when(appState.loginState).thenReturn(ApplicationLoginState.loggedOut);

      await tester.pumpWidget(testWidgetBuild);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading indicator is displayed when no user exists',
        (WidgetTester tester) async {
      when(userInfoState.userExist).thenReturn(false);

      await tester.pumpWidget(testWidgetBuild);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('cancel and save buttons', () {
    setUp(() {
      when(userInfoState.latestRelationshipBarDoc).thenReturn(
          RelationshipBarDocument(
              id: '1', userID: '1234', firestore: FakeFirebaseFirestore()));
      when(userInfoState.barsChanged).thenReturn(true);
    });

    testWidgets('buttons displayed when bars changed',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);

      expect(find.byType(FloatingActionButton), findsNWidgets(2));
    });

    testWidgets('buttons not displayed when user not logged in',
        (WidgetTester tester) async {
      when(appState.loginState).thenReturn(ApplicationLoginState.loggedOut);

      await tester.pumpWidget(testWidgetBuild);

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('buttons not displayed when no bar doc',
        (WidgetTester tester) async {
      when(userInfoState.latestRelationshipBarDoc).thenReturn(null);

      await tester.pumpWidget(testWidgetBuild);

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('buttons not displayed when bars not changed',
        (WidgetTester tester) async {
      when(userInfoState.barsChanged).thenReturn(false);

      await tester.pumpWidget(testWidgetBuild);

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('cancel button resets bars', (WidgetTester tester) async {
      when(userInfoState.userID).thenReturn(null);

      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byTooltip('Cancel'));

      verify(userInfoState.resetBarChange());
    });

    testWidgets('save button saves bars', (WidgetTester tester) async {
      when(userInfoState.saveBars()).thenAnswer((_) async {});
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byTooltip('Save'));

      verify(userInfoState.saveBars());
    });
  });
}
