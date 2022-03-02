import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/userinfo_firestore_collection_model.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../resources/database_and_table_names.dart';
import '../resources/printable_error.dart';
import '../resources/unique_link_code_generator.dart';

/// Deals with LinkCodes, and interfaces with the FirebaseFirestore [LinkCode] collection.
///
/// A [LinkCode] holds a [linkCode] for a [user].
class LinkCode {
  LinkCode({
    required this.linkCode,
    this.user,
  });

  /// [String] holding uniquely identifying generated code.
  final String linkCode;

  /// [DocumentReference] to a [UserInformation] document.
  final DocumentReference<UserInformation?>? user;

  // Reference to the linkCode collection in FirebaseFirestore database.
  static final CollectionReference<LinkCode?> _linkCodeFirestoreRef =
      FirebaseFirestore.instance.collection(linkCodesCollection).withConverter<LinkCode?>(
            fromFirestore: (snapshots, _) => LinkCode.fromMap(snapshots.data()!),
            toFirestore: (linkCode, _) => linkCode!.toMap(),
          );

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

  /// Updates [LinkCode] data in the LinkCode collection to send a link request to a user.
  ///
  /// Creates link code request from the current [user] to the user with the given [linkCode].
  /// Throws [PrintableError] if user is already connected or pending with a different partner,
  /// or the given [linkCode] doesn't correspond to a [UserInformation] in the database,
  /// or the user with [linkCode] is already connected to a different user.
  static Future<void> connectTo(String linkCode) async {
    // Can only connect to a partner if user isn't already connected/pending to another partner.
    if (PartnersInfoState.instance.partnerExist) {
      PartnersInfoState.instance.partnerPending
          ? throw PrintableError("Partner link already pending.")
          : throw PrintableError("Already connected to a partner.");
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference<LinkCode?> partnerCodeReference = _linkCodeFirestoreRef.doc(linkCode);
      DocumentSnapshot partnerCodeSnapshot = await transaction.get(partnerCodeReference);
      if (!partnerCodeSnapshot.exists) {
        throw PrintableError("Link code does not exist.");
      }

      String partnerID = partnerCodeSnapshot.get(LinkCode.columnUser).id;
      DocumentReference<UserInformation?> partner = UserInformation.getUserFromID(partnerID);
      DocumentReference<UserInformation?> currentUser = UserInformation.getUserFromID(UserInfoState.instance.userID);
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

  /// Updates [LinkCode] data in the LinkCode collection to connect a user and partner.
  ///
  /// Accepts link code request sent to the current [user].
  /// Throws [PrintableError] if user is already connected to a different partner,
  /// or there is no user or partner for the currently stored [UserInformation].
  static Future<void> acceptRequest() async {
    if (PartnersInfoState.instance.partnerExist && !UserInfoState.instance.userPending) {
      throw PrintableError("Already connected to a partner.");
    }
    UserInformation userInfo = _getCurrentUser();
    DocumentReference<UserInformation?> currentUser = UserInformation.getUserFromID(userInfo.userID);
    // Update the user info in database first, then update locally stored information.
    await currentUser.update({UserInformation.columnLinkPending: false}).then((_) async {
      debugPrint("LinkCode.acceptRequest: Updated linkPending for user id: ${currentUser.id}.");
      UserInfoState.instance.userInfo?.linkPending = false;
      // Pull local partner info from database if it isn't correct.
      if (userInfo.partnerID != null &&
          (!PartnersInfoState.instance.partnerExist || userInfo.partnerID != PartnersInfoState.instance.partnersID)) {
        PartnersInfoState.instance.addPartner(await UserInformation.firestoreGet(userInfo.partnerID!));
        debugPrint("LinkCode.acceptRequest: Updated partner info with partner id: ${userInfo.partnerID}.");
      } else {
        PartnersInfoState.instance.notify();
      }
    });
  }

  /// Updates [LinkCode] data in the LinkCode collection to unlink/reject connection from current user to partner.
  ///
  /// Used to unlink current connection or reject request, between [user] and their partner.
  /// Throws [PrintableError] if there is no user or partner for the currently stored [UserInformation].
  static Future<void> unlink() async {
    UserInformation userInfo = _getCurrentUser();
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference<UserInformation?> currentUser = UserInformation.getUserFromID(UserInfoState.instance.userID);
      transaction.update(currentUser, {UserInformation.columnPartner: null, UserInformation.columnLinkPending: false});
      transaction
          .update(userInfo.partner!, {UserInformation.columnPartner: null, UserInformation.columnLinkPending: false});
    }).then((_) {
      PartnersInfoState.instance.removePartner();
    });
  }

  /// Creates new uniquely generated [LinkCode] in the database and returns a [DocumentReference] to it.
  static Future<DocumentReference<LinkCode?>> create() async {
    DocumentReference<LinkCode?>? linkCode;
    do {
      // Generate a new link code, and check if it already exists in the database, to ensure uniqueness.
      linkCode = await _linkCodeFirestoreRef
          .doc(generateLinkCode())
          .get()
          .then((snapshot) => !snapshot.exists ? snapshot.reference : null);
    } while (linkCode == null);
    return linkCode;
  }

  /// Throws [PrintableError] if there is no user or partner for the currently stored [UserInformation].
  static UserInformation _getCurrentUser() {
    UserInformation? userInfo = UserInfoState.instance.userInfo;
    if (userInfo == null) {
      throw PrintableError("No user in database for current user.");
    }
    if (userInfo.partner == null) {
      throw PrintableError("No partner pending connection to current user.");
    }
    return userInfo;
  }
}
