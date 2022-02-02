import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/models/userinfo_firestore_collection_model.dart';
import 'package:relationship_bars/providers/user_info_state.dart';

class PartnersInfoState with ChangeNotifier {
  static final PartnersInfoState _instance = PartnersInfoState._internal();

  static PartnersInfoState get instance => _instance;

  PartnersInfoState._internal();
  factory PartnersInfoState() => _instance;

  StreamSubscription<DocumentSnapshot>? partnersInfoSubscription;
  UserInformation? _partnersInfo;

  set partnersInfo(UserInformation? info) {
    _partnersInfo = info;
    partnersName.value = info?.displayName ?? "Partner";
    notify();
  }

  void notify() {
    print("NOTIFY PARTNER");
    notifyListeners();
  }

  UserInformation? get partnersInfo => _partnersInfo;
  String? get partnersID => _partnersInfo?.userID;
  String? get linkCode => _partnersInfo?.linkCode?.id;
  bool get partnerExist => (_partnersInfo?.userID != null);
  bool get partnerLinked => (partnerExist && !(_partnersInfo?.linkPending ?? true) && !UserInfoState.instance.userPending);
  bool get partnerPending => (partnerExist && (_partnersInfo?.linkPending ?? false));
  ValueNotifier<String> partnersName = ValueNotifier<String>("Partner");

  void setupPartnerInfoSubscription() {
    print(partnersID);
    if (partnerExist) {
      partnersInfoSubscription = userInfoFirestoreRef.doc(partnersID).snapshots().listen((snapshot) {
        print("PARTNER INFO");
        UserInformation? partnersUserInfo = snapshot.data();
        print(partnersUserInfo?.partnerID);
        print(partnersInfo);
        if (UserInfoState.instance.userID != null && partnersUserInfo?.partnerID == UserInfoState.instance.userID) {
          partnersInfo = partnersUserInfo;
        } else {
          print("Error: Not linked to partner");
          partnersInfo = null;
        }
      });
    }
  }
}
