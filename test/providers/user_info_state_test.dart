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
  const Duration timeout = Duration(seconds: 5);

  late FakeFirebaseFirestore firestore;
  late MockDocumentReference<LinkCode> linkCodeRef;
  late MockPartnersInfoState partnersInfoState;
  late UserInfoState userInfoState;
  late UserInformation currentUserInfo;
  late MockFunction notifyListenerCallback;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    linkCodeRef = MockDocumentReference<LinkCode>();
    partnersInfoState = MockPartnersInfoState();
    userInfoState = UserInfoState(firestore, partnersInfoState);
    currentUserInfo = UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
    notifyListenerCallback = MockFunction();
    userInfoState.addListener(notifyListenerCallback);
  });

  group('setupUserInfoSubscription', () {
    test('setups partner info if new partner is added to user info', () async {
      final UserInformation partnersInfo = UserInformation(userID: '5678', linkCode: linkCodeRef, firestore: firestore);

      currentUserInfo.partner = firestore.collection(userInfoCollection).doc(partnersInfo.userID);
      partnersInfo.partner = firestore.collection(userInfoCollection).doc(currentUserInfo.userID);
      userInfoState.userInfo = currentUserInfo;

      when(partnersInfoState.partnerExist).thenReturn(false);

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
      userInfoState.userInfo = null;
      userInfoState.setupUserInfoSubscription();

      expect(userInfoState.userInfo, isNull);
    });

    test('removes partner info if no partner in user info', () async {
      userInfoState.userInfo = currentUserInfo;

      when(partnersInfoState.partnerExist).thenReturn(true);

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
    test('sets user info', () async {
      userInfoState.addUser(currentUserInfo);
      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.userInfo, isNotNull);
        expect(userInfoState.userInfo!.userID, equals(currentUserInfo.userID));
      });
    });
  });

  group('removesUser', () {
    test('removes user info', () async {
      userInfoState.userInfo = currentUserInfo;

      userInfoState.removeUser();
      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.userInfo, isNull);
      });
    });
  });

  group('barChange', () {
    test('sets bars changed to true and notifies listeners', () async {
      userInfoState.barsChanged = false;

      userInfoState.barChange();

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.barsChanged, isTrue);
      });
    });

    test("doesn't notify listeners if bars changed already true", () async {
      userInfoState.barsChanged = true;

      userInfoState.barChange();

      verifyNever(notifyListenerCallback.call());
    });
  });

  group('resetBarChange', () {
    test('sets bars changed to false and notifies listeners', () async {
      userInfoState.barsChanged = true;

      userInfoState.resetBarChange();

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(userInfoState.barsChanged, isFalse);
      });
    });

    test("doesn't notify listeners if bars changed already false", () async {
      userInfoState.barsChanged = false;

      userInfoState.resetBarChange();

      verifyNever(notifyListenerCallback.call());
    });
  });
}
