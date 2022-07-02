import '.firebase/firebase_options_prod.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

void main() {
  mainCommon(
    DefaultFirebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue',
      aboutText: '', //TODO: Write about dialog.
    ),
  );
}
