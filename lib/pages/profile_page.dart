import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';
import '../pages/sign_in_page.dart';
import '../providers/application_state.dart';
import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../resources/printable_error.dart';
import '../widgets/constrained_scaffold.dart';
import '../widgets/profile_page_widgets.dart';

const partnerNamePlaceholder = 'No name';

/// Profile Page, which was adapted from flutterfire_ui [ProfileScreen].
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _signOut(BuildContext context, FirebaseAuth auth) async {
    await auth
        .signOut()
        .then(await Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SignInPage(),
        )));
  }

  @override
  Widget build(BuildContext context) {
    ApplicationState appState =
        Provider.of<ApplicationState>(context, listen: false);

    final FirebaseAuth auth = appState.auth;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Center(child: EditableUserDisplayName(auth: auth)),
        const SizedBox(height: 32),
        Consumer<PartnersInfoState>(builder:
            (BuildContext context, PartnersInfoState partnersInfoState, _) {
          // Consumer that gives a column if partner linked, or just an empty SizedBox otherwise.
          if (partnersInfoState.partnerExist &&
              !(partnersInfoState.partnerPending ||
                  Provider.of<UserInfoState>(context, listen: false)
                      .userPending)) {
            String partnerName = partnersInfoState.partnersInfo?.displayName ??
                partnerNamePlaceholder;
            return Column(children: [
              Center(child: Text('Linked with: $partnerName')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                // Unlink Partner Button
                child: OutlinedButton.icon(
                    onPressed: () => UnlinkAlertDialog().show(
                        context, partnerName, partnersInfoState.linkCode!),
                    icon: const Icon(Icons.person_remove),
                    label: const Text('Unlink Partner')),
              ),
            ]);
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 64),
        ElevatedButton.icon(
            onPressed: () async => await _signOut(context, auth),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out')),
        const SizedBox(height: 24),
        if (auth.currentUser?.isAnonymous == true && !kIsWeb)
          OutlinedButton.icon(
              onPressed: () async => await convertAnonToEmailLink(context, auth,
                  appState), //TODO: Add this back in when convertAnonToEmailLink done.
              icon: const Icon(Icons.email),
              label: const Text('Sign In With Email')),
      ],
    );

    return FlutterFireUIActions(
      actions: [
        SignedOutAction((context) {
          // Called after account deleted, just navigate to SignInPage.
          debugPrint("ProfilePage: Signed Out.");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ));
        }),
      ],
      child: Builder(
        builder: (context) => ConstrainedScaffold(
          title: const Text("Account"),
          actions: [
            IconButton(
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

Future<void> convertAnonToEmailLink(
    BuildContext context, FirebaseAuth auth, ApplicationState appState) async {
  //TODO: Finish implementing this. Test some more, figure out what happens if account exists with email and doesn't exist with email. What happens to users current data?

  if (auth.currentUser == null || auth.currentUser?.isAnonymous != true) {
    throw PrintableError("No anonymous user");
  }

  var emailTypes = appState.authenticationInfo.providerConfigs
      .whereType<EmailLinkProviderConfiguration>();
  if (emailTypes.isEmpty) {
    throw PrintableError("No email link provider configuration");
  }

  EmailLinkProviderConfiguration emailLinkConfig = emailTypes.first;
  await showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      contentPadding: const EdgeInsets.all(10),
      children: [
        EmailLinkSignInView(
          auth: auth,
          config: emailLinkConfig,
        )
      ],
    ),
  );
}
