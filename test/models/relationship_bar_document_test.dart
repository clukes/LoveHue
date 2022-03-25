import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar.dart';
import 'package:lovehue/models/relationship_bar_document.dart';

void main() {
  const String userID = '1234';
  const String barDocID = '6789';

  late List<RelationshipBar> bars;
  late FakeFirebaseFirestore firestore;
  late RelationshipBarDocument barDocument;

  setUp(() {
    bars = [RelationshipBar(label: '1', order: 1, changed: true), RelationshipBar(label: '2', order: 2, changed: true)];
    firestore = FakeFirebaseFirestore();
    barDocument = RelationshipBarDocument(
        barList: bars, id: barDocID, userID: userID, firestore: firestore, timestamp: Timestamp.now());
  });

  group('resetBarsChanged', () {
    test('all bars in list changed is false', () {
      barDocument.resetBarsChanged();
      expect(barDocument.barList, isNotNull);
      for (var element in barDocument.barList!) {
        expect(element.changed, isFalse);
      }
    });
  });

  group('resetBars', () {
    test('barList should match bars in database', () async {
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID).set(barDocument);

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
      Map<String, Object?> map = {'id': barDocID};
      RelationshipBarDocument result = RelationshipBarDocument.fromMap(map, userID, firestore);
      expect(result.id, equals(barDocument.id));
      expect(result.userID, equals(barDocument.userID));
    });
  });

  group('toMap', () {
    test('valid RelationshipBarDocument should return map', () {
      Map<String, Object?> expected = {'id': barDocID};
      Map<String, Object?> result = barDocument.toMap();
      expect(result['id'], equals(expected['id']));
    });
  });

  group('firestoreGet', () {
    test('should get correct barDoc', () async {
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID).set(barDocument);
      RelationshipBarDocument? result = await barDocument.firestoreGet();

      expect(result, isNotNull);
      expect(result!.id, equals(barDocument.id));
    });
  });

  group('firestoreGetLatest', () {
    test('should get barDoc with greatest timestamp', () async {
      String expectedID = '4321';

      barDocument.timestamp = Timestamp.fromMillisecondsSinceEpoch(10000);
      RelationshipBarDocument expected = RelationshipBarDocument(
          barList: bars,
          timestamp: Timestamp.fromMillisecondsSinceEpoch(20000),
          id: expectedID,
          firestore: firestore,
          userID: userID);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID).set(barDocument);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(expectedID).set(expected);
      RelationshipBarDocument? result = await RelationshipBarDocument.firestoreGetLatest(userID, firestore);

      expect(result, isNotNull);
      expect(result!.id, equals(expected.id));
    });
  });

  group('firestoreGetAll', () {
    test('should get all barDocs', () async {
      String barDocID2 = '4321';
      barDocument.timestamp = Timestamp.fromMillisecondsSinceEpoch(10000);
      RelationshipBarDocument barDocument2 = RelationshipBarDocument(
          barList: bars,
          timestamp: Timestamp.fromMillisecondsSinceEpoch(20000),
          id: barDocID2,
          firestore: firestore,
          userID: userID);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID).set(barDocument);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID2).set(barDocument2);
      List<RelationshipBarDocument> expected = [barDocument, barDocument2];
      List<RelationshipBarDocument?> result = await RelationshipBarDocument.firestoreGetAll(userID, firestore);

      for (int i = 0; i < expected.length; i++) {
        expect(result[i], isNotNull);
        expect(result[i]!.id, equals(expected[i].id));
      }
    });

    test('no barDocs returns empty list', () async {
      List<RelationshipBarDocument?> result = await RelationshipBarDocument.firestoreGetAll(userID, firestore);

      expect(result, isEmpty);
    });
  });

  group('firestoreSet', () {
    test('should create new barDoc in database if not exist', () async {
      await barDocument.firestoreSet();
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc(barDocID)
          .get()
          .then((value) => value.data());
      expect(result, isNotNull);
      expect(barDocument.id, equals(result!.id));
    });

    test('should update barDoc in database if exist', () async {
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID).set(barDocument);
      barDocument.timestamp = Timestamp.fromMillisecondsSinceEpoch(100);
      await barDocument.firestoreSet();
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc(barDocID)
          .get()
          .then((value) => value.data());
      expect(result, isNotNull);
      expect(barDocument.id, equals(result!.id));
      expect(barDocument.timestamp, equals(result.timestamp));
    });
  });

  group('firestoreSetList', () {
    test('should add each barDoc in list to database', () async {
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
    test('should update barDoc in database', () async {
      Timestamp expectedTimestamp = Timestamp.fromMillisecondsSinceEpoch(20000);
      barDocument.timestamp = Timestamp.fromMillisecondsSinceEpoch(10000);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID).set(barDocument);
      await barDocument.firestoreUpdateColumns({RelationshipBarDocument.columnTimestamp: expectedTimestamp});
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc(barDocID)
          .get()
          .then((value) => value.data());
      expect(result, isNotNull);
      expect(result!.id, equals(barDocument.id));
      expect(result.timestamp, equals(expectedTimestamp));
    });
  });

  group('firestoreDelete', () {
    test('should remove barDoc from database', () async {
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc(barDocID).set(barDocument);
      await barDocument.firestoreDelete();
      RelationshipBarDocument? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc(barDocID)
          .get()
          .then((value) => value.data());
      expect(result, isNull);
    });
  });

  group('firestoreAddBarList', () {
    test('adds barDoc with barList to database', () async {
      RelationshipBarDocument newBarDoc = await RelationshipBarDocument.firestoreAddBarList(userID, bars, firestore);
      List<RelationshipBar>? result = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .doc(newBarDoc.id)
          .get()
          .then((value) => value.data()?.barList);
      expect(result, isNotNull);
      for (int i = 0; i < bars.length; i++) {
        expect(result![i].label, equals(bars[i].label));
        expect(result[i].order, equals(bars[i].order));
      }
    });
  });
}
