// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_common.dart';
import '../providers/application_state.dart';
import '../resources/authentication_info.dart';
import '../utils/app_info_class.dart';
import '../utils/colors.dart';
import '../utils/globals.dart';
import '../widgets/constrained_scaffold.dart';
import '../widgets/profile_page_widgets.dart';

/// Shows the about dialog with the info about this app.
Future<void> showAboutAppDialog(BuildContext context, AppInfo appInfo,
    AuthenticationInfo authenticationInfo) async {
  final double iconSize = IconTheme.of(context).size ?? 20;
  showAboutDialog(
    context: context,
    applicationName: appInfo.appName,
    applicationVersion: authenticationInfo.packageInfo.version,
    applicationIcon: Center(
        child: Image(
      image: appLogo,
      width: iconSize * 3,
    )),
    applicationLegalese: "Copyright © 2022 Conner Lukes",
    //TODO: Change this to developer name.
    children: [const SizedBox(height: 8), Text(appInfo.aboutText)],
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ApplicationState appState =
        Provider.of<ApplicationState>(context, listen: false);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        OutlinedButton.icon(
            onPressed: () async => await showAboutAppDialog(
                context, appState.appInfo, appState.authenticationInfo),
            icon: const Icon(Icons.info),
            label: const Text('About this app')),
        const SizedBox(height: 32),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: redColor),
            onPressed: () => DeleteAlertDialog(appState.auth,
                    appState.authenticationInfo, appState.notificationService)
                .show(context),
            icon: const Icon(Icons.delete),
            label: const Text('Delete Account')),
      ],
    );
    return ConstrainedScaffold(
      title: const Text("Settings"),
      content: content,
    );
  }
}
