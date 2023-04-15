import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'main_common.dart';
import 'utils/app_info_class.dart';

Future<void> main() async {
  const firebaseOptions = FirebaseOptions(
    apiKey: "test",
    appId: "test",
    messagingSenderId: "test",
    projectId: "lovehue-emu",
  );

  var firebaseApp = await Firebase.initializeApp(options: firebaseOptions);

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  return await mainCommon(
      firebaseOptions,
      const AppInfo(
        appName: 'LoveHue Emulated',
        aboutText: 'Emulated database version of the app',
      ),
      firebaseApp: firebaseApp);
}
