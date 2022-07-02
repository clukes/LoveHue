import 'firebase/firebase_options_demo.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

void main() {
  mainCommon(
    DefaultFirebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue Demo',
      aboutText: 'Demo version of the app',
    ),
  );
}
