import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/services/database_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late DatabaseService subject;
  const String docPath = "test/testDoc";
  setUp(() {
    firestore = FakeFirebaseFirestore();
    subject = DatabaseService(firestore);
  });

  test('saveAsync sets data', () async {
    const testKey = "test";
    const testValue = 1234;

    // Act
    subject.saveAsync(docPath, {testKey: testValue});

    var stored = await firestore.doc(docPath).get();
    expect(stored.get(testKey), equals(testValue));
  });

  test('saveTimestampAsync sets timestamp', () async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    const timestampKey = "timestamp";

    // Act
    subject.saveTimestampAsync(docPath, timestampKey, timestamp);

    var stored = await firestore.doc(docPath).get();
    Timestamp storedTimestamp = stored.get(timestampKey);
    expect(storedTimestamp.millisecondsSinceEpoch, equals(timestamp));
  });
}
