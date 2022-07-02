import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_information.dart';
import '../resources/database_and_table_names.dart';
import '../resources/unique_link_code_generator.dart';

/// Deals with LinkCodes, and interfaces with the FirebaseFirestore [LinkCode] collection.
///
/// A [LinkCode] holds a [linkCode] for a [user].
class LinkCode {
  LinkCode({required this.linkCode, this.user});

  /// [String] holding uniquely identifying generated code.
  final String linkCode;

  /// [DocumentReference] to a [UserInformation] document.
  final DocumentReference<UserInformation?>? user;

  // Reference to the linkCode collection in FirebaseFirestore database.
  static CollectionReference<LinkCode?> _firestoreConverter(
      FirebaseFirestore? firestore) {
    firestore ??= FirebaseFirestore.instance;
    return firestore.collection(linkCodesCollection).withConverter<LinkCode?>(
          fromFirestore: (snapshots, _) => LinkCode.fromMap(snapshots.data()!),
          toFirestore: (linkCode, _) => linkCode!.toMap(),
        );
  }

  /// Column names for a LinkCode document in the FirebaseFirestore Database.
  static const String columnLinkCode = 'linkCode';
  static const String columnUser = 'user';

  /// Converts a given [Map] to the returned [LinkCode].
  static LinkCode fromMap(Map<String, Object?> res) {
    return LinkCode(
      linkCode: res[columnLinkCode]! as String,
      user: res[columnUser] as DocumentReference<UserInformation?>?,
    );
  }

  /// Converts this [LinkCode] to the returned [Map].
  Map<String, Object?> toMap() {
    return <String, Object?>{
      columnLinkCode: linkCode,
      columnUser: user,
    };
  }

  static DocumentReference<LinkCode?> getDocumentReference(
      String linkCode, FirebaseFirestore? firestore) {
    return _firestoreConverter(firestore).doc(linkCode);
  }

  /// Generates id for a new uniquely generated [LinkCode], and returns a [DocumentReference] to it.
  ///
  /// If newCode is supplied, will check if it exists in the database, and generate a different code if so.
  static Future<DocumentReference<LinkCode?>> create(
      FirebaseFirestore? firestore,
      {String? newCode}) async {
    DocumentReference<LinkCode?>? linkCode;
    do {
      // Generate a new link code, and check if it already exists in the database, to ensure uniqueness.
      linkCode = await _firestoreConverter(firestore)
          .doc(newCode ?? generateLinkCode())
          .get()
          .then((snapshot) => !snapshot.exists ? snapshot.reference : null);
      newCode = null;
    } while (linkCode == null);
    return linkCode;
  }
}
