import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/models/userinfo_firestore_collection_model.dart';
import 'package:relationship_bars/providers/application_state.dart';

class PartnersInfoState extends ChangeNotifier {
  static final PartnersInfoState _instance = PartnersInfoState._internal();

  static PartnersInfoState get instance => _instance;

  PartnersInfoState._internal();
  factory PartnersInfoState() => _instance;

  StreamSubscription<DocumentSnapshot>? partnersInfoSubscription;
  UserInformation? _partnersInfo;
  set partnersInfo(UserInformation? info) {
    _partnersInfo = info;
    print("NOTIFY PARTNER");
    notifyListeners();
  }
  UserInformation? get partnersInfo => _partnersInfo;
  String? get partnersID => partnersInfo?.userID;


  void setupPartnerInfoSubscription() {
    print(partnersID);
    if (partnersID != null) {
      partnersInfoSubscription = userInfoFirestoreRef
          .doc(partnersID)
          .snapshots()
          .listen((snapshot) {
        print("PARTNER INFO");
        UserInformation? partnersUserInfo = snapshot.data();
        print(partnersUserInfo?.partnerID);
        print(partnersInfo);
        if(partnersUserInfo?.partnerID == ApplicationState.instance.userID) {
          partnersInfo = partnersUserInfo;
        }
        else {
          print("Error: Not linked to partner");
        }
      });
    }
  }
}
