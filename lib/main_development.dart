import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase/firebase_options_dev.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

Future main() async {
  await dotenv.load(fileName: ".dev.env");
  mainCommon(
    DefaultFirebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue Dev',
      aboutText: 'Development version of the app',
    ),
  );
}
