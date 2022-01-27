import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/models/link_code_firestore_collection_model.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/models/userinfo_firestore_collection_model.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/resources/unique_link_code_generator.dart';

enum ApplicationLoginState {
  loggedOut,
  loading,
  loggedIn,
}

class ApplicationState extends ChangeNotifier {
  static final ApplicationState _instance = ApplicationState._internal();

  static ApplicationState get instance => _instance;

  ApplicationState._internal();
  factory ApplicationState() => _instance;

  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) async {
      print("CHANGE");
      if (user != null && _loginState != ApplicationLoginState.loggedIn) {
        _loginState = ApplicationLoginState.loading;
        userInfo ??= await UserInformation.firestoreGet(user.uid);
        if(userInfo == null) {
          print("NULL USERINFO");
          DocumentReference<LinkCode?>? linkCode;
          while(linkCode == null) {
            linkCode = await linkCodeFirestoreRef.doc(generateLinkCode()).get().then((snapshot) => !snapshot.exists ? snapshot.reference: null);
          }
          userInfo = UserInformation(userID: user.uid, displayName: user.displayName, linkCode: linkCode);
          print("USERINFO: $userInfo");
          DocumentReference<UserInformation?> userDoc = userInfoFirestoreRef.doc(userInfo?.userID);
          WriteBatch batch = FirebaseFirestore.instance.batch();
          batch.set(userDoc, userInfo);
          batch.set(linkCode, LinkCode(linkCode: linkCode.id, user: userDoc));
          YourBarsState.instance.latestRelationshipBarDoc = RelationshipBarDocument.firestoreAddBarListWithBatch(userInfo!.userID, RelationshipBar.listFromLabels(defaultBarLabels), batch);
          await batch.commit().catchError((error) => print("Batch Error: $error"));
        }
        if(userInfo?.partnerID != null) {
          PartnersInfoState.instance.partnersInfo = await UserInformation.firestoreGet(userInfo!.partnerID!);
        }
        PartnersInfoState.instance.setupPartnerInfoSubscription();
        YourBarsState.instance.latestRelationshipBarDoc ??= await RelationshipBarDocument.firestoreGetLatest(userID!);
        _loginState = ApplicationLoginState.loggedIn;
        notifyListeners();
      } else if(_loginState != ApplicationLoginState.loggedIn) {
        _loginState = ApplicationLoginState.loading;
        userInfo = null;
        PartnersInfoState.instance.partnersInfo = null;
        PartnersInfoState.instance.partnersInfoSubscription?.cancel();
        _loginState = ApplicationLoginState.loggedOut;
        notifyListeners();
      }
      print("NOTIFY APP");
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  UserInformation? userInfo;
  String? get userID => userInfo?.userID;
  String? get linkCode => userInfo?.linkCode?.id;
}