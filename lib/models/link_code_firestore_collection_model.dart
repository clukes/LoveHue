import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:relationship_bars/database/firestore_database_handler.dart';
import 'package:relationship_bars/models/userinfo_firestore_collection_model.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:relationship_bars/resources/printable_error.dart';


final CollectionReference<LinkCode?> linkCodeFirestoreRef = FirebaseFirestore.instance
    .collection(linkCodesCollection)
    .withConverter<LinkCode?>(
  fromFirestore: (snapshots, _) => LinkCode.fromMap(snapshots.data()!),
  toFirestore: (linkCode, _) => linkCode!.toMap(),
);

class LinkCode {
  final String linkCode;
  DocumentReference? user;

  //Firestore database info
  static const String columnLinkCode = 'linkCode';
  static const String columnUser = 'user';

  LinkCode({required this.linkCode, this.user});

  static LinkCode fromMap(Map<String, Object?> res) {
    return LinkCode(
      linkCode: res[columnLinkCode]! as String,
      user: res[columnUser] as DocumentReference?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnLinkCode: linkCode,
      columnUser: user,
    };
  }

  static Future<String?> connectLinkCode(String linkCode) async {
    if(ApplicationState.instance.partnersInfo != null) {
      throw PrintableError("Already connected to a partner");
    }
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference<Object?> linkCodeReference = linkCodeFirestoreRef.doc(linkCode);
      DocumentSnapshot linkCodeSnapshot = await transaction.get(linkCodeReference);
      if (!linkCodeSnapshot.exists) {
        throw PrintableError("Link code does not exist.");
      }
      String partnerID = linkCodeSnapshot.get(LinkCode.columnUser).id;
      DocumentReference<UserInformation?> partner = userInfoFirestoreRef.doc(partnerID);
      DocumentReference<UserInformation?> currentUser = userInfoFirestoreRef.doc(ApplicationState.instance.userID);
      DocumentSnapshot<UserInformation?> partnerSnapshot = await transaction.get(partner);
      if(!partnerSnapshot.exists || partnerSnapshot.data() == null) {
        throw PrintableError("Link code does not exist.");
      }
      if(partnerSnapshot.get(UserInformation.columnPartner) != null) {
        throw PrintableError("That user is already connected to a partner.");
      }
      transaction.update(currentUser, {UserInformation.columnPartner: partner});
      transaction.update(partner, {UserInformation.columnPartner: currentUser});
      return partnerSnapshot.data();
    }).then((partnerInfo) {
      ApplicationState.instance.partnersInfo = partnerInfo;
      ApplicationState.instance.setupPartnerInfoSubscription();
    }
    );
  }
}