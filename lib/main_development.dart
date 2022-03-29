import '.firebase/firebase_options_dev.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

void main() {
  mainCommon(
    DefaultFirebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue Dev',
      aboutText: 'Development version of the app',
    ),
  );
}
