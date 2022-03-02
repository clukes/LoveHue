import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/userinfo_firestore_collection_model.dart';
import '../providers/user_info_state.dart';

class PartnersInfoState with ChangeNotifier {
  static final PartnersInfoState _instance = PartnersInfoState._internal();

  static PartnersInfoState get instance => _instance;

  PartnersInfoState._internal();
  factory PartnersInfoState() => _instance;

  StreamSubscription<DocumentSnapshot>? partnersInfoSubscription;
  UserInformation? _partnersInfo;

  void notify() {
    print("NOTIFY PARTNER");
    notifyListeners();
  }

  UserInformation? get partnersInfo => _partnersInfo;
  String? get partnersID => _partnersInfo?.userID;
  String? get linkCode => _partnersInfo?.linkCode.id;
  bool get partnerExist => (_partnersInfo?.userID != null);
  bool get partnerLinked =>
      (partnerExist && !(_partnersInfo?.linkPending ?? true) && !UserInfoState.instance.userPending);
  bool get partnerPending => (partnerExist && (_partnersInfo?.linkPending ?? false));
  ValueNotifier<String> partnersName = ValueNotifier<String>("Partner");

  void setupPartnerInfoSubscription() {
    print(partnersID);
    if (partnerExist) {
      partnersInfoSubscription = UserInformation.getUserFromID(partnersID).snapshots().listen((snapshot) {
        print("PARTNER INFO");
        UserInformation? partnersUserInfo = snapshot.data();
        print(partnersUserInfo?.partnerID);
        print(partnersInfo);
        if (UserInfoState.instance.userID != null && partnersUserInfo?.partnerID == UserInfoState.instance.userID) {
          _partnersInfo = partnersUserInfo;
          if (partnersName.value != partnersUserInfo?.displayName && partnersUserInfo?.displayName != null) {
            partnersName.value = partnersUserInfo!.displayName!;
          }
        } else {
          print("Error: Not linked to partner");
          _partnersInfo = null;
        }
        notifyListeners();
      });
    }
  }

  void addPartner(UserInformation? newPartnerInfo) {
    if (newPartnerInfo != null) {
      PartnersInfoState.instance._partnersInfo = newPartnerInfo;
      partnersName.value = newPartnerInfo.displayName ?? "Partner";
      PartnersInfoState.instance.setupPartnerInfoSubscription();
      notifyListeners();
    }
  }

  void removePartner() {
    PartnersInfoState.instance._partnersInfo = null;
    PartnersInfoState.instance.partnersInfoSubscription?.cancel();
    UserInfoState.instance.userInfo?.linkPending = false;
    UserInfoState.instance.userInfo?.partner = null;
    notifyListeners();
  }
}
