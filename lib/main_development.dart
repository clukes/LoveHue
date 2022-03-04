import '.firebase/firebase_options_dev.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

void main() {
  mainCommon(
    DefaultFirebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue Dev', //TODO: Set to correct name.
      aboutText: 'Development version of the app',
    ),
  );
}
