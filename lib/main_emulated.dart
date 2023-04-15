import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'flavour_firebase_options.dart';
import 'main_common.dart';
import 'utils/app_info_class.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".emu.env");
  var firebaseOptions =
      FlavourFirebaseOptions(dotenv.env, "lovehue-emu").currentPlatform;

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
