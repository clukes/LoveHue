import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../main_common.dart';
import '../resources/authentication_info.dart';
import '../utils/globals.dart';

/// SignIn Page, using flutterfire_ui [SignInScreen].
class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AspectRatio logo = const AspectRatio(
      aspectRatio: 1,
      child: Image(
        image: appTextLogo,
      ),
    );
    debugPrint("${globalAuthenticationInfo.actionCodeSettings.androidPackageName}");
    return SignInScreen(
      headerMaxExtent: 200,
      headerBuilder: (context, constraints, _) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: logo,
        );
      },
      sideBuilder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: logo,
        );
      },
      subtitleBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Welcome to ${appInfo.appName}.'),
        );
      },
      footerBuilder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(children: const [
                if (!kIsWeb)
                  Text(
                      'You can use magic link to sign in with a verification link sent to your email, no password required.\n'),
                Text(
                  'By using this app, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              ]),
            ),
            const SizedBox(height: 70),
            const Divider(
              height: 8,
              thickness: 1,
              color: Colors.grey,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async => await globalAuthenticationInfo.signInAnonymously(context, FirebaseAuth.instance),
                    child: const Text('Skip Login'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: const Text(
                    'If you choose not to log in, you cannot sync data across devices. However, you can still create an account later.',
                    textScaleFactor: 0.9,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 8,
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        );
      },
      providerConfigs: globalAuthenticationInfo.providerConfigs,
      actions: [
        AuthStateChangeAction<SignedIn>((context, _) async {
          globalAuthenticationInfo.afterSignIn(context);
        }),
      ],
      showAuthActionSwitch: false,
    );
  }
}
