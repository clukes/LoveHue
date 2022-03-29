import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/authentication_info.dart';
import 'package:lovehue/utils/app_info_class.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

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
])
void main() {
  // Uses build runner to generate mocks for tests.
}
