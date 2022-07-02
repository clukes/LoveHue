import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar.dart';

void main() {
  late RelationshipBar bar;

  setUp(() {
    bar = RelationshipBar(
        label: '1', order: 1, prevValue: 100, value: 75, changed: false);
  });

  group('setValue', () {
    test('new value changes prev value and sets changed', () {
      bar.setValue(60);
      expect(bar.prevValue, equals(75));
      expect(bar.changed, isTrue);
    });

    test("same value doesn't change prev value or set changed", () {
      bar.setValue(75);
      expect(bar.prevValue, equals(100));
      expect(bar.changed, isFalse);
    });
  });

  group('resetValue', () {
    test('resetValue sets changed to false and value to prevValue', () {
      bar.changed = true;

      bar.resetValue();
      expect(bar.value, equals(100));
      expect(bar.changed, isFalse);
    });
  });

  group('fromMap', () {
    test('valid map should return RelationshipBar', () {
      Map<String, Object?> map = {'label': '1', 'order': 1};
      RelationshipBar result = RelationshipBar.fromMap(map);
      expect(result.label, equals(bar.label));
      expect(result.order, equals(bar.order));
    });
  });

  group('toMap', () {
    test('valid RelationshipBar should return map', () {
      Map<String, Object?> expected = {'label': '1', 'order': 1};

      Map<String, Object?> result = bar.toMap();
      expect(result['label'], equals(expected['label']));
      expect(result['order'], equals(expected['order']));
    });
  });

  group('toMapList', () {
    test('valid RelationshipBars should return map list', () {
      List<Map<String, Object?>> expected = [
        {'label': '1', 'order': 1},
        {'label': '2', 'order': 2}
      ];
      List<RelationshipBar> bars = [
        RelationshipBar(label: '1', order: 1),
        RelationshipBar(label: '2', order: 2)
      ];
      List<Map<String, Object?>>? result = RelationshipBar.toMapList(bars);
      expect(result, isNotNull);
      for (int i = 0; i < bars.length; i++) {
        expect(result![i]['label'], equals(expected[i]['label']));
        expect(result[i]['order'], equals(expected[i]['order']));
      }
    });
  });

  group('fromMapList', () {
    test('valid map should return RelationshipBar list', () {
      List<RelationshipBar> expected = [
        RelationshipBar(label: '1', order: 1),
        RelationshipBar(label: '2', order: 2)
      ];
      List<Map<String, Object?>> maps = [
        {'label': '1', 'order': 1},
        {'label': '2', 'order': 2}
      ];
      List<RelationshipBar>? result = RelationshipBar.fromMapList(maps);
      for (int i = 0; i < maps.length; i++) {
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
