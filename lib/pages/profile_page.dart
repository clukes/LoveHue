import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:relationship_bars/pages/sign_in_page.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? partnerName = PartnersInfoState.instance.partnersInfo?.displayName;
    return ProfileScreen(
      providerConfigs: const [],
      actions: [
        SignedOutAction((context) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ));
        }),
      ],
      children: [
        (PartnersInfoState.instance.partnerExist && !(PartnersInfoState.instance.partnerPending || UserInfoState.instance.userPending))
            ? Center(child: Text('Linked with: ${partnerName ?? '(No Name)'}'))
            : const SizedBox.shrink(),
        /* TODO: Unlink partner button */
        /* TODO: Add sign in button when anonymously signed in */
        /* TODO: Add clearer sign out button */
      ],
    );
  }
}
