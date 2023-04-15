import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'flavour_firebase_options.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

Future main() async {
  await dotenv.load(fileName: ".emu.env");
  var firebaseOptions = FlavourFirebaseOptions(dotenv.env, "lovehue-dev");
  return await mainCommon(
    firebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue Dev',
      aboutText: 'Development version of the app',
    ),
  );
}
