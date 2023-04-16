// ignore_for_file: avoid_print

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> takeScreenshot(tester, binding, name) async {
  if (PlatformUtils.isAndroid) {
    try {
      await binding.convertFlutterSurfaceToImage();
    } catch (e) {
      print("TakeScreenshot exception $e");
    }
    await tester.pumpAndSettle();
  }

  if(!kIsWeb) {
    // Currently screenshots aren't working on web
    await binding.takeScreenshot(name);
  }
}

class PlatformUtils {
  static bool get isMobile {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isIOS || Platform.isAndroid;
    }
  }

  static bool get isAndroid {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isAndroid;
    }
  }

  static bool get isDesktop {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isLinux ||
          Platform.isFuchsia ||
          Platform.isWindows ||
          Platform.isMacOS;
    }
  }
}
