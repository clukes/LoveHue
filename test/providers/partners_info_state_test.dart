import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/partners_info_state.dart';
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

  group('setupPartnerInfoSubscription', () {
    final MockDocumentReference<LinkCode> linkCodeRef = MockDocumentReference<LinkCode>();

    test('partner name changed updates partner name in state', () async {
      String displayName = 'Test';

      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation currentUserInfo =
          UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
      final UserInformation partnersInfo =
          UserInformation(displayName: displayName, userID: '5678', linkCode: linkCodeRef, firestore: firestore);
      final PartnersInfoState partnersInfoState = PartnersInfoState();

      currentUserInfo.partner = firestore.collection(userInfoCollection).doc(partnersInfo.userID);
      partnersInfo.partner = firestore.collection(userInfoCollection).doc(currentUserInfo.userID);
      partnersInfoState.partnersInfo = partnersInfo;
      partnersInfoState.partnersName.value = '';

      final notifyListenerCallback = MockFunction();
      partnersInfoState.addListener(notifyListenerCallback);

      await firestore
          .collection(userInfoCollection)
          .doc(partnersInfo.userID)
          .set(partnersInfo.toMap())
          .then((value) => partnersInfoState.setupPartnerInfoSubscription(currentUserInfo));

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(partnersInfoState.partnersInfo, isNotNull);
        expect(partnersInfoState.partnersInfo!.userID, equals(partnersInfo.userID));
        expect(partnersInfoState.partnersInfo!.displayName, equals(displayName));
        expect(partnersInfoState.partnersName.value, equals(displayName));
      });
    });

    test('does nothing if partner info is null', () async {
      final MockUserInformation currentUserInfo = MockUserInformation();
      final PartnersInfoState partnersInfoState = PartnersInfoState();

      partnersInfoState.partnersInfo = null;
      partnersInfoState.setupPartnerInfoSubscription(currentUserInfo);

      expect(partnersInfoState.partnersInfo, isNull);
    });

    test('if partners info id does not match current user partner id, set partner info to null', () async {
      final MockUserInformation currentUserInfo = MockUserInformation();
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation partnersInfo = UserInformation(userID: '5678', linkCode: linkCodeRef, firestore: firestore);
      final PartnersInfoState partnersInfoState = PartnersInfoState();

      partnersInfoState.partnersInfo = partnersInfo;

      when(currentUserInfo.userID).thenReturn('1234');

      final notifyListenerCallback = MockFunction();
      partnersInfoState.addListener(notifyListenerCallback);

      await firestore
          .collection(userInfoCollection)
          .doc(partnersInfo.userID)
          .set(partnersInfo.toMap())
          .then((value) => partnersInfoState.setupPartnerInfoSubscription(currentUserInfo));

      await untilCalled(notifyListenerCallback.call())
          .timeout(timeout)
          .then((value) => expect(partnersInfoState.partnersInfo, isNull));
    });
  });

  group('addPartner', () {
    final MockDocumentReference<LinkCode> linkCodeRef = MockDocumentReference<LinkCode>();

    test('sets partner info and display name', () async {
      String displayName = 'Test';

      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation currentUserInfo =
          UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
      final UserInformation partnersInfo =
          UserInformation(displayName: displayName, userID: '5678', linkCode: linkCodeRef, firestore: firestore);
      final PartnersInfoState partnersInfoState = PartnersInfoState();

      partnersInfoState.addPartner(partnersInfo, currentUserInfo);

      expect(partnersInfoState.partnersInfo, isNotNull);
      expect(partnersInfoState.partnersInfo!.userID, equals(partnersInfo.userID));
      expect(partnersInfoState.partnersName.value, equals(displayName));
    });
  });

  group('removePartner', () {
    final MockDocumentReference<LinkCode> linkCodeRef = MockDocumentReference<LinkCode>();

    test('removes partner info from state and current user info', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final UserInformation currentUserInfo =
          UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
      final PartnersInfoState partnersInfoState = PartnersInfoState();

      partnersInfoState.removePartner(currentUserInfo);

      expect(partnersInfoState.partnersInfo, isNull);
      expect(currentUserInfo.linkPending, isFalse);
      expect(currentUserInfo.partner, isNull);
    });
  });
}
