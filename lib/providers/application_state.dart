import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/link_code_firestore_collection_model.dart';
import '../models/relationship_bar_model.dart';
import '../models/userinfo_firestore_collection_model.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../providers/your_bars_state.dart';
import '../utils/globals.dart';

/// The possible states of login: [loggedOut], [loading], [loggedIn].
enum ApplicationLoginState {
  loggedOut,

  /// Currently processing login/logout.
  loading,
  loggedIn,
}

/// Handles overall application state, including the [ApplicationLoginState].
///
/// Has [init] to setup app on startup.
class ApplicationState with ChangeNotifier {
  // Singleton pattern
  static final ApplicationState _instance = ApplicationState._internal();

  static ApplicationState get instance => _instance;

  ApplicationState._internal();

  factory ApplicationState() => _instance;

  // _loginState only changed in this class
  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;

  /// Returns current [ApplicationLoginState].
  ApplicationLoginState get loginState => _loginState;

  /// Setups app state on startup. Setups listener for [FirebaseAuth.userChanges], dealing with login.
  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) async {
      UserInfoState userInfoState = UserInfoState.instance;
      PartnersInfoState partnerInfoState = PartnersInfoState.instance;
      if (user != null && _loginState == ApplicationLoginState.loggedOut) {
        // The user has logged in, so run setup.
        await userLoggedInSetup(user, userInfoState, partnerInfoState);
        notifyListeners();
      } else if (user != null && _loginState == ApplicationLoginState.loggedIn) {
        // When something changes while user is logged in.
        if (userInfoState.userExist && user.displayName != userInfoState.userInfo?.displayName) {
          // If user display name has changed, update their userInfo display name in database.
          await UserInformation.firestoreUpdateColumns(
              userInfoState.userID!, {UserInformation.columnDisplayName: user.displayName});
        }
      } else if (user == null && _loginState == ApplicationLoginState.loggedIn) {
        // If user has been logged out, reset.
        resetAppState(userInfoState, partnerInfoState);
        notifyListeners();
      }
    });
  }

  /// Setups app state on user login.
  ///
  /// Sets [ApplicationLoginState.loading] until it is finished.
  /// Sets [ApplicationLoginState.loggedIn] on finish.
  Future<void> userLoggedInSetup(User user, UserInfoState userInfoState, PartnersInfoState partnerInfoState) async {
    _loginState = ApplicationLoginState.loading;

    // Retrieve userInfo if not locally stored.
    UserInformation? userInfo = userInfoState.userInfo ?? await UserInformation.firestoreGet(user.uid);
    if (userInfo == null) {
      // If there is no UserInformation in the database for the current user, i.e. they are a new user, setup their data.
      DocumentReference<LinkCode?> linkCode = await LinkCode.create();
      userInfo = UserInformation(userID: user.uid, displayName: user.displayName, linkCode: linkCode);
      debugPrint("ApplicationState.userLoggedInSetup: New user setup: $userInfo.");

      DocumentReference<UserInformation?> userDoc = UserInformation.getUserFromID(userInfo.userID);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(userDoc, userInfo);
      batch.set(linkCode, LinkCode(linkCode: linkCode.id, user: userDoc));
      // Setup default bars.
      YourBarsState.instance.latestRelationshipBarDoc = RelationshipBarDocument.firestoreAddBarListWithBatch(
          userInfo.userID, RelationshipBar.listFromLabels(defaultBarLabels), batch);
      await batch.commit().catchError((error) => debugPrint("ApplicationState.userLoggedInSetup: Batch Error: $error"));
    }
    if (userInfo.partnerID != null) {
      partnerInfoState.addPartner(await UserInformation.firestoreGet(userInfo.partnerID!));
    }
    YourBarsState.instance.latestRelationshipBarDoc ??=
        await RelationshipBarDocument.firestoreGetLatest(userInfo.userID);
    userInfoState.addUser(userInfo);
    _loginState = ApplicationLoginState.loggedIn;
    YourBarsState.instance.notifyListeners();
  }

  /// Sets app state variables to null on user logout.
  ///
  /// Sets [ApplicationLoginState.loading] until it is finished.
  /// Sets [ApplicationLoginState.loggedOut] on finish.
  void resetAppState(UserInfoState userInfoState, PartnersInfoState partnerInfoState) {
    _loginState = ApplicationLoginState.loading;
    partnerInfoState.removePartner();
    userInfoState.removeUser();
    _loginState = ApplicationLoginState.loggedOut;
  }
}
