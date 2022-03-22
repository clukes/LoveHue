import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/link_code.dart';
import '../models/relationship_bar_document.dart';
import '../models/user_information.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';

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
  // _loginState only changed in this class
  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;

  final UserInfoState userInfoState;
  final PartnersInfoState partnersInfoState;
  final FirebaseFirestore firestore;

  /// Returns current [ApplicationLoginState].
  ApplicationLoginState get loginState => _loginState;

  /// Setups app state on startup. Setups listener for [FirebaseAuth.userChanges], dealing with login.
  ApplicationState(this.userInfoState, this.partnersInfoState, this.firestore) {
    _setupUserChangersListener();
  }

  void _setupUserChangersListener() {
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null && _loginState == ApplicationLoginState.loggedOut) {
        // The user has logged in, so run setup.
        await userLoggedInSetup(user);
        notifyListeners();
      } else if (user != null && _loginState == ApplicationLoginState.loggedIn) {
        // When something changes while user is logged in.
        if (userInfoState.userExist && user.displayName != userInfoState.userInfo?.displayName) {
          // If user display name has changed, update their userInfo display name in database.
          await userInfoState.userInfo?.firestoreUpdateColumns({UserInformation.columnDisplayName: user.displayName});
        }
      } else if (user == null && _loginState == ApplicationLoginState.loggedIn) {
        // If user has been logged out, reset.
        resetAppState();
        notifyListeners();
      }
    });
  }

  /// Setups app state on user login.
  ///
  /// Sets [ApplicationLoginState.loading] until it is finished.
  /// Sets [ApplicationLoginState.loggedIn] on finish.
  Future<void> userLoggedInSetup(User user) async {
    _loginState = ApplicationLoginState.loading;

    // Retrieve userInfo if not locally stored.
    UserInformation? userInfo = userInfoState.userInfo ?? await UserInformation.firestoreGet(user.uid, firestore);
    if (userInfo == null) {
      // If there is no UserInformation in the database for the current user, i.e. they are a new user, setup their data.
      DocumentReference<LinkCode?> linkCode = await LinkCode.create(firestore);
      userInfo = UserInformation(userID: user.uid, displayName: user.displayName, linkCode: linkCode, firestore: firestore);
      debugPrint("ApplicationState.userLoggedInSetup: New user setup: $userInfo.");

      DocumentReference<UserInformation?> userDoc = userInfo.getUserInDatabase();
      await userInfo.setupUserInDatabase(userDoc, linkCode, userInfoState);
    }
    if (userInfo.partnerID != null) {
      partnersInfoState.addPartner(await UserInformation.firestoreGet(userInfo.partnerID!, firestore), userInfo);
    }
    userInfoState.latestRelationshipBarDoc ??= await RelationshipBarDocument.firestoreGetLatest(userInfo.userID, firestore);
    userInfoState.addUser(userInfo);
    _loginState = ApplicationLoginState.loggedIn;
    userInfoState.notifyListeners();
  }

  /// Sets app state variables to null on user logout.
  ///
  /// Sets [ApplicationLoginState.loading] until it is finished.
  /// Sets [ApplicationLoginState.loggedOut] on finish.
  void resetAppState() {
    _loginState = ApplicationLoginState.loading;
    partnersInfoState.removePartner(userInfoState.userInfo);
    userInfoState.removeUser();
    _loginState = ApplicationLoginState.loggedOut;
  }
}
