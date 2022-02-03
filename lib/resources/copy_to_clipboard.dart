import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyToClipboard(String? copyText, BuildContext context) async {
  await Clipboard.setData(ClipboardData(text: copyText)).then((_){
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copied to clipboard"),
          duration: Duration(seconds: 2),
        )
    );
  });
}
