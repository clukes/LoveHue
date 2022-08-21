import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/authentication_info.dart';
import 'package:lovehue/services/database_service.dart';
import 'package:lovehue/services/notification_service.dart';
import 'package:lovehue/services/shared_preferences_service.dart';
import 'package:lovehue/utils/app_info_class.dart';
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
])
void main() {
  // Uses build runner to generate mocks for tests.
  // Using command: flutter pub run build_runner build
}
