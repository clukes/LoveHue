//TODO

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/resources/delete_firestore_collection.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CollectionReference collection;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    collection = firestore.collection('collection');
  });

  test('deletes all documents in a collection', () async {
    WriteBatch batch = firestore.batch();
    for (int i = 0; i < 500; i++) {
      batch.set(collection.doc('$i'), {'id': i});
    }
    await batch.commit();
    for (int i = 500; i < 1000; i++) {
      batch.set(collection.doc('$i'), {'id': i});
    }
    await batch.commit();
    expect(await collection.get().then((value) => value.docs.length), greaterThan(0));
    await deleteCollection(collection, firestore: firestore);
  });

  test('no expection thrown if collection is empty', () async {
    expect(await collection.get().then((value) => value.docs.length), equals(0));
    await deleteCollection(collection, firestore: firestore);
    expect(await collection.get().then((value) => value.docs.length), equals(0));
  });
}
