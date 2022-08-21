import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to connect with firestore.
class DatabaseService {
  final FirebaseFirestore firestore;

  DatabaseService(this.firestore);

  /// Saves [data] to [docPath] in firestore.
  Future<void> saveAsync(String docPath, Map<String, dynamic> data) =>
      firestore.doc(docPath).set(data);

  /// Saves a milliseconds timestamp to [docPath] in firestore.
  Future<void> saveTimestampAsync(
      String docPath, String lastNudgeTimestampKey, int milliseconds) {
    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(milliseconds);
    Map<String, Timestamp> data = {lastNudgeTimestampKey: timestamp};
    return saveAsync(docPath, data);
  }
}
