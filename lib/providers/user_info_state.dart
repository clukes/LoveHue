import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/link_code.dart';
import '../models/relationship_bar.dart';
import '../models/relationship_bar_document.dart';
import '../models/user_information.dart';
import '../providers/partners_info_state.dart';
import '../resources/printable_error.dart';

/// Handles current user state, dealing with users [UserInformation]
class UserInfoState with ChangeNotifier {
  UserInfoState(FirebaseFirestore? firestore, this.partnersInfoState) {
    this.firestore = firestore ?? FirebaseFirestore.instance;
  }

  final PartnersInfoState partnersInfoState;
  late final FirebaseFirestore firestore;

  StreamSubscription<DocumentSnapshot>? _userInfoSubscription;

  /// [UserInformation] for current user.
  UserInformation? userInfo;

  /// ID for current user if exists.
  String? get userID => userInfo?.userID;

  /// ID for [LinkCode] of current user if exists.
  String? get linkCode => userInfo?.linkCode.id;

  /// True if [userID] is not null.
  bool get userExist => (userInfo?.userID != null);

  /// True if [userExist] and there is a link pending.
  bool get userPending => (userExist && (userInfo?.linkPending ?? false));

  /// True if [partnerExist] and there isn't a link pending.
  bool get partnerLinked => (partnersInfoState.partnerExist &&
      !partnersInfoState.partnerPending &&
      !userPending);

  /// Stores the most recent [RelationshipBarDocument].
  RelationshipBarDocument? latestRelationshipBarDoc;

  /// Gets the list of [RelationshipBar] from [latestRelationshipBarDoc].
  List<RelationshipBar>? get barList => latestRelationshipBarDoc?.barList;

  /// True if any bars have been changed since last [resetBarChange].
  bool barsChanged = false;

  /// True if all bars are to be reset to values in database.
  bool barsReset = false;

  /// Setups listener for [UserInformation] changes of [userID] document.
  void setupUserInfoSubscription() {
    if (userInfo != null) {
      _userInfoSubscription =
          userInfo!.getUserInDatabase().snapshots().listen((snapshot) async {
        UserInformation? newUserInfo = snapshot.data();
        debugPrint(
            "UserInfoState.setupYourInfoSubscription: User Info Change: $newUserInfo");

        if (newUserInfo != null) {
          userInfo = newUserInfo;

          String? partnerID = newUserInfo.partnerID;
          if (partnerID != null &&
              (!partnersInfoState.partnerExist ||
                  partnersInfoState.partnersID != partnerID)) {
            // If theres a new partner linked, setup partner info.
            UserInformation? partnerInfo =
                await UserInformation.firestoreGetFromID(partnerID, firestore);
            partnersInfoState.addPartner(partnerInfo, userInfo!);
          } else if (partnerID == null && partnersInfoState.partnerExist) {
            // Remove partner info if not linked.
            partnersInfoState.removePartner(userInfo!);
          }
          notifyListeners();
        }
      });
    }
  }

  /// Setups local data for a new user.
  void addUser(UserInformation newUserInfo) {
    userInfo = newUserInfo;
    setupUserInfoSubscription();
    notifyListeners();
  }

  /// Removes local data for current user.
  void removeUser() {
    userInfo = null;
    _userInfoSubscription?.cancel();
    notifyListeners();
  }

  /// Set [barsChanged] to true, and [notifyListeners].
  void barChange() {
    if (!barsChanged) {
      barsChanged = true;
      notifyListeners();
    }
  }

  /// Set [barsChanged] to false, and [notifyListeners].
  void resetBarChange() {
    if (barsChanged) {
      barsChanged = false;
      notifyListeners();
    }
  }

