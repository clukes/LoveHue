// ignore_for_file: avoid_print

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes) async {
      try {
        final File image = await File('screenshots/$screenshotName.png')
            .create(recursive: true);

        image.writeAsBytesSync(screenshotBytes);
      } catch (e) {
        print('onScreenshot - error - $e');
      }
      return true;
    },
  );
}
