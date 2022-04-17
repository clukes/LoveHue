import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar.dart';
import 'package:lovehue/models/relationship_bar_document.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/data_formatting.dart';
import 'package:lovehue/widgets/bar_builders.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

void main() {
  group('BarDocBuilder', () {
    const findText = 'BAR_FIND_TEST_';

    Widget barBuilder(BuildContext context, RelationshipBar bar) {
      return Text(findText + bar.label, key: Key(bar.label));
    }

    testWidgets('null bar doc displays loading', (WidgetTester tester) async {
      final testWidget = BarDocBuilder(itemBuilderFunction: barBuilder);
      final testWidgetBuild = MaterialApp(home: testWidget);

      await tester.pumpWidget(testWidgetBuild);
      expect(find.text(findText), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('bars in bar doc list are displayed', (WidgetTester tester) async {
      List<RelationshipBar> bars = [];
      for (int i = 0; i < 5; i++) {
        bars.add(RelationshipBar(order: i, label: 'Bar_$i'));
      }

      final barDoc =
          RelationshipBarDocument(id: '1', barList: bars, firestore: FakeFirebaseFirestore(), userID: '1234');
      final testWidget = BarDocBuilder(itemBuilderFunction: barBuilder, barDoc: barDoc);
      final testWidgetBuild = MaterialApp(home: testWidget);

      await tester.pumpWidget(testWidgetBuild);
      for (RelationshipBar bar in bars) {
        expect(find.text(findText + bar.label), findsOneWidget);
      }
    });

    testWidgets('timestamp is displayed', (WidgetTester tester) async {
      final Timestamp timestamp = Timestamp.now();
      final barDoc =
          RelationshipBarDocument(id: '1', timestamp: timestamp, firestore: FakeFirebaseFirestore(), userID: '1234');
      final testWidget = BarDocBuilder(itemBuilderFunction: barBuilder, barDoc: barDoc);
      final testWidgetBuild = MaterialApp(home: testWidget);

      await tester.pumpWidget(testWidgetBuild);
      expect(find.textContaining(formatTimestamp(timestamp)), findsOneWidget);
    });
  });

  group('interactableBarBuilder', () {
    testWidgets('sets bar reset to false', (WidgetTester tester) async {
      UserInfoState userInfoState = UserInfoState(FakeFirebaseFirestore(), MockPartnersInfoState());
      RelationshipBar bar = RelationshipBar(order: 1, label: '1');
      userInfoState.barsReset = true;

      final testWidgetBuild = MaterialApp(
          home: ChangeNotifierProvider<UserInfoState>.value(
              value: userInfoState, child: Builder(builder: (context) => interactableBarBuilder(context, bar))));

      await tester.pumpWidget(testWidgetBuild);
      expect(userInfoState.barsReset, isFalse);
    });
  });

  group('buildBars', () {
    testWidgets('displays error on snapshot error', (WidgetTester tester) async {
      const errorString = 'ERROR_TEST';
      const AsyncSnapshot<QuerySnapshot<RelationshipBarDocument>> snapshot =
          AsyncSnapshot.withError(ConnectionState.done, errorString);
      final Widget testWidget = buildBars(MockBuildContext(), snapshot, nonInteractableBarBuilder);

      final testWidgetBuild = MaterialApp(home: testWidget);

      await tester.pumpWidget(testWidgetBuild);
      expect(find.text(errorString), findsOneWidget);
    });

    testWidgets('displays no bars message on no data', (WidgetTester tester) async {
      const AsyncSnapshot<QuerySnapshot<RelationshipBarDocument>> snapshot = AsyncSnapshot.nothing();
      final Widget testWidget = buildBars(MockBuildContext(), snapshot, nonInteractableBarBuilder);

      final testWidgetBuild = MaterialApp(home: testWidget);

      await tester.pumpWidget(testWidgetBuild);
      expect(find.textContaining("No bars found"), findsOneWidget);
    });

    testWidgets('displays latest barDoc', (WidgetTester tester) async {
      const userID = '1234';
      final Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(2000);
      final firestore = FakeFirebaseFirestore();
      final RelationshipBarDocument barDoc1 =
          RelationshipBarDocument(id: '1', timestamp: timestamp, firestore: firestore, userID: userID);
      final RelationshipBarDocument barDoc2 = RelationshipBarDocument(
          id: '2', timestamp: Timestamp.fromMillisecondsSinceEpoch(1000), firestore: firestore, userID: userID);
      final collection = RelationshipBarDocument.getUserBarsFromID(userID, firestore);
      await collection.add(barDoc1);
      await collection.add(barDoc2);
      QuerySnapshot<RelationshipBarDocument> querySnapshot = await collection.get();

      final AsyncSnapshot<QuerySnapshot<RelationshipBarDocument>> snapshot =
          AsyncSnapshot.withData(ConnectionState.done, querySnapshot);
      final Widget testWidget = buildBars(MockBuildContext(), snapshot, nonInteractableBarBuilder);

      final testWidgetBuild = MaterialApp(home: testWidget);

      await tester.pumpWidget(testWidgetBuild);
      expect(find.textContaining(formatTimestamp(timestamp)), findsOneWidget);
    });
  });
}
