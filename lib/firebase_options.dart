// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCkCeK7qHrxJgjj0eDx7O6_9nJyWXNWscU',
    appId: '1:922871415729:web:0e17711cb8e75d91d2f390',
    messagingSenderId: '922871415729',
    projectId: 'relationshipapp-70422',
    authDomain: 'relationshipapp-70422.firebaseapp.com',
    storageBucket: 'relationshipapp-70422.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgQAOZd9HgrubsDufsAXfMqkjfrNI1gxQ',
    appId: '1:922871415729:android:a054cfd0be4b9766d2f390',
    messagingSenderId: '922871415729',
    projectId: 'relationshipapp-70422',
    storageBucket: 'relationshipapp-70422.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCK4wfFbQ4iutMsmPhRcs-GyvkhKB8Saik',
    appId: '1:922871415729:ios:ed5855cc68dd9827d2f390',
    messagingSenderId: '922871415729',
    projectId: 'relationshipapp-70422',
    storageBucket: 'relationshipapp-70422.appspot.com',
    androidClientId: '922871415729-8k7f8crvcngi7geqhos0hqdp07c9n7fa.apps.googleusercontent.com',
    iosClientId: '922871415729-h99ko6ecigqutmo05eelk4nfiv36vl3g.apps.googleusercontent.com',
    iosBundleId: 'com.example.relationshipbars',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCK4wfFbQ4iutMsmPhRcs-GyvkhKB8Saik',
    appId: '1:922871415729:ios:ed5855cc68dd9827d2f390',
    messagingSenderId: '922871415729',
    projectId: 'relationshipapp-70422',
    storageBucket: 'relationshipapp-70422.appspot.com',
    androidClientId: '922871415729-8k7f8crvcngi7geqhos0hqdp07c9n7fa.apps.googleusercontent.com',
    iosClientId: '922871415729-h99ko6ecigqutmo05eelk4nfiv36vl3g.apps.googleusercontent.com',
    iosBundleId: 'com.example.relationshipbars',
  );
}
