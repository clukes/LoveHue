import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfire_ui/auth.dart';

import '../resources/authentication.dart';

//TODO: LEFT OFF HERE, NEXT TO COMMENT/CLEANUP CODE.
class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      headerMaxExtent: 200,
      headerBuilder: (context, constraints, _) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset('assets/logo.svg'),
          ),
        );
      },
      sideBuilder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset('assets/logo.svg'),
          ),
        );
      },
      subtitleBuilder: (context, _) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Welcome to RelationshipApp!'),
        );
      },
      footerBuilder: (context, _) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'By signing in, you agree to our terms and conditions.',
                style: TextStyle(color: Colors.grey),
              ),
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
                    onPressed: () async => await signInAnonymously(context),
                    child: const Text('Skip Login'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: const Text(
                    'If you choose not to log in you can still create an account later.',
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
      providerConfigs: providerConfigs,
      actions: [
        AuthStateChangeAction<SignedIn>((context, _) async {
          print("Signed in");
          afterSignIn(context);
        }),
      ],
      showAuthActionSwitch: false,
    );
  }
}
