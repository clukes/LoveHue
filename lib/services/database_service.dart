import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Service to connect with firestore.
class DatabaseService {
  final FirebaseFirestore firestore;

  DatabaseService(this.firestore);

  /// Saves [data] to [docPath] in firestore.
  Future<void> saveAsync(String docPath, Map<String, dynamic> data,
      {bool merge = false}) {
    debugPrint(
        "saveAsync: Writing to $docPath with data $data and merge set to $merge");
    return firestore.doc(docPath).set(data, SetOptions(merge: merge));
  }

  /// Saves [data] object to [docPath] in firestore, overwriting doc if exists.
  Future<void> writeObjectAsync<T extends Mappable>(String docPath, T data) =>
      saveAsync(docPath, data.toMap(), merge: false);

  /// Saves [data] object to [docPath] in firestore, merging with doc if exists and ignoring null values in object.
  Future<void> mergeObjectAsync<T extends Mappable>(String docPath, T data) =>
      saveAsync(docPath, data.toMapIgnoreNulls(), merge: true);
}

abstract class Mappable {
  Map<String, Object?> toMap();

  Map<String, Object> toMapIgnoreNulls();
}
