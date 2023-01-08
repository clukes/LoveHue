// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../main_common.dart';
import '../responsive/responsive_screen_layout.dart';

class AuthenticationInfo {
  AuthenticationInfo(this.packageInfo) {
    actionCodeSettings = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
      url: 'http://lovehue.page.link/',
      // This must be true
      handleCodeInApp: true,
      // installIfNotAvailable
      androidInstallApp: true,
      androidPackageName: packageInfo.packageName,
      iOSBundleId: packageInfo.packageName,
    );

    providers = <AuthProvider>[
      EmailLinkAuthProvider(actionCodeSettings: actionCodeSettings)
    ];
  }

  /// [ActionCodeSettings] for the email link login.
  late final ActionCodeSettings actionCodeSettings;

  /// Info with app metadata.
  late final PackageInfo packageInfo;

  /// Configs for different auth providers.
  late final List<AuthProvider> providers;

  /// Sets the providers in FirebaseUIAuth.
  void setProviders() => FirebaseUIAuth.configureProviders(providers);

  /// Implements [signInAnonymously] to allow sign in without email.
  /// navigator is Navigator.of(context)
  Future<void> signInAnonymously(
      NavigatorState navigator, FirebaseAuth auth) async {
/* TODO: HAVE LOADING OVERLAY */
    await auth.signInAnonymously();
    if (auth.currentUser != null) {
      afterSignIn(navigator);
    } else {
/* TODO: Display Error */
      debugPrint("signInAnonymously: Sign In Error.");
    }
  }

  /// Build and navigate to [ResponsiveLayout].
  /// navigator is Navigator.of(context)
  void afterSignIn(NavigatorState navigator) {
    navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => responsiveLayout), (route) => false);
  }

  Future<bool> reauthenticate(BuildContext context, FirebaseAuth auth,
      {ReauthenticateHelper? helper}) {
    User? user = auth.currentUser;
    if (user == null) {
      throw PrintableError("No current user.");
    }
    helper ??= ReauthenticateHelper();
    return helper.showDialog(context, auth, providers);
  }
}

class ReauthenticateHelper {
  Future<bool> showDialog(BuildContext context, FirebaseAuth auth,
          List<AuthProvider> providers) =>
      showReauthenticateDialog(
        context: context,
        providers: providers,
        auth: auth,
        onSignedIn: () => Navigator.of(context).pop(true),
      );
}
