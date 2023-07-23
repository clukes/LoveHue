import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/services/database_service.dart';

class MockMappable extends Mappable {
  final String testField;
  final int? testMergeField;

  MockMappable(this.testField, {this.testMergeField});

  @override
  Map<String, Object?> toMap() {
    return {"testField": testField, "testMergeField": testMergeField};
  }

  @override
  Map<String, Object> toMapIgnoreNulls() {
    return {"testField": testField};
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late DatabaseService subject;
  setUp(() {
    firestore = FakeFirebaseFirestore();
    subject = DatabaseService(firestore);
  });

  test('saveAsync sets data', () async {
    const String docPath = "test/testDoc";
    const testKey = "test";
    const testValue = 1234;

    // Act
    subject.saveAsync(docPath, {testKey: testValue});

    var stored = await firestore.doc(docPath).get();
    expect(stored.get(testKey), equals(testValue));
  });

  test('saveObjectAsync saves object', () async {
    const String docPath = "test/testMappable";
    const testField = "TEST";
    final mappable = MockMappable(testField);

    // Act
    subject.writeObjectAsync<MockMappable>(docPath, mappable);

    var stored = await firestore.doc(docPath).get();
    expect(stored.get("testField"), equals(testField));
    expect(stored.get("testMergeField"), isNull);
  });

  test('saveObjectAsync with merge updates fields', () async {
    const String docPath = "test/testMappable";
    const testField = "TEST";
    const testMergeField = 12345;

    final mappable = MockMappable(testField, testMergeField: testMergeField);
    subject.writeObjectAsync(docPath, mappable);
    var stored = await firestore.doc(docPath).get();
    expect(stored.get("testField"), equals(testField));
    expect(stored.get("testMergeField"), equals(testMergeField));

    const updatedTestField = "UPDATEDTEST";
    final mappableUpdate = MockMappable(updatedTestField);
    // Act
    subject.mergeObjectAsync(docPath, mappableUpdate);

    var storedUpdate = await firestore.doc(docPath).get();
    expect(storedUpdate.get("testField"), equals(updatedTestField));
    expect(storedUpdate.get("testMergeField"), equals(testMergeField));
  });
}
