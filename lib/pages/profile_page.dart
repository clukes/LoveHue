import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:relationship_bars/pages/sign_in_page.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/resources/authentication.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? partnerName = PartnersInfoState.instance.partnersInfo?.displayName;
    return ProfileScreen(
      providerConfigs: [],
      actions: [
        SignedOutAction((context) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ));
        }),
      ],
      children: [
        (partnerName != null)
            ? Center(child: Text('Linked with: $partnerName'))
            : const SizedBox.shrink(),
        /* TODO: Unlink partner button */
        /* TODO: Add sign in button when anonymously signed in */
        /* TODO: Add clearer sign out button */
      ],
    );
  }
}
