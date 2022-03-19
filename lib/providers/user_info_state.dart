import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/relationship_bar_model.dart';
import '../models/userinfo_firestore_collection_model.dart';
import '../providers/partners_info_state.dart';

/// Handles current user state, dealing with users [UserInformation]
class UserInfoState with ChangeNotifier {
  UserInfoState();

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

  /// Stores the most recent [RelationshipBarDocument].
  RelationshipBarDocument? latestRelationshipBarDoc;

  /// Gets the list of [RelationshipBar] from [latestRelationshipBarDoc].
  List<RelationshipBar>? get barList => latestRelationshipBarDoc?.barList;

  /// True if any bars have been changed since last [resetBarChange].
  bool barsChanged = false;

  /// True if all bars are to be reset to values in database.
  bool barsReset = false;

  /// Setups listener for [UserInformation] changes of [userID] document.
  void setupUserInfoSubscription(PartnersInfoState partnersInfoState) {
    if (userExist) {
      _userInfoSubscription = UserInformation.getUserFromID(userID).snapshots().listen((snapshot) async {
        UserInformation? newUserInfo = snapshot.data();
        debugPrint("UserInfoState.setupYourInfoSubscription: User Info Change: $newUserInfo");

        userInfo = newUserInfo;
        String? partnerID = newUserInfo?.partnerID;
        if (partnerID != null && (!partnersInfoState.partnerExist || partnersInfoState.partnersID != partnerID)) {
          // If theres a new partner linked, setup partner info.
          partnersInfoState.addPartner(await UserInformation.firestoreGet(partnerID));
        }
        if (partnerID == null && partnersInfoState.partnerExist) {
          // Remove partner info if not linked.
          partnersInfoState.removePartner();
        }
        notifyListeners();
      });
    }
  }

  /// Setups local data for a new user.
  void addUser(UserInformation newUserInfo, PartnersInfoState partnersInfoState) {
    userInfo = newUserInfo;
    setupUserInfoSubscription(partnersInfoState);
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
}
