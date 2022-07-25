import 'firebase/firebase_options.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

Future<void> main() async {
  mainCommon(
    DefaultFirebaseOptions.getCurrentPlatform(),
    const AppInfo(
      appName: 'LoveHue Emulated',
      aboutText: 'Emulated database version of the app',
    ),
  );
}
