import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:lovehue/resources/authentication_info.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../mocker.mocks.dart';
import '../models/user_information_test.mocks.dart';

void main() {
  const String packageName = "TestPackage";

  late AuthenticationInfo subject;
  late PackageInfo packageInfo;

  setUp(() {
    packageInfo = PackageInfo(appName: "TestApp", packageName: packageName, version: "1", buildNumber: "2");
    subject = AuthenticationInfo(packageInfo);
  });

  group("constructor", () {
    test('sets ActionCodeSettings correctly', () async {
      expect(subject.actionCodeSettings.handleCodeInApp, true);
      expect(subject.actionCodeSettings.androidInstallApp, true);
      expect(subject.actionCodeSettings.androidPackageName, packageName);
      expect(subject.actionCodeSettings.iOSBundleId, packageName);
    });

    test('providerConfigs has email link provider config', () async {
      expect(subject.providerConfigs.whereType<EmailLinkProviderConfiguration>(), isNotEmpty);
    });
  });

  group("signInAnonymously", () {
    late MockFirebaseAuth auth;
    late MockNavigatorState navigator;

    setUp(() {
      auth = MockFirebaseAuth();
      navigator = MockNavigatorState();
      when(auth.currentUser).thenReturn(MockUser());
      when(auth.signInAnonymously()).thenAnswer((_) async => MockUserCredential());
      when(navigator.pushAndRemoveUntil(any, any)).thenAnswer((_) async => null);
    });

    test('calls signInAnonymously and navigator', () async {
      await subject.signInAnonymously(navigator, auth);

      verify(auth.signInAnonymously());
      verify(navigator.pushAndRemoveUntil(any, any));
    });

    test('doesnt navigate if user is null', () async {
      when(auth.currentUser).thenReturn(null);

      await subject.signInAnonymously(navigator, auth);

      verify(auth.signInAnonymously());
      verifyNever(navigator.pushAndRemoveUntil(any, any));
    });
  });

  group("reauthenticate", () {
    late MockFirebaseAuth auth;
    late MockBuildContext context;

    setUp(() {
      auth = MockFirebaseAuth();
      context = MockBuildContext();
      when(auth.signInAnonymously()).thenAnswer((_) async => MockUserCredential());
    });

    test('null user throws error', () async {
      when(auth.currentUser).thenReturn(null);
      await expectLater(() => subject.reauthenticate(context, auth), throwsA(isA<PrintableError>()));
    });

    test('reauthenticate shows dialog', () async {
      var helper = MockReauthenticateHelper();
      when(helper.showDialog(any, any, any)).thenAnswer((_) async => false);
      when(auth.currentUser).thenReturn(MockUser());

      await subject.reauthenticate(context, auth, helper: helper);

      verify(helper.showDialog(context, auth, subject.providerConfigs)).called(1);
    });
  });
}

class MockUserCredential extends Mock implements UserCredential {}
