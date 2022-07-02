import 'firebase/firebase_options_emu.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

void main() {
  mainCommon(
    DefaultFirebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue Emulated',
      aboutText: 'Emulated database version of the app',
    ),
  );
}
