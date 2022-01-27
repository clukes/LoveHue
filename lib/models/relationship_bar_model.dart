import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:sqflite/sqflite.dart';

import '../database/local_database_handler.dart';

List<String> defaultBarLabels = [
  "Words of Affirmation",
  "Quality Time",
  "Giving Gifts",
  "Acts of Service",
  "Physical Touch",
];

CollectionReference<RelationshipBarDocument> userBarsFirestoreRef(
        String userID) =>
    FirebaseFirestore.instance
        .collection(userBarsCollection)
        .doc(userID)
        .collection(specificUserBarsCollection)
        .withConverter<RelationshipBarDocument>(
          fromFirestore: (snapshots, _) =>
              RelationshipBarDocument.fromMap(snapshots.data()!),
          toFirestore: (relationshipBarDocument, _) =>
              relationshipBarDocument.toMap(),
        );

const defaultBarValue = 100;

class RelationshipBar {
  int order;
  String label;
  int prevValue;
  int value;
  bool changed;

  RelationshipBar(
      {required this.order,
      required this.label,
      this.prevValue = defaultBarValue,
      this.value = defaultBarValue,
      this.changed = false});

  int setValue(int newValue) {
    if (newValue != value) {
      prevValue = value;
      value = newValue;
      changed = true;
    }
    return value;
  }

  int resetValue() {
    value = prevValue;
    changed = false;
    return value;
  }

  @override
  String toString() {
    return label + ": " + value.toString();
  }

  //Firestore database info
  static const String columnOrder = 'order';
  static const String columnLabel = 'label';
  static const String columnValue = 'value';
  static const String columnPrevValue = 'prevValue';

  static RelationshipBar fromMap(Map<String, Object?> res) {
    return RelationshipBar(
      order: res[columnOrder] as int,
      label: res[columnLabel]! as String,
      value:
          res[columnValue] is int ? res[columnValue] as int : defaultBarValue,
      prevValue:
          res[columnValue] is int ? res[columnValue] as int : defaultBarValue,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnOrder: order,
      columnLabel: label,
      columnPrevValue: prevValue,
      columnValue: value,
    };
  }

  static List<Map<String, dynamic>>? toMapList(List<RelationshipBar>? info) {
    return info?.map((e) => e.toMap()).toList();
  }

  static List<RelationshipBar>? fromMapList(List<dynamic>? query) {
    query?.sort((a, b) => a[columnOrder].compareTo(b[columnOrder]));
    return query?.map((e) => fromMap((e as Map<String, dynamic>))).toList();
  }

  static List<RelationshipBar> listFromLabels(List<String> labels) {
    return List<RelationshipBar>.generate(labels.length,
        (index) => RelationshipBar(order: index, label: labels[index]));
  }
}

class RelationshipBarDocument {
  final String id;
  Timestamp? timestamp;
  List<RelationshipBar>? barList;

  RelationshipBarDocument({
    required this.id,
    this.timestamp,
    this.barList,
  });

  RelationshipBarDocument resetBarsChanged() {
    barList?.map((e) {
      e.changed = false;
      return e;
    }).toList();
    return this;
  }

  Future<RelationshipBarDocument> resetBars() async {
    barList = (await firestoreGet(ApplicationState.instance.userID!, id))!
        .barList;
    return resetBarsChanged();
  }

  //Firestore database info
  static const String columnID = 'id';
  static const String columnTimestamp = 'timestamp';
  static const String columnBarList = 'barList';

