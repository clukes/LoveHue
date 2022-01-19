import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:relationship_bars/Pages/your_bars_page.dart';
import 'package:relationship_bars/resources/email_storage.dart';

import '../resources/firebase_options.dart';
import '../resources/authentication.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    secureEmailStore = EmailSecureStore(flutterSecureStorage: secureStorage);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    initDynamicLinks();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
      notifyListeners();
    });
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      handleSignInDynamicLink(initialLink);
    }
  }
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late EmailSecureStore secureEmailStore;
  bool _isSendingDynamicLink = false;
  bool _isHandlingLoginDynamicLink = false;

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
    if(!_isSendingDynamicLink) {
      try {
        _isSendingDynamicLink = true;
        /* TODO: Show loading indicator when sending email */
        await FirebaseAuth.instance
            .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
            .then((value) =>
            print('Successfully sent email verification to $email'));
        secureEmailStore.setEmail(email);
        _loginState = ApplicationLoginState.awaitEmailLink;
        _email = email;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        errorCallback(e);
      } finally {
        _isSendingDynamicLink = false;
      }
    }
  }

  /* TODO: FIX MULTIPLE ERRORS POPPING UP ON ERRONEOUS LINK */
  Future<void> signInWithEmailAndLink(
    String emailLink,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    print("EMAIL SIGN IN");
    var auth = FirebaseAuth.instance;
    if (auth.isSignInWithEmailLink(emailLink)) {
      String? email = await secureEmailStore.getEmail();
      if (email != null) {
        await auth
            .signInWithEmailLink(email: email, emailLink: emailLink)
            .then((value) {
          print('Successfully signed in with email link!');
        }).catchError((onError) {
          errorCallback(onError);
          print('Error signing in with email link $onError');
        });
      }
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> initDynamicLinks() async {
    print("LISTENING");

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      print("LISTENED");
      await handleSignInDynamicLink(dynamicLinkData);
    }).onError((e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  Future<void> handleSignInDynamicLink(PendingDynamicLinkData? dynamicLinkData) async {
    if (!_isHandlingLoginDynamicLink) {
      _isHandlingLoginDynamicLink = true;
      errorCallback(e) => print(e); /* TODO: DISPLAY ERROR IN APP */
      if (dynamicLinkData?.link != null) {
        await signInWithEmailAndLink(
            dynamicLinkData!.link.toString(), errorCallback);
      }
      _isHandlingLoginDynamicLink = false;
    }
  }
}
