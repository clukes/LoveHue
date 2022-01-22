import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:relationship_bars/database/firestore_database_handler.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';

final CollectionReference<UserInformation?> userInfoFirestoreRef = FirebaseFirestore.instance
    .collection(userInfoCollection)
    .withConverter<UserInformation?>(
  fromFirestore: (snapshots, _) => UserInformation.fromMap(snapshots.data()!),
  toFirestore: (userInfo, _) => userInfo!.toMap(),
);

class UserInformation {
  final String userID;
  String? displayName = "User";
  DocumentReference? partner;
  DocumentReference? linkCode;
  String? get partnerID => partner?.id;

  //Firestore database info
  static const String columnUserID = 'id';
  static const String columnDisplayName = 'displayName';
  static const String columnPartner = 'partner';
  static const String columnLinkCode = 'linkCode';

  UserInformation({required this.userID, this.displayName, this.partner, this.linkCode});

  static UserInformation fromMap(Map<String, Object?> res) {
    return UserInformation(
      userID: res[columnUserID]! as String,
      displayName: res[columnDisplayName] as String?,
      partner: res[columnPartner] as DocumentReference?,
      linkCode: res[columnLinkCode] as DocumentReference?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnUserID: userID,
      columnDisplayName: displayName,
      columnPartner: partner,
      columnLinkCode: linkCode,
    };
  }

  List<Map<String, dynamic>> userInfoToList(List<UserInformation> info) {
    return info.map((e) => e.toMap()).toList();
  }

  List<UserInformation> userInfoFromList(List<Map<String, dynamic>> query) {
    return query.map((e) => fromMap(e)).toList();
  }

  static Future<UserInformation?> firestoreGet(String userID) async {
    print("Get");
    UserInformation? info;
    info = await userInfoFirestoreRef
        .doc(userID)
        .get()
        .then((snapshot) => snapshot.data())
        .catchError((error) { print("Failed to retrieve user info: $error");});
    return info;
  }

  Future<void> firestoreSet(WriteBatch? batch) async {
    return await userInfoFirestoreRef
        .doc(userID)
        .set(this, SetOptions(merge: true))
        .then((value) => print("User Info Added"))
        .catchError((error) => print("Failed to add user info: $error"));
  }

  static Future<void> firestoreUpdateColumns(String userID, Map<String, dynamic> data) async {
    return await userInfoFirestoreRef
        .doc(userID)
        .update(data)
        .then((value) => print("User Info Update"))
        .catchError((error) => print("Failed to update user info: $error"));
  }

  Future<void> firestoreDelete() async {
    return await userInfoFirestoreRef
        .doc(userID)
        .delete()
        .then((value) => print("User Info Deleted"))
        .catchError((error) => print("Failed to delete user info: $error"));
  }
}