  static RelationshipBarDocument fromMap(Map<String, Object?> res) {
    print("firestoreFromMap: $res");

    return RelationshipBarDocument(
      id: res[columnID] as String,
      timestamp: res[columnTimestamp] as Timestamp,
      barList: RelationshipBar.fromMapList(
          res[columnBarList] as List<dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnID: id,
      columnTimestamp: timestamp,
      columnBarList: RelationshipBar.toMapList(barList),
    };
  }

  static List<RelationshipBarDocument> fromQuerySnapshot(
      QuerySnapshot<RelationshipBarDocument> snapshot) {
    return snapshot.docs.map((e) => e.data()).toList();
  }

  static Future<RelationshipBarDocument?> firestoreGet(
      String userID, String barDocID,
      [GetOptions? options]) async {
    print("firestoreGet: $barDocID");
    return await userBarsFirestoreRef(userID)
        .doc(barDocID)
        .get(options)
        .then((snapshot) => snapshot.data())
        .catchError((error) {
      print("firestoreGet: Failed to retrieve relationship bar document: $error");
      return null;
    });
  }

  static Future<RelationshipBarDocument?> firestoreGetLatest(String userID,
      [GetOptions? options]) async {
    print("firestoreGetLatest: $userID");

    return await userBarsFirestoreRef(userID)
        .where(columnTimestamp, isNull: false)
        .orderBy(columnTimestamp, descending: true)
        .limit(1)
        .get(options)
        .then((QuerySnapshot<RelationshipBarDocument?> snapshot) => snapshot.docs[0].data())
        .catchError((error) {
      print("firestoreGetLatest: Failed to retrieve relationship bar document: $error");
    });
  }

  static Future<List<RelationshipBarDocument>?> firestoreGetAll(String userID,
      [GetOptions? options]) async {
    print("firestoreGetAll: $userID");
    return await userBarsFirestoreRef(userID)
        .get(options)
        .then((snapshot) => fromQuerySnapshot(snapshot))
        .catchError((error) {
      print("firestoreGetAll: Failed to retrieve relationship bar documents: $error");
      return <RelationshipBarDocument>[];
    });
  }

  Future<void> firestoreSet(String userID) async {
    print("firestoreSet: $id");
    return await userBarsFirestoreRef(userID)
        .doc(id)
        .set(this, SetOptions(merge: true))
        .then((value) => print("Relationship Bar Document Added"))
        .catchError((error) =>
            print("firestoreSet: Failed to add relationship bar document: $error"));
  }

  static Future<void> firestoreSetList(
      String userID, List<RelationshipBarDocument> barDocs) async {
    print("firestoreSetList: $barDocs");
    final CollectionReference<RelationshipBarDocument> ref =
        userBarsFirestoreRef(userID);
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    for (RelationshipBarDocument barDoc in barDocs) {
      batch.set(ref.doc(barDoc.id), barDoc, SetOptions(merge: true));
    }
    await batch.commit();
  }

  static Future<void> firestoreUpdateColumns(
      String userID, String barDocID, Map<String, dynamic> data) async {
    print("firestoreUpdateColumns: $barDocID");
    await userBarsFirestoreRef(userID)
        .doc(barDocID)
        .update(data)
        .then((value) => print("Relationship Bar Document Update"))
        .catchError((error) =>
            print("firestoreUpdateColumns: Failed to update relationship bar document: $error"));
  }

  Future<void> firestoreDelete(String userID) async {
    print("firestoreDelete: $id");
    await userBarsFirestoreRef(userID)
        .doc(id)
        .delete()
        .then((value) => print("Relationship Bar Document Deleted"))
        .catchError((error) =>
            print("firestoreDelete: Failed to delete relationship bar document: $error"));
  }

  static Future<RelationshipBarDocument> firestoreAddBarList(
      String userID, List<RelationshipBar> barList) async {
    print("firestoreAddBarList: $barList");
    WriteBatch batch = FirebaseFirestore.instance.batch();
    RelationshipBarDocument barDoc = firestoreAddBarListWithBatch(userID, barList, batch);
    await batch.commit();
    return barDoc;
  }

  static RelationshipBarDocument firestoreAddBarListWithBatch(
      String userID, List<RelationshipBar> barList, WriteBatch batch) {
    print("firestoreAddBarListWithBatch: $barList");
    final CollectionReference<RelationshipBarDocument> ref =
        userBarsFirestoreRef(userID);
    DocumentReference<RelationshipBarDocument> docRef = ref.doc();
    RelationshipBarDocument barDoc = RelationshipBarDocument(
        id: docRef.id,
        timestamp: Timestamp.now(),
        barList: barList);
    batch.set(docRef, barDoc, SetOptions(merge: true));
    batch.update(docRef, {columnTimestamp: FieldValue.serverTimestamp()});
    return barDoc;
  }
}