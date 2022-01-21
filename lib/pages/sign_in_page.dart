import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:relationship_bars/resources/authentication.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providerConfigs: providerConfigs,
      actions: [
        AuthStateChangeAction<SignedIn>((context, _) {
          Navigator.of(context).pushReplacementNamed('/profile');
        }),
      ],
      showAuthActionSwitch: false,
    );
  }
}
