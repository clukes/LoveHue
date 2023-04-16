import 'dart:io';

import 'package:flutter/foundation.dart';

takeScreenshot(tester, binding, name) async {
  if (Platform.isAndroid) {
    try {
      await binding.convertFlutterSurfaceToImage();
    } catch (e) {
      if (kDebugMode) {
        print("TakeScreenshot exception $e");
      }
    }
    await tester.pumpAndSettle();
  }

  await binding.takeScreenshot(name);
}
