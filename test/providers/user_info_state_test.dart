import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/database_and_table_names.dart';
import 'package:mockito/mockito.dart';

import '../mocker.mocks.dart';

class MockFunction extends Mock {
  call();
}

void main() {
  setUp(() {});
  tearDown(() {});

  const Duration timeout = Duration(seconds: 5);

  group('setupUserInfoSubscription', () {
    final MockDocumentReference<LinkCode> linkCodeRef = MockDocumentReference<LinkCode>();

    test('setups partner info if new partner is added to user info', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation currentUserInfo =
      UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
      final UserInformation partnersInfo =
      UserInformation(userID: '5678', linkCode: linkCodeRef, firestore: firestore);
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      currentUserInfo.partner = firestore.collection(userInfoCollection).doc(partnersInfo.userID);
      partnersInfo.partner = firestore.collection(userInfoCollection).doc(currentUserInfo.userID);
      userInfoState.userInfo = currentUserInfo;

      when(partnersInfoState.partnerExist).thenReturn(false);

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      await firestore
          .collection(userInfoCollection)
          .doc(currentUserInfo.userID)
          .set(currentUserInfo.toMap())
          .then((value) => userInfoState.setupUserInfoSubscription());

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.userInfo, isNotNull);
        expect(userInfoState.userInfo!.userID, equals(currentUserInfo.userID));
        verify(partnersInfoState.addPartner(captureAny, captureAny));
      });
    });

    test('does nothing if user info is null', () async {
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      userInfoState.userInfo = null;
      userInfoState.setupUserInfoSubscription();

      expect(userInfoState.userInfo, isNull);
    });

    test('removes partner info if no partner in user info', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation currentUserInfo =
      UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      userInfoState.userInfo = currentUserInfo;

      when(partnersInfoState.partnerExist).thenReturn(true);

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      await firestore
          .collection(userInfoCollection)
          .doc(currentUserInfo.userID)
          .set(currentUserInfo.toMap())
          .then((value) => userInfoState.setupUserInfoSubscription());

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.userInfo, isNotNull);
        expect(userInfoState.userInfo!.userID, equals(currentUserInfo.userID));
        verify(partnersInfoState.removePartner(captureAny));
      });
    });
  });

  group('addUser', () {
    final MockDocumentReference<LinkCode> linkCodeRef = MockDocumentReference<LinkCode>();

    test('sets user info', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation currentUserInfo = UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      userInfoState.addUser(currentUserInfo);
      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.userInfo, isNotNull);
        expect(userInfoState.userInfo!.userID, equals(currentUserInfo.userID));
      });
    });
  });

  group('removesUser', () {
    final MockDocumentReference<LinkCode> linkCodeRef = MockDocumentReference<LinkCode>();

    test('removes user info', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation currentUserInfo = UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      userInfoState.userInfo = currentUserInfo;

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      userInfoState.removeUser();
      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.userInfo, isNull);
      });
    });
  });

  group('barChange', () {
    test('sets bars changed to true and notifies listeners', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      userInfoState.barsChanged = false;

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      userInfoState.barChange();

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.barsChanged, isTrue);
      });
    });

    test("doesn't notify listeners if bars changed already true", () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      userInfoState.barsChanged = true;

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      userInfoState.barChange();

      verifyNever(notifyListenerCallback.call());
    });
  });

  group('resetBarChange', () {
    test('sets bars changed to false and notifies listeners', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      userInfoState.barsChanged = true;

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      userInfoState.resetBarChange();

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.barsChanged, isFalse);
      });
    });

    test("doesn't notify listeners if bars changed already false", () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
      final UserInfoState userInfoState = UserInfoState(firestore, partnersInfoState);

      userInfoState.barsChanged = false;

      final notifyListenerCallback = MockFunction();
      userInfoState.addListener(notifyListenerCallback);

      userInfoState.resetBarChange();

      verifyNever(notifyListenerCallback.call());
    });
  });
}
