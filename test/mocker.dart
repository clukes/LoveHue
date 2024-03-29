import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/authentication_info.dart';
import 'package:lovehue/services/database_service.dart';
import 'package:lovehue/services/notification_service.dart';
import 'package:lovehue/services/shared_preferences_service.dart';
import 'package:lovehue/utils/app_info_class.dart';
import 'package:lovehue/utils/configs.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockClipboard {
  Map<String, dynamic> _clipboardData = <String, dynamic>{
    'text': null,
  };

  Map<String, dynamic> get clipboardData => _clipboardData;

  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Clipboard.getData':
        return _clipboardData;
      case 'Clipboard.setData':
        _clipboardData = methodCall.arguments;
        break;
    }
  }
}

class MockFunction extends Mock {
  call();
}

Future<FirebaseApp> setupMockFirebaseApp() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  return await Firebase.initializeApp();
}

@GenerateMocks([
  ApplicationState,
  UserInfoState,
  PartnersInfoState,
  DocumentReference,
  UserInformation,
  BuildContext,
  AuthenticationInfo,
  AppInfo,
  NavigatorState,
  ReauthenticateHelper,
  NotificationService,
  SharedPreferences,
  SharedPreferencesService,
  DatabaseService,
  NotificationsConfig,
  FirebaseMessaging,
  OverlayControllerWidget
])
void main() {
  // Uses build runner to generate mocks for tests.
  // Using command: flutter pub run build_runner build
}
