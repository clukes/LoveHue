import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/models/link_code_firestore_collection_model.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/models/userinfo_firestore_collection_model.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/resources/unique_link_code_generator.dart';

enum ApplicationLoginState {
  loggedOut,
  loading,
  loggedIn,
}

class ApplicationState with ChangeNotifier {
  static final ApplicationState _instance = ApplicationState._internal();

  static ApplicationState get instance => _instance;

  ApplicationState._internal();
  factory ApplicationState() => _instance;

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) async {
      UserInfoState userInfoState = UserInfoState.instance;
      PartnersInfoState partnerInfoState = PartnersInfoState.instance;
      print("CHANGE");
      if (user != null && _loginState == ApplicationLoginState.loggedOut) {
        await userLoggedInSetup(user, userInfoState, partnerInfoState);
        notifyListeners();
      } else if(user != null && _loginState == ApplicationLoginState.loggedIn) {
        //When something changes while user is logged in.
        if(userInfoState.userExist && user.displayName != userInfoState.userInfo?.displayName) {
          //When user display name changes, update their userInfo display name.
          await UserInformation.firestoreUpdateColumns(userInfoState.userID!, {UserInformation.columnDisplayName: user.displayName});
        }
      } else if (user == null && _loginState == ApplicationLoginState.loggedIn) {
        resetAppState(userInfoState, partnerInfoState);
        notifyListeners();
      }
      print("NOTIFY APP");
    });
  }

  Future<void> userLoggedInSetup(User user, UserInfoState userInfoState, PartnersInfoState partnerInfoState) async {
    _loginState = ApplicationLoginState.loading;

    UserInformation? userInfo = userInfoState.userInfo ?? await UserInformation.firestoreGet(user.uid);
    if (userInfo == null) {
      print("NULL USERINFO");
      DocumentReference<LinkCode?>? linkCode;
      while (linkCode == null) {
        linkCode = await linkCodeFirestoreRef
            .doc(generateLinkCode())
            .get()
            .then((snapshot) => !snapshot.exists ? snapshot.reference : null);
      }
      userInfo = UserInformation(userID: user.uid, displayName: user.displayName, linkCode: linkCode);
      print("USERINFO: $userInfo");
      DocumentReference<UserInformation?> userDoc = userInfoFirestoreRef.doc(userInfo.userID);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(userDoc, userInfo);
      batch.set(linkCode, LinkCode(linkCode: linkCode.id, user: userDoc));
      YourBarsState.instance.latestRelationshipBarDoc = RelationshipBarDocument.firestoreAddBarListWithBatch(
          userInfo.userID, RelationshipBar.listFromLabels(defaultBarLabels), batch);
      await batch.commit().catchError((error) => print("Batch Error: $error"));
    }
    if (userInfo.partnerID != null) {
      partnerInfoState.addPartner(await UserInformation.firestoreGet(userInfo.partnerID!));
    }
    YourBarsState.instance.latestRelationshipBarDoc ??=
        await RelationshipBarDocument.firestoreGetLatest(userInfo.userID);
    userInfoState.addUser(userInfo);
    _loginState = ApplicationLoginState.loggedIn;
  }

  void resetAppState(UserInfoState userInfoState, PartnersInfoState partnerInfoState) {
    _loginState = ApplicationLoginState.loading;
    partnerInfoState.removePartner();
    userInfoState.removeUser();
    _loginState = ApplicationLoginState.loggedOut;
  }
}
