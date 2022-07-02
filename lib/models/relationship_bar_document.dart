import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/relationship_bar.dart';
import '../resources/database_and_table_names.dart';

/// Holds information for a [RelationshipBarDocument] containing a list of [RelationshipBar].
class RelationshipBarDocument {
  RelationshipBarDocument({
    required this.id,
    this.timestamp,
    this.barList,
    FirebaseFirestore? firestore,
    required this.userID,
  }) {
    this.firestore = (firestore == null) ? FirebaseFirestore.instance : firestore;
  }

  late final FirebaseFirestore firestore;

  /// id in database for this document.
  final String id;

  String userID;

  /// Timestamp when document was last changed.
  Timestamp? timestamp;

  /// List of [RelationshipBar] in document.
  List<RelationshipBar>? barList;

  /// Column names for a RelationshipBar document in the FirebaseFirestore Database.
  static const String columnID = 'id';
  static const String columnTimestamp = 'timestamp';
  static const String columnBarList = 'barList';

  /// Sets all bars in this [barList] to have [RelationshipBar.changed] set to false.
  void resetBarsChanged() {
    barList?.map((e) {
      e.changed = false;
      return e;
    }).toList();
  }

  /// Replaces [barList] with the list of [RelationshipBar] stored in the database.
  Future<void> resetBars() async {
    RelationshipBarDocument? prevBarDoc = await firestoreGet();
    if (prevBarDoc == null) {
      debugPrint("RelationshipBarDocument.resetBars: Retrieved no bars from firestore.");
      return;
    }
    barList = prevBarDoc.barList;
  }

  /// Gets a reference to the [RelationshipBarDocument] collection for user with the given id.
  static CollectionReference<RelationshipBarDocument> getUserBarsFromID(String userID, FirebaseFirestore? firestore) {
    firestore ??= FirebaseFirestore.instance;
    return firestore
        .collection(userBarsCollection)
        .doc(userID)
        .collection(specificUserBarsCollection)
        .withConverter<RelationshipBarDocument>(
          fromFirestore: (snapshots, _) => RelationshipBarDocument.fromMap(snapshots.data()!, userID, firestore),
          toFirestore: (relationshipBarDocument, _) => relationshipBarDocument.toMap(),
        );
  }

  /// Converts a given [Map] to the returned [RelationshipBarDocument].
  static RelationshipBarDocument fromMap(Map<String, Object?> res, String userID, FirebaseFirestore? firestore) {
    return RelationshipBarDocument(
      id: res[columnID] as String,
      timestamp: res[columnTimestamp] as Timestamp?,
      barList: res[columnBarList] != null
          ? RelationshipBar.fromMapList(List<Map<String, Object?>>.from(res[columnBarList] as List))
          : null,
      firestore: firestore,
      userID: userID,
    );
  }

  /// Converts this [RelationshipBarDocument] to the returned [Map].
  Map<String, Object?> toMap() {
    return <String, Object?>{
      columnID: id,
      columnTimestamp: timestamp,
      columnBarList: RelationshipBar.toMapList(barList),
    };
  }

  /// Converts a [QuerySnapshot] to a list of [RelationshipBarDocument].
  static List<RelationshipBarDocument> fromQuerySnapshot(QuerySnapshot<RelationshipBarDocument> snapshot) {
    return snapshot.docs.map((e) => e.data()).toList();
  }

  /// Retrieve specific [RelationshipBarDocument] from the FirebaseFirestore collection.
  Future<RelationshipBarDocument?> firestoreGet([GetOptions? options]) async {
    debugPrint("RelationshipBarDocument.firestoreGet: Get doc with barDocID: $id.");
    RelationshipBarDocument? doc = await getUserBarsFromID(userID, firestore)
        .doc(id)
        .get(options)
        .then((snapshot) => snapshot.data())
        .catchError((error) {
      debugPrint("RelationshipBarDocument.firestoreGet: Failed to retrieve relationship bar document: $error.");
    });
    return doc;
  }

  /// Retrieve [RelationshipBarDocument] with the greatest timestamp from the FirebaseFirestore collection for given userID.
  static Future<RelationshipBarDocument?> firestoreGetLatest(String userID, FirebaseFirestore? firestore,
      [GetOptions? options]) async {
    debugPrint("RelationshipBarDocument.firestoreGetLatest: Get doc for userID: $userID.");

    return await getUserBarsFromID(userID, firestore)
        .where(columnTimestamp, isNull: false)
        .orderBy(columnTimestamp, descending: true)
        .limit(1)
        .get(options)
        .then((QuerySnapshot<RelationshipBarDocument?> snapshot) => snapshot.docs[0].data())
        .catchError((error) {
      debugPrint("RelationshipBarDocument.firestoreGetLatest: Failed to retrieve relationship bar document: $error.");
    });
  }

  /// Retrieve ordered list of [RelationshipBarDocument] for user with given userID.
  static Query<RelationshipBarDocument> getOrderedUserBarsFromID(String userID, FirebaseFirestore? firestore) {
    return getUserBarsFromID(userID, firestore).orderBy(RelationshipBarDocument.columnTimestamp, descending: true);
  }

