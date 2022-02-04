import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relationship_bars/models/userinfo_firestore_collection_model.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:relationship_bars/resources/printable_error.dart';

final CollectionReference<LinkCode?> linkCodeFirestoreRef =
    FirebaseFirestore.instance.collection(linkCodesCollection).withConverter<LinkCode?>(
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

  static Future<void> connectLinkCode(String linkCode) async {
    if (PartnersInfoState.instance.partnerExist) {
      PartnersInfoState.instance.partnerPending
          ? throw PrintableError("Partner link already pending.")
          : throw PrintableError("Already connected to a partner.");
    }
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference<LinkCode?> linkCodeReference = linkCodeFirestoreRef.doc(linkCode);
      DocumentSnapshot linkCodeSnapshot = await transaction.get(linkCodeReference);
      if (!linkCodeSnapshot.exists) {
        throw PrintableError("Link code does not exist.");
      }
      String partnerID = linkCodeSnapshot.get(LinkCode.columnUser).id;
      DocumentReference<UserInformation?> partner = userInfoFirestoreRef.doc(partnerID);
      DocumentReference<UserInformation?> currentUser = userInfoFirestoreRef.doc(UserInfoState.instance.userID);
      DocumentSnapshot<UserInformation?> partnerSnapshot = await transaction.get(partner);
      if (!partnerSnapshot.exists || partnerSnapshot.data() == null) {
        throw PrintableError("Link code does not exist.");
      }
      if (partnerSnapshot.get(UserInformation.columnPartner) != null) {
        throw PrintableError("That user is already connected to a partner.");
      }
      transaction
          .update(currentUser, {UserInformation.columnPartner: partner, UserInformation.columnLinkPending: false});
      transaction
          .update(partner, {UserInformation.columnPartner: currentUser, UserInformation.columnLinkPending: true});
      UserInformation partnerInfo = partnerSnapshot.data()!;
      partnerInfo.linkPending = true;
      partnerInfo.partner = currentUser;
      return partnerInfo;
    }).then((partnerInfo) {
      PartnersInfoState.instance.addPartner(partnerInfo);
    });
  }

  static Future<void> acceptLinkCode() async {
    if (PartnersInfoState.instance.partnerExist && !UserInfoState.instance.userPending) {
      throw PrintableError("Already connected to a partner.");
    }
    UserInformation? userInfo = UserInfoState.instance.userInfo;
    if (userInfo == null) {
      throw PrintableError("No user.");
    }
    if (userInfo.partner == null) {
      throw PrintableError("No partner.");
    }
    DocumentReference<UserInformation?> currentUser = userInfoFirestoreRef.doc(userInfo.userID);
    await currentUser.update({UserInformation.columnLinkPending: false}).then((_) async {
      print("UPDATED USER");
      UserInfoState.instance.userInfo?.linkPending = false;
      print(userInfo.partnerID);
      print(PartnersInfoState.instance.partnerExist);
      print(PartnersInfoState.instance.partnersID);
      if (userInfo.partnerID != null && (!PartnersInfoState.instance.partnerExist || userInfo.partnerID != PartnersInfoState.instance.partnersID)) {
        print("UPDATE PARTNER INFO");
        PartnersInfoState.instance.addPartner(await UserInformation.firestoreGet(userInfo.partnerID!));
      }
      else {
        PartnersInfoState.instance.notify();
      }
    });
  }

  static Future<void> rejectLinkCode() async {
    UserInformation? userInfo = UserInfoState.instance.userInfo;
    if (userInfo == null) {
      throw PrintableError("No user.");
    }
    if (userInfo.partner == null) {
      throw PrintableError("No partner.");
    }
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference<UserInformation?> currentUser = userInfoFirestoreRef.doc(UserInfoState.instance.userID);
      transaction.update(currentUser, {UserInformation.columnPartner: null, UserInformation.columnLinkPending: false});
      transaction
          .update(userInfo.partner!, {UserInformation.columnPartner: null, UserInformation.columnLinkPending: false});
    }).then((_) {
      PartnersInfoState.instance.removePartner();
    });
  }

  static Future<void> unlinkLinkCode() async {
    rejectLinkCode();
  }
}
