import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar.dart';
import 'package:lovehue/models/relationship_bar_document.dart';
import 'package:lovehue/pages/partners_bars_page.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

void main() {
  const partnersName = 'TEST_NAME';
  const partnerID = '1234';

  late MockUserInfoState userInfoState;
  late MockPartnersInfoState partnersInfoState;
  late MockApplicationState applicationState;
  late FakeFirebaseFirestore firestore;
  late Widget testWidget;
  late Widget testWidgetBuild;
  late ValueNotifier<String> partnersNameValueNotifier;

  setUp(() {
    userInfoState = MockUserInfoState();
    partnersInfoState = MockPartnersInfoState();
    applicationState = MockApplicationState();
    firestore = FakeFirebaseFirestore();
    testWidget = PartnersBars(
      firestore: firestore,
    );
    testWidgetBuild = MaterialApp(
        home: MultiProvider(
      providers: [
        ChangeNotifierProvider<ApplicationState>.value(value: applicationState),
        ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
        ChangeNotifierProvider<PartnersInfoState>.value(
            value: partnersInfoState),
      ],
      child: testWidget,
    ));

    partnersNameValueNotifier = ValueNotifier('TEST_NAME');

    when(userInfoState.partnerLinked).thenReturn(true);
    when(userInfoState.userPending).thenReturn(true);
    when(partnersInfoState.partnersInfo).thenReturn(null);
    when(partnersInfoState.partnersID).thenReturn(partnerID);
    when(partnersInfoState.partnersName).thenReturn(partnersNameValueNotifier);
    when(partnersInfoState.linkCode).thenReturn(null);
    when(userInfoState.linkCode).thenReturn(null);
    when(applicationState.canSendNudgeNotification()).thenReturn(false);
  });

  group('partners name', () {
    testWidgets('partners name is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      expect(find.textContaining(partnersName), findsOneWidget);
    });

    testWidgets('partners name is updated', (WidgetTester tester) async {
      const partnersChangedName = 'NEW_TEST_NAME';

      await tester.pumpWidget(testWidgetBuild);
      expect(find.textContaining(partnersName), findsOneWidget);
      expect(find.textContaining(partnersChangedName), findsNothing);

      partnersNameValueNotifier.value = partnersChangedName;
      await tester.pump();
      await expectLater(
          find.textContaining(partnersChangedName), findsOneWidget);
    });
  });

  group('partners bars', () {
    testWidgets('partners bars are displayed', (WidgetTester tester) async {
      List<RelationshipBar> bars = [];
      for (int i = 0; i < 5; i++) {
        bars.add(RelationshipBar(order: i, label: 'Bar_$i'));
      }

      RelationshipBarDocument barDoc = RelationshipBarDocument(
          id: '1', userID: partnerID, barList: bars, firestore: firestore);
      await RelationshipBarDocument.getUserBarsFromID(partnerID, firestore)
          .doc(barDoc.id)
          .set(barDoc);

      await tester.pumpWidget(testWidgetBuild);
      await tester.pumpAndSettle();
      for (RelationshipBar bar in bars) {
        expect(find.textContaining(bar.label), findsOneWidget);
      }
    });
  });

  group('nudge button', () {
    testWidgets('if partner not linked then nudge button not displayed',
        (WidgetTester tester) async {
      when(userInfoState.partnerLinked).thenReturn(false);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byTooltip('Nudge'), findsNothing);
    });

    testWidgets(
        'if cant send nudge notification then nudge button not displayed',
        (WidgetTester tester) async {
      when(applicationState.canSendNudgeNotification()).thenReturn(false);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byTooltip('Nudge'), findsNothing);
      verify(applicationState.canSendNudgeNotification());
    });

    testWidgets('nudge button is displayed', (WidgetTester tester) async {
      when(applicationState.canSendNudgeNotification()).thenReturn(true);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byTooltip('Nudge'), findsOneWidget);
      verify(applicationState.canSendNudgeNotification());
    });

    testWidgets('nudge button is displayed', (WidgetTester tester) async {
      when(applicationState.canSendNudgeNotification()).thenReturn(true);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byTooltip('Nudge'), findsOneWidget);
      verify(applicationState.canSendNudgeNotification());
    });

    testWidgets('nudge button pressed calls sendNudgeNotification',
        (WidgetTester tester) async {
      when(applicationState.canSendNudgeNotification()).thenReturn(true);

      await tester.pumpWidget(testWidgetBuild);

      expect(find.byTooltip('Nudge'), findsOneWidget);
      await tester.tap(find.byTooltip('Nudge'));

      verify(applicationState.canSendNudgeNotification());
      verify(applicationState.sendNudgeNotification());
    });
  });
}
