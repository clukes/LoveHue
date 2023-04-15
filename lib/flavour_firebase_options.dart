import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';

/// [FirebaseOptions] that pulls from dotenv, giving options for different flavours.
///
/// Example:
/// ```dart
/// await dotenv.load(fileName: ".dev.env");
/// var firebaseOptions = FlavourFirebaseOptions(dotenv.env, "app-dev");
/// await Firebase.initializeApp(
///   options: firebaseOptions.currentPlatform,
/// );
/// ```
class FlavourFirebaseOptions {
  FlavourFirebaseOptions(this.envMap, this.projectName) {
    web = FirebaseOptions(
      apiKey: envMap['WEB_APIKEY']!,
      appId: envMap['WEB_APPID']!,
      messagingSenderId: envMap['MESSAGINGSENDERID']!,
      projectId: projectName,
      authDomain: '$projectName.firebaseapp.com',
      storageBucket: '$projectName.appspot.com',
    );

    android = FirebaseOptions(
      apiKey: envMap['ANDROID_APIKEY']!,
      appId: envMap['ANDROID_APPID']!,
      messagingSenderId: envMap['MESSAGINGSENDERID']!,
      projectId: projectName,
      storageBucket: '$projectName.appspot.com',
    );
  }

  final Map<String, String> envMap;
  final String projectName;
  late final FirebaseOptions web;
  late final FirebaseOptions android;

  FirebaseOptions get currentPlatform =>
      DefaultFirebaseOptions.getCurrentPlatform(web: web, android: android);
}
