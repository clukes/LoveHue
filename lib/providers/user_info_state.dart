import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/userinfo_firestore_collection_model.dart';
import '../providers/partners_info_state.dart';

/// Handles current user state, dealing with users [UserInformation]
class UserInfoState with ChangeNotifier {
  // Singleton pattern
  static final UserInfoState _instance = UserInfoState._internal();

  static UserInfoState get instance => _instance;

  UserInfoState._internal();

  factory UserInfoState() => _instance;

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

  /// Setups listener for [UserInformation] changes of [userID] document.
  void setupUserInfoSubscription() {
    if (userExist) {
      _userInfoSubscription = UserInformation.getUserFromID(userID).snapshots().listen((snapshot) async {
        UserInformation? newUserInfo = snapshot.data();
        debugPrint("UserInfoState.setupYourInfoSubscription: User Info Change: $newUserInfo");

        userInfo = newUserInfo;
        String? partnerID = newUserInfo?.partnerID;
        if (partnerID != null &&
            (!PartnersInfoState.instance.partnerExist || PartnersInfoState.instance.partnersID != partnerID)) {
          // If theres a new partner linked, setup partner info.
          PartnersInfoState.instance.addPartner(await UserInformation.firestoreGet(partnerID));
        }
        if (partnerID == null && PartnersInfoState.instance.partnerExist) {
          // Remove partner info if not linked.
          PartnersInfoState.instance.removePartner();
        }
        notifyListeners();
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
}
