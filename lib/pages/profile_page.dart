import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/pages/sign_in_page.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';
import 'package:relationship_bars/widgets/profile_page_widgets.dart';

import '../resources/authentication.dart';
import '../utils/colors.dart';

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

  Future<bool> _reauthenticate(BuildContext context) {
    return showReauthenticateDialog(
      context: context,
      providerConfigs: providerConfigs,
      auth: _auth,
      onSignedIn: () => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

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
        //TODO: About dialog
        OutlinedButton.icon(
            onPressed: () => showAboutDialog(context: context),
            icon: const Icon(Icons.info),
            label: const Text('About this app')),
        const SizedBox(height: 24),
        ElevatedButton.icon(
            onPressed: () async => await _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out')),
        /* TODO: Add sign in button when anonymously signed in */
        /* TODO: Delete account functionality. Have confirmation popup. */
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(primary: redColor),
            onPressed: () => showDeleteAlertDialog(context),
            icon: const Icon(Icons.delete),
            label: const Text('Delete Account')),
      ],
    );

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: content,
              );
            } else {
              return content;
            }
          },
        ),
      ),
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
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l.profile),
            actions: [
              IconButton(
                //TODO: Navigate to settings page
                onPressed: () => {},
                icon: const Icon(
                  Icons.settings,
                ),
              )
            ],
          ),
          body: SafeArea(child: SingleChildScrollView(child: body)),
        ),
      ),
    );
  }
}
