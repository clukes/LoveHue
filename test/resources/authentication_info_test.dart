import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:lovehue/resources/authentication_info.dart';
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
      when(navigator.pushAndRemoveUntil(captureAny, captureAny)).thenAnswer((_) async => null);
    });

    test('calls signInAnonymously and navigator', () async {
      await subject.signInAnonymously(navigator, auth: auth);

      verify(auth.signInAnonymously());
      verify(navigator.pushAndRemoveUntil(captureAny, captureAny));
    });

    test('doesnt navigate if user is null', () async {
      when(auth.currentUser).thenReturn(null);

      await subject.signInAnonymously(navigator, auth: auth);

      verify(auth.signInAnonymously());
      verifyNever(navigator.pushAndRemoveUntil(captureAny, captureAny));
    });
  });
}

class MockUserCredential implements UserCredential {
  @override
  AdditionalUserInfo? get additionalUserInfo => throw UnimplementedError();

  @override
  AuthCredential? get credential => throw UnimplementedError();

  @override
  User? get user => throw UnimplementedError();
}
