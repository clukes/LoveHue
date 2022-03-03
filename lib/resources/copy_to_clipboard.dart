import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copies given text to device clipboard.
Future<void> copyToClipboard(String? copyText, BuildContext context) async {
  await Clipboard.setData(ClipboardData(text: copyText)).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Copied to clipboard"),
      duration: Duration(seconds: 2),
    ));
  });
}