  /// Updates [UserInformation] data to send a link request to a user.
  ///
  /// Creates link code request from the current [user] to the user with the given [linkCode].
  /// Throws [PrintableError] if user is already connected or pending with a different partner,
  /// or the given [linkCode] doesn't correspond to a [UserInformation] in the database,
  /// or the user with [linkCode] is already connected to a different user.
  Future<void> connectTo(String linkCode) async {
    // Can only connect to a partner if user isn't already connected/pending to another partner.
    if (partnersInfoState.partnerExist) {
      partnersInfoState.partnerPending
          ? throw PrintableError("Partner link already pending.")
          : throw PrintableError("Already connected to a partner.");
    }
    UserInformation? userInfo = this.userInfo;
    if (userInfo == null) {
      throw PrintableError("No current user.");
    }

    await firestore.runTransaction((transaction) async {
      DocumentReference<LinkCode?> partnerCodeReference =
          LinkCode.getDocumentReference(linkCode, firestore);
      DocumentSnapshot partnerCodeSnapshot =
          await transaction.get(partnerCodeReference);
      if (!partnerCodeSnapshot.exists) {
        throw PrintableError("Link code does not exist.");
      }
      if (partnerCodeSnapshot.get(LinkCode.columnUser) == null) {
        throw PrintableError("No user for that link code.");
      }
      String partnerID = partnerCodeSnapshot.get(LinkCode.columnUser).id;
      DocumentReference<UserInformation?> partner =
          UserInformation.getUserInDatabaseFromID(partnerID, firestore);
      DocumentReference<UserInformation?> currentUser =
          UserInformation.getUserInDatabaseFromID(userInfo.userID, firestore);
      DocumentSnapshot<UserInformation?> partnerSnapshot =
          await transaction.get(partner);
      if (!partnerSnapshot.exists || partnerSnapshot.data() == null) {
        throw PrintableError("Link code does not exist.");
      }
      if (partnerSnapshot.get(UserInformation.columnPartner) != null) {
        throw PrintableError("That user is already connected to a partner.");
      }
      transaction.update(currentUser, {
        UserInformation.columnPartner: partner,
        UserInformation.columnLinkPending: false
      });
      transaction.update(partner, {
        UserInformation.columnPartner: currentUser,
        UserInformation.columnLinkPending: true
      });
      UserInformation partnerInfo = partnerSnapshot.data()!;
      partnerInfo.linkPending = true;
      partnerInfo.partner = currentUser;
      return partnerInfo;
    }).then((partnerInfo) {
      partnersInfoState.addPartner(partnerInfo, userInfo);
    });
  }

  /// Updates [UserInformation] data to connect user and partner.
  ///
  /// Accepts link code request sent to the current [user].
  /// Throws [PrintableError] if user is already connected to a different partner,
  /// or there is no user or partner for the currently stored [UserInformation].
  Future<void> acceptRequest() async {
    if (partnersInfoState.partnerExist && !userPending) {
      throw PrintableError("Already connected to a partner.");
    }
    UserInformation userInfo = _getCurrentUser();
    DocumentReference<UserInformation?> currentUser =
        userInfo.getUserInDatabase();
    // Update the user info in database first, then update locally stored information.
    await currentUser
        .update({UserInformation.columnLinkPending: false}).then((_) async {
      debugPrint(
          "LinkCode.acceptRequest: Updated linkPending for user id: ${currentUser.id}.");
      userInfo.linkPending = false;
      // Pull local partner info from database if it isn't correct.
      if (userInfo.partnerID != null &&
          (!partnersInfoState.partnerExist ||
              userInfo.partnerID != partnersInfoState.partnersID)) {
        UserInformation? newPartnerInfo =
            await UserInformation.firestoreGetFromID(
                userInfo.partnerID!, firestore);
        partnersInfoState.addPartner(newPartnerInfo, userInfo);
        debugPrint(
            "LinkCode.acceptRequest: Updated partner info with partner id: ${userInfo.partnerID}.");
      } else {
        // Notify listeners that partner has been connected.
        partnersInfoState.notify();
      }
    });
  }

  /// Updates [UserInformation] data to unlink/reject connection from current user to partner.
  ///
  /// Used to unlink current connection or reject request, between [user] and their partner.
  /// Throws [PrintableError] if there is no user or partner for the currently stored [UserInformation].
  Future<void> unlink() async {
    UserInformation userInfo = _getCurrentUser();
    await firestore.runTransaction((transaction) async {
      DocumentReference<UserInformation?> currentUser =
          userInfo.getUserInDatabase();
      transaction.update(currentUser, {
        UserInformation.columnPartner: null,
        UserInformation.columnLinkPending: false
      });
      transaction.update(userInfo.partner!, {
        UserInformation.columnPartner: null,
        UserInformation.columnLinkPending: false
      });
    }).then((_) {
      partnersInfoState.removePartner(userInfo);
    });
  }

  /// Throws [PrintableError] if there is no user or partner for the currently stored [UserInformation].
  UserInformation _getCurrentUser() {
    UserInformation? userInfo = this.userInfo;
    if (userInfo == null) {
      throw PrintableError("No user in database for current user.");
    }
    if (userInfo.partner == null) {
      throw PrintableError("No partner with connection to current user.");
    }
    return userInfo;
  }

  Future<void> saveBars() async {
    String? userID = this.userID;
    RelationshipBarDocument? barDoc = latestRelationshipBarDoc;
    if (userID != null && barDoc != null) {
      barDoc.resetBarsChanged();
      latestRelationshipBarDoc =
          await RelationshipBarDocument.firestoreAddBarList(
              userID, barDoc.barList, firestore);
      resetBarChange();
    }
    return;
  }
}
