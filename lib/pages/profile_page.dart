import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/pages/sign_in_page.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';
import 'package:relationship_bars/widgets/profile_page_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Consumer<PartnersInfoState>(builder: (BuildContext context, PartnersInfoState partnersInfoState, _) {
          if (partnersInfoState.partnerExist &&
              !(partnersInfoState.partnerPending || UserInfoState.instance.userPending)) {
            String partnerName = partnersInfoState.partnersInfo?.displayName ?? '(No Name)';
            return Column(children: [
              Center(child: Text('Linked with: $partnerName')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                    onPressed: () => showUnlinkAlertDialog(context, partnerName, partnersInfoState.linkCode!),
                    icon: const Icon(Icons.person_remove),
                    label: const Text('Unlink Partner')),
              ),
            ]);
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 50),
        //TODO: About dialog
        OutlinedButton.icon(
            onPressed: () => showAboutDialog(context: context),
            icon: const Icon(Icons.info),
            label: const Text('About this app')),
        const SizedBox(height: 30),
        const SignOutButton(),
        const SizedBox(height: 30 - 16),
        /* TODO: Add sign in button when anonymously signed in */
        /* TODO: Delete account functionality. Have confirmation popup. */
      ],
    );
  }
}
