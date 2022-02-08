import 'package:flutter/material.dart';
import 'package:relationship_bars/widgets/profile_page_widgets.dart';

import '../utils/colors.dart';
import '../widgets/default_scaffold.dart';

class SettingsPage extends StatelessWidget {

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //TODO: Theme switcher: Light/Dark/Follow device mode.
        const SizedBox(height: 32),
        //TODO: About dialog
        OutlinedButton.icon(
            onPressed: () => showAboutDialog(context: context),
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
