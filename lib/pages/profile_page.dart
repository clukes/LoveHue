import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:relationship_bars/resources/authentication.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      providerConfigs: providerConfigs,
      actions: [
        SignedOutAction((context) {
          Navigator.pushReplacementNamed(context, '/login');
        }),
      ],
    );
  }
}