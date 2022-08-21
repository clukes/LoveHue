import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lovehue/firebase/firebase_options.dart';

import 'main_common.dart';
import 'utils/app_info_class.dart';

Future main() async {
  await dotenv.load(fileName: "assets/.dev.env");
  mainCommon(
    DevFirebaseOptions.currentPlatform,
    const AppInfo(
      appName: 'LoveHue Dev',
      aboutText: 'Development version of the app',
    ),
  );
}

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DevFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      DefaultFirebaseOptions.getCurrentPlatform(web: web, android: android);

  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['DEV_WEB_APIKEY']!,
    appId: dotenv.env['DEV_WEB_APPID']!,
    messagingSenderId: dotenv.env['DEV_MESSAGINGSENDERID']!,
    projectId: 'lovehue-dev',
    authDomain: 'lovehue-dev.firebaseapp.com',
    storageBucket: 'lovehue-dev.appspot.com',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['DEV_ANDROID_APIKEY']!,
    appId: dotenv.env['DEV_ANDROID_APPID']!,
    messagingSenderId: dotenv.env['DEV_MESSAGINGSENDERID']!,
    projectId: 'lovehue-dev',
    storageBucket: 'lovehue-dev.appspot.com',
  );
}
