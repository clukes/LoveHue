import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar_model.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([])
void main() {
  relationshipBar();
  relationshipBarDocument();
}

void relationshipBar() {
  setUp(() {});
  tearDown(() {});


  group('setValue', () {
    test('new value changes prev value and sets changed', () {
      RelationshipBar bar = RelationshipBar(label: '1',
          order: 1,
          prevValue: 100,
          value: 75,
          changed: false);
      bar.setValue(60);
      expect(bar.prevValue, equals(75));
      expect(bar.changed, isTrue);
    });

    test("same value doesn't change prev value or set changed", () {
      RelationshipBar bar = RelationshipBar(label: '1',
          order: 1,
          prevValue: 100,
          value: 75,
          changed: false);
      bar.setValue(75);
      expect(bar.prevValue, equals(100));
      expect(bar.changed, isFalse);
    });
  });

  group('resetValue', () {
    test('resetValue sets changed to false and value to prevValue', () {
      RelationshipBar bar = RelationshipBar(label: '1',
          order: 1,
          prevValue: 100,
          value: 75,
          changed: true);
      bar.resetValue();
      expect(bar.value, equals(100));
      expect(bar.changed, isFalse);
    });
  });

  group('fromMap', () {
    test('valid map should return RelationshipBar', () {
      RelationshipBar expected = RelationshipBar(label: '1',
          order: 1);
      Map<String, Object?> map = {'label': '1', 'order': 1};
      RelationshipBar result = RelationshipBar.fromMap(map);
      expect(result.label, equals(expected.label));
      expect(result.order, equals(expected.order));
    });
  });

  group('toMap', () {
    test('valid RelationshipBar should return map', () {
      Map<String, Object?> expected = {'label': '1', 'order': 1};
      RelationshipBar bar = RelationshipBar(label: '1',
          order: 1);
      Map<String, Object?> result = bar.toMap();
      expect(result['label'], equals(expected['label']));
      expect(result['order'], equals(expected['order']));
    });
  });

  group('toMapList', () {
    test('valid RelationshipBars should return map list', () {
      List<Map<String, Object?>> expected = [{'label': '1', 'order': 1}, {'label': '2', 'order': 2}];
      List<RelationshipBar> bars = [RelationshipBar(label: '1', order: 1), RelationshipBar(label: '2', order: 2)];
      List<Map<String, Object?>>? result = RelationshipBar.toMapList(bars);
      expect(result, isNotNull);
      for(int i = 0; i < bars.length; i++) {
        expect(result![i]['label'], equals(expected[i]['label']));
        expect(result[i]['order'], equals(expected[i]['order']));
      }
    });
  });

  group('fromMapList', () {
    test('valid map should return RelationshipBar list', () {
      List<RelationshipBar> expected = [RelationshipBar(label: '1', order: 1), RelationshipBar(label: '2', order: 2)];
      List<Map<String, Object?>> maps = [{'label': '1', 'order': 1}, {'label': '2', 'order': 2}];
      List<RelationshipBar>? result = RelationshipBar.fromMapList(maps);
      for(int i = 0; i < maps.length; i++) {
        expect(result![i].label, equals(expected[i].label));
        expect(result[i].order, equals(expected[i].order));
      }
    });
  });

  group('listFromLabels', () {
    test('valid labels should return RelationshipBar list', () {
      List<String> labels = ['1', '2', '3'];
      List<RelationshipBar> result = RelationshipBar.listFromLabels(labels);
      expect(result.map((element) => element.label), orderedEquals(labels));
    });
  });
}



void relationshipBarDocument() {
  setUp(() {});
  tearDown(() {});


  group('resetBarsChanged', () {
    test('all bars in list changed is false', () {
      List<RelationshipBar> bars = [RelationshipBar(label: '1', order: 1, changed: true), RelationshipBar(label: '2', order: 2, changed: true)];
      RelationshipBarDocument barDocument = RelationshipBarDocument(barList: bars, id: '1', firestore: FakeFirebaseFirestore());
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
      List<RelationshipBar> bars = [RelationshipBar(label: '1', order: 1, changed: true), RelationshipBar(label: '2', order: 2, changed: true)];
      RelationshipBarDocument barDocument = RelationshipBarDocument(barList: bars, timestamp: Timestamp.now(), id: '1', firestore: firestore);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument);

      barDocument.barList = null;
      await barDocument.resetBars(userID);
      List<RelationshipBar>? result = barDocument.barList;
      expect(barDocument.barList, isNotNull);
      for(int i = 0; i < bars.length; i++) {
        expect(result![i].label, equals(bars[i].label));
        expect(result[i].order, equals(bars[i].order));
      }
    });
  });

  group('fromMap', () {
    test('valid map should return RelationshipBarDocument', () {
      FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      RelationshipBarDocument expected = RelationshipBarDocument(id: '1234', firestore: firestore);
      Map<String, Object?> map = {'id': '1234'};
      RelationshipBarDocument result = RelationshipBarDocument.fromMap(map, firestore);
      expect(result.id, equals(expected.id));
    });
  });

  group('toMap', () {
    test('valid RelationshipBarDocument should return map', () {
      FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      Map<String, Object?> expected = {'id': '1234'};
      RelationshipBarDocument barDoc = RelationshipBarDocument(id: '1234', firestore: firestore);
      Map<String, Object?> result = barDoc.toMap();
      expect(result['id'], equals(expected['id']));
    });
  });

  group('firestoreGet', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should get correct barDoc', () async {
      String userID = '1234';
      List<RelationshipBar> bars = [RelationshipBar(label: '1', order: 1, changed: true), RelationshipBar(label: '2', order: 2, changed: true)];
      RelationshipBarDocument barDocument = RelationshipBarDocument(barList: bars, timestamp: Timestamp.now(), id: '1', firestore: firestore);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument);
      RelationshipBarDocument? result = await barDocument.firestoreGet(userID);

      expect(result, isNotNull);
      expect(result!.id, equals(barDocument.id));
    });
  });

  group('firestoreGetLatest', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('should get barDoc with greatest timestamp', () async {
      String userID = '1234';
      List<RelationshipBar> bars = [RelationshipBar(label: '1', order: 1, changed: true), RelationshipBar(label: '2', order: 2, changed: true)];
      RelationshipBarDocument barDocument = RelationshipBarDocument(barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(10000), id: '1', firestore: firestore);
      RelationshipBarDocument expected = RelationshipBarDocument(barList: bars, timestamp: Timestamp.fromMillisecondsSinceEpoch(20000), id: '2', firestore: firestore);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('1').set(barDocument);
      await RelationshipBarDocument.getUserBarsFromID(userID, firestore).doc('2').set(expected);
      RelationshipBarDocument? result = await RelationshipBarDocument.firestoreGetLatest(userID, firestore);

      expect(result, isNotNull);
      expect(result!.id, equals(expected.id));
    });
  });



}
