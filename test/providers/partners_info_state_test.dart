import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/resources/database_and_table_names.dart';
import 'package:mockito/mockito.dart';

import '../mocker.dart';
import '../mocker.mocks.dart';

void main() {
  const Duration timeout = Duration(seconds: 5);
  const String displayName = 'Test';
  const String linkCodeID = "9876";

  late MockDocumentReference<LinkCode> linkCodeRef;
  late FakeFirebaseFirestore firestore;
  late UserInformation currentUserInfo;
  late UserInformation partnersInfo;
  late PartnersInfoState partnersInfoState;

  setUp(() {
    linkCodeRef = MockDocumentReference<LinkCode>();
    when(linkCodeRef.id).thenReturn(linkCodeID);
    firestore = FakeFirebaseFirestore();
    currentUserInfo = UserInformation(userID: '1234', linkCode: linkCodeRef, firestore: firestore);
    partnersInfo = UserInformation(displayName: displayName, userID: '5678', linkCode: linkCodeRef, firestore: firestore);
    partnersInfoState = PartnersInfoState();
  });

  group('getters', () {
    test('get partnersID returns ID', () {
      partnersInfoState.partnersInfo = partnersInfo;
      expect(partnersInfoState.partnersID, equals(partnersInfo.userID));
    });

    test('get partnersID returns null if no partner', () {
      partnersInfoState.partnersInfo = null;
      expect(partnersInfoState.partnersID, isNull);
    });

    test('get linkCode returns linkCode', () {
      partnersInfoState.partnersInfo = partnersInfo;
      expect(partnersInfoState.linkCode, equals(linkCodeID));
    });

    test('get linkCode returns null if no partner', () {
      partnersInfoState.partnersInfo = null;
      expect(partnersInfoState.linkCode, isNull);
    });

    test('get partnerExist true if not null', () {
      partnersInfoState.partnersInfo = partnersInfo;
      expect(partnersInfoState.partnerExist, isTrue);
    });

    test('get partnerExist false if null', () {
      partnersInfoState.partnersInfo = null;
      expect(partnersInfoState.partnerExist, isFalse);
    });

    test('get partnerPending true if pending true', () {
      partnersInfo.linkPending = true;
      partnersInfoState.partnersInfo = partnersInfo;
      expect(partnersInfoState.partnerPending, isTrue);
    });

    test('get partnerPending false if null', () {
      partnersInfoState.partnersInfo = null;
      expect(partnersInfoState.partnerPending, isFalse);
    });
  });

  group('setupPartnerInfoSubscription', () {
    MockFunction notifyListenerCallback = MockFunction();

    setUp(() {
      notifyListenerCallback = MockFunction();
      partnersInfoState.addListener(notifyListenerCallback);
    });

    test('partner name changed updates partner name in state', () async {
      currentUserInfo.partner = firestore.collection(userInfoCollection).doc(partnersInfo.userID);
      partnersInfo.partner = firestore.collection(userInfoCollection).doc(currentUserInfo.userID);
      partnersInfoState.partnersInfo = partnersInfo;
      partnersInfoState.partnersName.value = '';

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
      partnersInfoState.partnersInfo = null;
      partnersInfoState.setupPartnerInfoSubscription(currentUserInfo);

      expect(partnersInfoState.partnersInfo, isNull);
    });

    test('if partners info id does not match current user partner id, set partner info to null', () async {
      final MockUserInformation currentUserInfo = MockUserInformation();

      partnersInfoState.partnersInfo = partnersInfo;

      when(currentUserInfo.userID).thenReturn('1234');

      await firestore
          .collection(userInfoCollection)
          .doc(partnersInfo.userID)
          .set(partnersInfo.toMap())
          .then((value) => partnersInfoState.setupPartnerInfoSubscription(currentUserInfo));

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) => expect(partnersInfoState.partnersInfo, isNull));
    });
  });

  group('addPartner', () {
    test('sets partner info and display name', () async {
      partnersInfoState.addPartner(partnersInfo, currentUserInfo);

      expect(partnersInfoState.partnersInfo, isNotNull);
      expect(partnersInfoState.partnersInfo!.userID, equals(partnersInfo.userID));
      expect(partnersInfoState.partnersName.value, equals(displayName));
    });
  });

  group('removePartner', () {
    test('removes partner info from state and current user info', () async {
      partnersInfoState.removePartner(currentUserInfo);

      expect(partnersInfoState.partnersInfo, isNull);
      expect(currentUserInfo.linkPending, isFalse);
      expect(currentUserInfo.partner, isNull);
    });
  });
}
