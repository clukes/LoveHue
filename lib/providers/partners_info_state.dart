import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_information.dart';

const String defaultPartnerName = "Partner";

/// Handles partner state, dealing with partners [UserInformation]
class PartnersInfoState with ChangeNotifier {
  PartnersInfoState();

  StreamSubscription<DocumentSnapshot>? _partnersInfoSubscription;
  UserInformation? _partnersInfo;

  /// [UserInformation] for linked partner if exists.
  UserInformation? get partnersInfo => _partnersInfo;

  /// ID for linked partner if exists.
  String? get partnersID => _partnersInfo?.userID;

  /// ID for [LinkCode] of linked partner if exists.
  String? get linkCode => _partnersInfo?.linkCode.id;

  /// True if [partnersID] is not null.
  bool get partnerExist => (partnersID != null);

  /// True if [partnerExist] and there is a link pending.
  bool get partnerPending => (partnerExist && (_partnersInfo?.linkPending ?? false));

  /// [ValueNotifier] to listen to changes in the partners [UserInformation.displayName]. Defaults to "Partner".
  ValueNotifier<String> partnersName = ValueNotifier<String>(defaultPartnerName);

  /// Allows outside classes to call [notifyListeners].
  void notify() => notifyListeners();

  /// Setups listener for [UserInformation] changes of [partnersID] document.
  void setupPartnerInfoSubscription(UserInformation currentUserInfo) {
    if (_partnersInfo != null) {
      _partnersInfoSubscription = _partnersInfo!.getUserInDatabase().snapshots().listen((snapshot) {
        UserInformation? partnersUserInfo = snapshot.data();
        debugPrint("PartnersInfoState.setupPartnerInfoSubscription: Partner Info Change: $partnersUserInfo");

        if (partnersUserInfo?.partnerID == currentUserInfo.userID) {
          // Check that user and partner are linked to each other
          _partnersInfo = partnersUserInfo;
          if (partnersName.value != partnersUserInfo?.displayName && partnersUserInfo?.displayName != null) {
            // Update the ValueNotifier with current displayName.
            partnersName.value = partnersUserInfo!.displayName!;
          }
        } else {
          debugPrint("PartnersInfoState.setupPartnerInfoSubscription: Error: Not linked to that partner.");
          _partnersInfo = null;
        }
        notifyListeners();
      });
    }
  }

  /// Setups local data for a new partner.
  void addPartner(UserInformation? newPartnerInfo, UserInformation currentUserInfo) {
    if (newPartnerInfo != null) {
      _partnersInfo = newPartnerInfo;
      partnersName.value = newPartnerInfo.displayName ?? defaultPartnerName;
      setupPartnerInfoSubscription(currentUserInfo);
      notifyListeners();
    }
  }

  /// Removes local data for current partner.
  void removePartner(UserInformation? currentUserInfo) {
    _partnersInfo = null;
    _partnersInfoSubscription?.cancel();
    currentUserInfo?.linkPending = false;
    currentUserInfo?.partner = null;
    notifyListeners();
  }
}
