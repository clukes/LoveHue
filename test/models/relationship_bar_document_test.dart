import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar.dart';
import 'package:lovehue/models/relationship_bar_document.dart';

void main() {
  setUp(() {});
  tearDown(() {});


  group('resetBarsChanged', () {
    test('all bars in list changed is false', () {
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument barDocument = RelationshipBarDocument(
          barList: bars, id: '1', userID: '1234', firestore: FakeFirebaseFirestore());
      barDocument.resetBarsChanged();
      expect(barDocument.barList, isNotNull);
      for (var element in barDocument.barList!) {
        expect(element.changed, isFalse);
      }
    });
  });

  group('resetBars', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('barList should match bars in database', () async {
      String userID = '1234';
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument barDocument = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.now(), userID: userID,  id: '1', firestore: firestore);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument);

      barDocument.barList = null;
      await barDocument.resetBars(userID);
      List<RelationshipBar>? result = barDocument.barList;
      expect(barDocument.barList, isNotNull);
      for (int i = 0; i < bars.length; i++) {
        expect(result![i].label, equals(bars[i].label));
        expect(result[i].order, equals(bars[i].order));
      }
    });
  });

  group('fromMap', () {
    test('valid map should return RelationshipBarDocument', () {
      FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      RelationshipBarDocument expected = RelationshipBarDocument(id: '6789', userID: '1234', firestore: firestore);
      Map<String, Object?> map = {'id': '6789'};
      RelationshipBarDocument result = RelationshipBarDocument.fromMap(map, '1234', firestore);
      expect(result.id, equals(expected.id));
      expect(result.userID, equals(expected.userID));
    });
  });

  group('toMap', () {
    test('valid RelationshipBarDocument should return map', () {
      FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      Map<String, Object?> expected = {'id': '6789'};
      RelationshipBarDocument barDoc = RelationshipBarDocument(id: '6789', userID: '1234', firestore: firestore);
      Map<String, Object?> result = barDoc.toMap();
      expect(result['id'], equals(expected['id']));
    });
  });

  group('firestoreGet', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should get correct barDoc', () async {
      String userID = '1234';
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument barDocument = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.now(), id: '1', firestore: firestore, userID: '1234');
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument);
      RelationshipBarDocument? result = await barDocument.firestoreGet();

      expect(result, isNotNull);
      expect(result!.id, equals(barDocument.id));
    });
  });

  group('firestoreGetLatest', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should get barDoc with greatest timestamp', () async {
      String userID = '1234';
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument barDocument = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(10000), id: '1', firestore: firestore, userID: userID);
      RelationshipBarDocument expected = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(20000), id: '2', firestore: firestore, userID: userID);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('2').set(expected);
      RelationshipBarDocument? result = await RelationshipBarDocument.firestoreGetLatest(userID, firestore);

      expect(result, isNotNull);
      expect(result!.id, equals(expected.id));
    });
  });


  group('firestoreGetAll', () {
    test('should get barDoc with greatest timestamp', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      String userID = '1234';
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument barDocument1 = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(10000), id: '1', firestore: firestore, userID: userID);
      RelationshipBarDocument barDocument2 = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(20000), id: '2', firestore: firestore, userID: userID);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument1);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('2').set(barDocument2);
      List<RelationshipBarDocument> expected = [barDocument1, barDocument2];
      List<RelationshipBarDocument?> result = await RelationshipBarDocument.firestoreGetAll(userID, firestore);

      for (int i = 0; i < expected.length; i++) {
        expect(result[i], isNotNull);
        expect(result[i]!.id, equals(expected[i].id));
      }
    });

    test('no barDocs returns empty list', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      String userID = '1234';
      List<RelationshipBarDocument?> result = await RelationshipBarDocument.firestoreGetAll(userID, firestore);

      expect(result, isEmpty);
    });
  });

  group('firestoreSet', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should create new barDoc in database if not exist', () async {
      String userID = '1234';
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument expected = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(10000), id: '1289', firestore: firestore, userID: userID);
      await expected.firestoreSet();
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc('1289')
          .get()
          .then((value) => value.data());
      expect(result, isNotNull);
      expect(expected.id, equals(result!.id));
    });

    test('should update barDoc in database if exist', () async {
      String userID = '1234';
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument expected = RelationshipBarDocument(
          barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(10000), id: '1289', firestore: firestore, userID: userID);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1289').set(expected);
      expected.timestamp = Timestamp.fromMillisecondsSinceEpoch(100);
      await expected.firestoreSet();
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc('1289')
          .get()
          .then((value) => value.data());
      expect(result, isNotNull);
      expect(expected.id, equals(result!.id));
      expect(expected.timestamp, equals(result.timestamp));
    });
  });

  group('firestoreSetList', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should add each barDoc in list to database', () async {
      String userID = '1234';
      List<RelationshipBarDocument> expected = [
        RelationshipBarDocument(id: '1', firestore: firestore, userID: userID),
        RelationshipBarDocument(id: '2', firestore: firestore, userID: userID),
      ];
      await RelationshipBarDocument.firestoreSetList(userID, expected, firestore);
      List<RelationshipBarDocument?> result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .get()
          .then((value) => value.docs.map((element) => element.data()).toList());

      for (int i = 0; i < expected.length; i++) {
        expect(result[i], isNotNull);
        expect(result[i]!.id, equals(expected[i].id));
      }
    });
  });

  group('firestoreUpdateColumns', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should update barDoc in database', () async {
      String userID = '1234';
      Timestamp expectedTimestamp = Timestamp.fromMillisecondsSinceEpoch(20000);
      RelationshipBarDocument expected = RelationshipBarDocument(
          timestamp: Timestamp.fromMillisecondsSinceEpoch(10000), id: '1', firestore: firestore, userID: userID);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc('1')
          .set(expected);
      await expected.firestoreUpdateColumns({RelationshipBarDocument.columnTimestamp: expectedTimestamp});
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc('1')
          .get()
          .then((value) => value.data());
      expect(result, isNotNull);
      expect(result!.id, equals(expected.id));
      expect(result.timestamp, equals(expectedTimestamp));
    });
  });

  group('firestoreDelete', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should remove barDoc from database', () async {
      String userID = '1234';
      RelationshipBarDocument barDocument = RelationshipBarDocument(
          id: '1', firestore: firestore, userID: userID);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument);
      await barDocument.firestoreDelete();
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc('1')
          .get()
          .then((value) => value.data());
      expect(result, isNull);
    });
  });

  group('firestoreAddBarList', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('adds barDoc with barList to database', () async {
      String userID = '1234';
      List<RelationshipBar> barList = [
        RelationshipBar(label: '1', order: 1, changed: true),
        RelationshipBar(label: '2', order: 2, changed: true)
      ];
      RelationshipBarDocument newBarDoc = await RelationshipBarDocument.firestoreAddBarList(userID, barList, firestore);
      List<RelationshipBar>? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc(newBarDoc.id)
          .get()
          .then((value) => value.data()?.barList);
      expect(result, isNotNull);
      for(int i = 0; i < barList.length; i++) {
        expect(result![i].label, equals(barList[i].label));
        expect(result[i].order, equals(barList[i].order));
      }
    });
  });
}