import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:relationship_bars/pages/sign_in_page.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';
import 'package:relationship_bars/widgets/settings_page_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PartnersInfoState partnersInfoState = PartnersInfoState.instance;
    String partnerName = partnersInfoState.partnersInfo?.displayName  ?? '(No Name)';
    return ProfileScreen(
      avatarSize: 0,
      providerConfigs: const [],
      actions: [
        SignedOutAction((context) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ));
        }),
      ],
      children: [
        const SizedBox(height: 100),
        if (partnersInfoState.partnerExist && !(partnersInfoState.partnerPending || UserInfoState.instance.userPending)) ...[
          Center(child: Text('Linked with: $partnerName')),
          const SizedBox(height: 20),
          //TODO: Confirmation message on unlink button press
          OutlinedButton.icon(onPressed: () => showUnlinkAlertDialog(context, partnerName, partnersInfoState.linkCode!), icon: const Icon(Icons.person_remove), label: const Text('Unlink Partner')),
        ],
        const SizedBox(height: 50),
        //TODO: About dialog
        OutlinedButton.icon(onPressed: () => showAboutDialog(context: context), icon: const Icon(Icons.info), label: const Text('About this app')),
        const SizedBox(height: 30),
        const SignOutButton(),
        const SizedBox(height: 30-16),
        /* TODO: Add sign in button when anonymously signed in */
        /* TODO: Add clearer sign out button */
        /* TODO: Delete account functionality. Have confirmation popup. */
      ],
    );
  }
}
