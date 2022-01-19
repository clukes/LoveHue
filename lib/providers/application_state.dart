import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:relationship_bars/Database/relationship_bar_model.dart';
import 'package:relationship_bars/Pages/your_bars_page.dart';

import '../resources/firebase_options.dart';
import '../resources/authentication.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      /* TODO: PREVENT DOUBLE EMAIL SENDING */
      await FirebaseAuth.instance
          .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
          .then((value) => print('Successfully sent email verification to $email'));
      _loginState = ApplicationLoginState.awaitEmailLink;
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  /* TODO: FIX MULTIPLE ERRORS POPPING UP ON ERRONEOUS LINK */
  Future<void> signInWithEmailAndLink(String emailLink,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    print("EMAIL SIGN IN");
      var auth = FirebaseAuth.instance;
      if (auth.isSignInWithEmailLink(emailLink)) {
        await auth
            .signInWithEmailLink(email: _email!, emailLink: emailLink)
            .then((value) {
          print('Successfully signed in with email link!');
        }).catchError((onError) {
          errorCallback(onError);
          print('Error signing in with email link $onError');
        });
      }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
