import 'package:flutter/material.dart';

import '../main_common.dart';
import '../utils/colors.dart';
import '../utils/globals.dart';
import '../widgets/default_scaffold.dart';
import '../widgets/profile_page_widgets.dart';

/// Shows the about dialog with the info about this app.
Future<void> aboutAppDialog(BuildContext context) async {
  final double iconSize = IconTheme.of(context).size ?? 20;
  showAboutDialog(context: context,
    applicationName: appInfo.appName,
    applicationVersion: packageInfo.version,
    applicationIcon: Center(child: Image(image: appLogo, width: iconSize*3,)), //TODO: Make better icon logo.
    applicationLegalese: "Copyright © 2022 Conner Lukes", //TODO: Change this to a different name.
    children: [const SizedBox(height: 8), Text(appInfo.aboutText)], //TODO: Write about.
    // routeSettings: ,
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        // TODO: Write about dialog.
        OutlinedButton.icon(
            onPressed: () async => await aboutAppDialog(context),
            icon: const Icon(Icons.info),
            label: const Text('About this app')),
        const SizedBox(height: 32),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(primary: redColor),
            onPressed: () => showDeleteAlertDialog(context),
            icon: const Icon(Icons.delete),
            label: const Text('Delete Account')),
      ],
    );
    return DefaultScaffold(
      title: const Text("Settings"),
      content: content,
    );
  }
}