  /// Retrieve list of [RelationshipBarDocument] from the FirebaseFirestore collection for given userID.
  static Future<List<RelationshipBarDocument?>> firestoreGetAll(String userID, FirebaseFirestore? firestore,
      [GetOptions? options]) async {
    debugPrint("RelationshipBarDocument.firestoreGetAll: Get docs for userID: $userID.");
    return await getUserBarsFromID(userID, firestore)
        .get(options)
        .then((snapshot) => fromQuerySnapshot(snapshot))
        .catchError((error) {
      debugPrint("RelationshipBarDocument.firestoreGetAll: Failed to retrieve relationship bar documents: $error.");
      return <RelationshipBarDocument>[];
    });
  }

  /// Creates/updates this [RelationshipBarDocument] in given userID's RelationshipBarDocument FirebaseFirestore collection.
  Future<void> firestoreSet() async {
    debugPrint("RelationshipBarDocument.firestoreSet: Set doc with id: $id, for userID: $userID.");
    return await getUserBarsFromID(userID, firestore)
        .doc(id)
        .set(this, SetOptions(merge: true))
        .then((value) => debugPrint(
            "RelationshipBarDocument.firestoreSet: Relationship Bar Document Added with id: $id, for userID: $userID."))
        .catchError((error) =>
            debugPrint("RelationshipBarDocument.firestoreSet: Failed to add relationship bar document: $error"));
  }

  /// Creates/merges each [RelationshipBarDocument] in list to given userID's RelationshipBarDocument FirebaseFirestore collection.
  static Future<void> firestoreSetList(
      String userID, List<RelationshipBarDocument> barDocs, FirebaseFirestore? firestore) async {
    debugPrint("RelationshipBarDocument.firestoreSetList: Set list of barDocs: $barDocs");
    firestore ??= FirebaseFirestore.instance;
    final CollectionReference<RelationshipBarDocument> ref = getUserBarsFromID(userID, firestore);
    final WriteBatch batch = firestore.batch();

    for (RelationshipBarDocument barDoc in barDocs) {
      batch.set(ref.doc(barDoc.id), barDoc, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Updates columns of [RelationshipBarDocument] with given userID, using the given data Map, in the RelationshipBarDocument FirebaseFirestore collection.
  Future<void> firestoreUpdateColumns(Map<String, Object?> data) async {
    debugPrint("RelationshipBarDocument.firestoreUpdateColumns: Update doc with id: $id.");
    await getUserBarsFromID(userID, firestore)
        .doc(id)
        .update(data)
        .then(
            (value) => debugPrint("RelationshipBarDocument.firestoreUpdateColumns: Relationship Bar Document Updated."))
        .catchError((error) => debugPrint(
            "RelationshipBarDocument.firestoreUpdateColumns: Failed to update relationship bar document: $error."));
  }

  /// Deletes this [RelationshipBarDocument] from given userID's RelationshipBarDocument FirebaseFirestore collection.
  Future<void> firestoreDelete() async {
    debugPrint("RelationshipBarDocument.firestoreDelete: Delete doc with id: $id.");
    await getUserBarsFromID(userID, firestore)
        .doc(id)
        .delete()
        .then((value) => debugPrint("RelationshipBarDocument.firestoreDelete: Relationship Bar Document Deleted."))
        .catchError((error) => debugPrint("firestoreDelete: Failed to delete relationship bar document: $error."));
  }

  /// Creates [RelationshipBarDocument] with given barList and adds to given userID's RelationshipBarDocument FirebaseFirestore collection.
  static Future<RelationshipBarDocument?> firestoreAddBarList(String userID, List<RelationshipBar>? barList,
      {FirebaseFirestore? firestore}) async {
    debugPrint("RelationshipBarDocument.firestoreAddBarList: Add list: $barList.");
    if (barList == null) {
      return null;
    }
    firestore ??= FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();
    RelationshipBarDocument barDoc = firestoreAddBarListWithBatch(userID, barList, batch, firestore);
    await batch.commit();
    return barDoc;
  }

  /// Uses given batch without committing to give batch operations that add a bar list.
  ///
  /// Creates [RelationshipBarDocument] with given barList and adds to given userID's RelationshipBarDocument FirebaseFirestore collection.
  /// Doesn't call [WriteBatch.commit], adds necessary operations to batch which should be committed after this function call.
  ///
  /// See also: [firestoreAddBarList] which has the same functionality, without a given batch.
  static RelationshipBarDocument firestoreAddBarListWithBatch(
      String userID, List<RelationshipBar> barList, WriteBatch batch, FirebaseFirestore? firestore) {
    // Allows passing in a batch so that adding a bar list can be combined with other operations in one batch commit.
    debugPrint("RelationshipBarDocument.firestoreAddBarListWithBatch: Add list: $barList.");
    final CollectionReference<RelationshipBarDocument> ref = getUserBarsFromID(userID, firestore);
    DocumentReference<RelationshipBarDocument> docRef = ref.doc();
    RelationshipBarDocument barDoc = RelationshipBarDocument(
        id: docRef.id, timestamp: Timestamp.now(), barList: barList, userID: userID, firestore: firestore);
    batch.set(docRef, barDoc, SetOptions(merge: true));
    batch.update(docRef, {columnTimestamp: FieldValue.serverTimestamp()});
    return barDoc;
  }
}
