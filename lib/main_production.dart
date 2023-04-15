import 'firebase/firebase_options.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

Future<void> main() async {
  return await mainCommon(
    DefaultFirebaseOptions.getCurrentPlatform(),
    const AppInfo(
      appName: 'LoveHue',
      aboutText: '', //TODO: Write about dialog.
    ),
  );
}
