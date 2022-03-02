import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';
import '../pages/sign_in_page.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../widgets/default_scaffold.dart';
import '../widgets/profile_page_widgets.dart';

//Sourced from flutterfire_ui ProfileScreen(). Edited code.
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const SignInPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Align(child: EditableUserDisplayName(auth: _auth)),
        const SizedBox(height: 32),
        Consumer<PartnersInfoState>(builder: (BuildContext context, PartnersInfoState partnersInfoState, _) {
          if (partnersInfoState.partnerExist &&
              !(partnersInfoState.partnerPending || UserInfoState.instance.userPending)) {
            String partnerName = partnersInfoState.partnersInfo?.displayName ?? '(No Name)';
            return Column(children: [
              Center(child: Text('Linked with: $partnerName')),
              const SizedBox(height: 16),
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
        const SizedBox(height: 64),
        ElevatedButton.icon(
            onPressed: () async => await _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out')),
        const SizedBox(height: 24),
        // if (FirebaseAuth.instance.currentUser?.isAnonymous == true)
        // OutlinedButton.icon(
        //     onPressed: null,//() async => await convertAnonSignInToEmail(context),    //TODO: Add sign in button when anonymously signed in, hopefully flutterfire ui will be updated soon to permit that easily
        //     icon: const Icon(Icons.email),
        //     label: const Text('Sign In With Email')),
      ],
    );

    return FlutterFireUIActions(
      actions: [
        SignedOutAction((context) {
          //Called on delete account button.
          print("Signed Out");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ));
        }),
      ],
      child: Builder(
        builder: (context) => DefaultScaffold(
          title: const Text("Account"),
          actions: [
            IconButton(
              //TODO: Navigate to settings page
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              )),
              icon: const Icon(
                Icons.settings,
              ),
            )
          ],
          content: content,
        ),
      ),
    );
  }
}
