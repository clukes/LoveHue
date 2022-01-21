import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:relationship_bars/Pages/your_bars_page.dart';
import 'package:relationship_bars/database/local_database_handler.dart';
import 'package:relationship_bars/database/secure_storage_handler.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/models/userinfo_firestore_collection_model.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';

import '../firebase_options.dart';
import '../resources/authentication.dart';


enum ApplicationLoginState {
  loggedOut,
  loggedIn,
}

class ApplicationState extends ChangeNotifier {
  static final ApplicationState _instance = ApplicationState._internal();

  static ApplicationState get instance => _instance;

  ApplicationState._internal();
  factory ApplicationState() => _instance;

  Future<void> init() async {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _userInfo ??= await UserInformation.firestoreGet(user.uid);
        if(_userInfo == null) {
          _userInfo = UserInformation(userID: user.uid, displayName: user.displayName);
          await _userInfo!.firestoreSet();
          await RelationshipBar.firestoreAddMap(_userInfo!.userID, defaultBarLabels);
        }
        print(_userInfo);
        print(_userInfo?.userID);
        _setupPartnerInfoSubscription(_userInfo?.partnerID);
        YourBarsState.instance.yourRelationshipBars ??= await RelationshipBar.firestoreGetBars(userID!);
        notifyListeners();
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _userInfo = null;
        _partnersInfo = null;
        _partnersInfoSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  UserInformation? _userInfo;
  UserInformation? get userInfo => _userInfo;
  String? get userID => _userInfo?.userID;

  StreamSubscription<DocumentSnapshot>? _partnersInfoSubscription;
  UserInformation? _partnersInfo;
  UserInformation? get partnersInfo => _userInfo;
  String? get partnersID => _partnersInfo?.userID;

  void _setupPartnerInfoSubscription(String? partnerID) {
    print(partnerID);
    if (partnerID != null) {
      _partnersInfoSubscription = userInfoFirestoreRef
          .doc(partnerID)
          .snapshots()
          .listen((snapshot) {
            print("PARTNER INFO");
            UserInformation? partnersInfo = snapshot.data();
            if(partnersInfo?.partnerID == userID) {
               _partnersInfo = partnersInfo;
            }
            else {
              print("Error: Not linked to partner");
            }
          });
    }
  }
}
    // Future<void> _setupPartnerBarsSubscription() async {
    // //ONLY LISTEN TO LOCAL CHANGES
    //   userInfoFirestoreRef
    //       .doc(partnersID).listen((snapshot) {
    //   snapshot.docChanges.forEach((res) {
    //     if (res.type == DocumentChangeType.added) {
    //       _partnersRelationshipBars.add(res.);
    //     }
    //     if (res.type == DocumentChangeType.modified) {
    //
    //     }
    //     if (res.type == DocumentChangeType.removed) {
    //       _partnersRelationshipBars.remove();
    //     }
    //   }
    //   );
    // }
    // );




          // void startLoginFlow() {
  //   _loginState = ApplicationLoginState.emailAddress;
  //   notifyListeners();
  // }
  //
  // Future<void> verifyEmail(
  //   String email,
  //   void Function(FirebaseAuthException e) errorCallback,
  // ) async {
  //   if(!_isSendingDynamicLink) {
  //     try {
  //       _isSendingDynamicLink = true;
  //       /* TODO: Show loading indicator when sending email */
  //       await FirebaseAuth.instance
  //           .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
  //           .then((value) =>
  //           print('Successfully sent email verification to $email'));
  //       SecureStorageHandler.getInstance().write(key: emailAddressSecureStorageKey, value: email);
  //       _loginState = ApplicationLoginState.awaitEmailLink;
  //       _email = email;
  //       notifyListeners();
  //     } on FirebaseAuthException catch (e) {
  //       errorCallback(e);
  //     } finally {
  //       _isSendingDynamicLink = false;
  //     }
  //   }
  // }
  //
  // /* TODO: FIX MULTIPLE ERRORS POPPING UP ON ERRONEOUS LINK */
  // Future<void> signInWithEmailAndLink(
  //   String emailLink,
  //   void Function(FirebaseAuthException e) errorCallback,
  // ) async {
  //   print("EMAIL SIGN IN");
  //   var auth = FirebaseAuth.instance;
  //   if (auth.isSignInWithEmailLink(emailLink)) {
  //     String? email = await SecureStorageHandler.getInstance().read(key: emailAddressSecureStorageKey);
  //     if (email != null) {
  //       await auth
  //           .signInWithEmailLink(email: email, emailLink: emailLink)
  //           .then((value) {
  //         print('Successfully signed in with email link!');
  //       }).catchError((onError) {
  //         errorCallback(onError);
  //         print('Error signing in with email link $onError');
  //       });
  //     }
  //   }
  // }
  //
  // void cancelRegistration() {
  //   _loginState = ApplicationLoginState.emailAddress;
  //   notifyListeners();
  // }
  //
  // Future<void> signOut() async {
  //   await FirebaseAuth.instance.signOut();
  // }
  //
  // Future<void> initDynamicLinks() async {
  //   print("LISTENING");
  //
  //   FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
  //     print("LISTENED");
  //     await handleSignInDynamicLink(dynamicLinkData);
  //   }).onError((e) async {
  //     print('onLinkError');
  //     print(e.message);
  //   });
  // }
  //
  // Future<void> handleInitialDynamicLink() async {
  //   final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  //   if (initialLink != null) {
  //     await handleSignInDynamicLink(initialLink);
  //   }
  // }
  //
  // Future<void> handleSignInDynamicLink(PendingDynamicLinkData? dynamicLinkData) async {
  //   if (!_isHandlingLoginDynamicLink) {
  //     _isHandlingLoginDynamicLink = true;
  //     errorCallback(e) => print(e); /* TODO: DISPLAY ERROR IN APP */
  //     if (dynamicLinkData?.link != null) {
  //       await signInWithEmailAndLink(
  //           dynamicLinkData!.link.toString(), errorCallback);
  //     }
  //     _isHandlingLoginDynamicLink = false;
  //   }
  // }
  //
