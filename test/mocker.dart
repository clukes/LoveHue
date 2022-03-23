import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/authentication_info.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  UserInfoState,
  PartnersInfoState,
  DocumentReference,
  UserInformation,
  BuildContext,
  AuthenticationInfo,
])
void main() {

}