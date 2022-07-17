import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/relationship_bar.dart';
import 'package:lovehue/models/relationship_bar_document.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/database_and_table_names.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:mockito/mockito.dart';

import '../mocker.dart';
import '../mocker.mocks.dart';

void main() {
  const Duration timeout = Duration(seconds: 5);
  const String userID = '1234';
  const String linkCodeID = '123';

  late FakeFirebaseFirestore firestore;
  late MockDocumentReference<LinkCode> linkCodeRef;
  late MockPartnersInfoState partnersInfoState;
  late UserInformation currentUserInfo;
  late MockFunction notifyListenerCallback;
  late UserInfoState subject;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    linkCodeRef = MockDocumentReference<LinkCode>();
    when(linkCodeRef.id).thenReturn(linkCodeID);
    partnersInfoState = MockPartnersInfoState();
    subject = UserInfoState(firestore, partnersInfoState);
    currentUserInfo = UserInformation(userID: userID, linkCode: linkCodeRef, firestore: firestore);
    notifyListenerCallback = MockFunction();
    subject.addListener(notifyListenerCallback);
  });

  group('getters', () {
    test('get userID returns ID', () {
      subject.userInfo = currentUserInfo;
      expect(subject.userID, equals(currentUserInfo.userID));
    });

    test('get userID returns null if no partner', () {
      subject.userInfo = null;
      expect(subject.userID, isNull);
    });

    test('get linkCode returns linkCode', () {
      subject.userInfo = currentUserInfo;
      expect(subject.linkCode, equals(linkCodeID));
    });

    test('get linkCode returns null if no partner', () {
      subject.userInfo = null;
      expect(subject.linkCode, isNull);
    });

    test('get userExist true if not null', () {
      subject.userInfo = currentUserInfo;
      expect(subject.userExist, isTrue);
    });

    test('get userExist false if null', () {
      subject.userInfo = null;
      expect(subject.userExist, isFalse);
    });

    test('get userPending true if pending true', () {
      currentUserInfo.linkPending = true;
      subject.userInfo = currentUserInfo;
      expect(subject.userPending, isTrue);
    });

    test('get userPending false if user null', () {
      subject.userInfo = null;
      expect(subject.userPending, isFalse);
    });

    test('get partnerLinked true if partner linked', () {
      currentUserInfo.linkPending = false;
      subject.userInfo = currentUserInfo;
      when(partnersInfoState.partnerExist).thenReturn(true);
      when(partnersInfoState.partnerPending).thenReturn(false);
      expect(subject.partnerLinked, isTrue);
    });

    test('get partnerLinked false if partner not exist', () {
      currentUserInfo.linkPending = false;
      subject.userInfo = currentUserInfo;
      when(partnersInfoState.partnerExist).thenReturn(false);
      when(partnersInfoState.partnerPending).thenReturn(false);
      expect(subject.partnerLinked, isFalse);
    });

    test('get partnerLinked false if partner pending', () {
      currentUserInfo.linkPending = false;
      subject.userInfo = currentUserInfo;
      when(partnersInfoState.partnerExist).thenReturn(true);
      when(partnersInfoState.partnerPending).thenReturn(true);
      expect(subject.partnerLinked, isFalse);
    });

    test('get partnerLinked false if user pending', () {
      currentUserInfo.linkPending = true;
      subject.userInfo = currentUserInfo;
      when(partnersInfoState.partnerExist).thenReturn(true);
      when(partnersInfoState.partnerPending).thenReturn(true);
      expect(subject.partnerLinked, isFalse);
    });
  });

  group('setupUserInfoSubscription', () {
    test('setups partner info if new partner is added to user info', () async {
      final UserInformation partnersInfo = UserInformation(userID: '5678', linkCode: linkCodeRef, firestore: firestore);

      currentUserInfo.partner = firestore.collection(userInfoCollection).doc(partnersInfo.userID);
      partnersInfo.partner = firestore.collection(userInfoCollection).doc(currentUserInfo.userID);
      subject.userInfo = currentUserInfo;

      when(partnersInfoState.partnerExist).thenReturn(false);

      await firestore
          .collection(userInfoCollection)
          .doc(currentUserInfo.userID)
          .set(currentUserInfo.toMap())
          .then((value) => subject.setupUserInfoSubscription());

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(subject.userInfo, isNotNull);
        expect(subject.userInfo!.userID, equals(currentUserInfo.userID));
        verify(partnersInfoState.addPartner(any, any));
      });
    });

    test('does nothing if user info is null', () async {
      subject.userInfo = null;
      subject.setupUserInfoSubscription();

      expect(subject.userInfo, isNull);
    });

    test('does nothing with partner if already connected to partner', () async {
      String partnerId = '5678';

      currentUserInfo.partner = firestore.collection(userInfoCollection).doc(partnerId);
      subject.userInfo = currentUserInfo;

      when(partnersInfoState.partnerExist).thenReturn(true);
      when(partnersInfoState.partnersID).thenReturn(partnerId);

      await firestore
          .collection(userInfoCollection)
          .doc(currentUserInfo.userID)
          .set(currentUserInfo.toMap())
          .then((value) => subject.setupUserInfoSubscription());

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(subject.userInfo, isNotNull);
        expect(subject.userInfo!.userID, equals(currentUserInfo.userID));
        verify(partnersInfoState.partnerExist);
        verify(partnersInfoState.partnersID);
        verifyNever(partnersInfoState.addPartner(any, any));
        verifyNever(partnersInfoState.removePartner(any));
      });
    });

    test('removes partner info if no partner in user info', () async {
      subject.userInfo = currentUserInfo;

      when(partnersInfoState.partnerExist).thenReturn(true);

      await firestore
          .collection(userInfoCollection)
          .doc(currentUserInfo.userID)
          .set(currentUserInfo.toMap())
          .then((value) => subject.setupUserInfoSubscription());

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(subject.userInfo, isNotNull);
        expect(subject.userInfo!.userID, equals(currentUserInfo.userID));
        verify(partnersInfoState.removePartner(any));
      });
    });
  });

  group('addUser', () {
    test('sets user info', () async {
      subject.addUser(currentUserInfo);
      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(subject.userInfo, isNotNull);
        expect(subject.userInfo!.userID, equals(currentUserInfo.userID));
      });
    });
  });

  group('removesUser', () {
    test('removes user info', () async {
      subject.userInfo = currentUserInfo;

      subject.removeUser();
      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(subject.userInfo, isNull);
      });
    });
  });

  group('barChange', () {
    test('sets bars changed to true and notifies listeners', () async {
      subject.barsChanged = false;

      subject.barChange();

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(subject.barsChanged, isTrue);
      });
    });

    test("doesn't notify listeners if bars changed already true", () async {
      subject.barsChanged = true;

      subject.barChange();

      verifyNever(notifyListenerCallback.call());
    });
  });

  group('resetBarChange', () {
    test('sets bars changed to false and notifies listeners', () async {
      subject.barsChanged = true;

      subject.resetBarChange();

      await untilCalled(notifyListenerCallback.call()).timeout(timeout).then((value) {
        expect(subject.barsChanged, isFalse);
      });
    });

    test("doesn't notify listeners if bars changed already false", () async {
      subject.barsChanged = false;

      subject.resetBarChange();

      verifyNever(notifyListenerCallback.call());
    });
  });

  group('connectTo', () {
    late DocumentReference<LinkCode?> linkCodeRef;
    late UserInformation partnerInfo;
    late UserInformation userInfo;
    late MockDocumentReference<UserInformation?> userRef;
    late LinkCode linkCode;

    setUp(() async {
      userRef = MockDocumentReference<UserInformation?>();
      linkCode = LinkCode(linkCode: linkCodeID, user: userRef);
      linkCodeRef = LinkCode.getDocumentReference(linkCodeID, firestore);
      partnerInfo = UserInformation(userID: userID, linkCode: linkCodeRef, firestore: firestore);
      userInfo = UserInformation(userID: '9876', linkCode: linkCodeRef, firestore: firestore);
      subject.userInfo = userInfo;

      partnerInfo.linkCode = linkCodeRef;

      when(userRef.id).thenReturn(userID);
      await linkCodeRef.set(linkCode);
      await firestore.collection(userInfoCollection).doc(userRef.id).set(partnerInfo.toMap());
      await firestore.collection(userInfoCollection).doc(userInfo.userID).set(userInfo.toMap());
      when(partnersInfoState.partnerExist).thenReturn(false);
      when(partnersInfoState.partnerPending).thenReturn(false);
    });

    test('valid user adds partner to state', () async {
      when(partnersInfoState.addPartner(partnerInfo, userInfo))
          .thenAnswer((realInvocation) => expect(realInvocation.positionalArguments.first['userID'], partnerInfo.userID));
      await subject.connectTo(linkCodeID);
    });

    test('pending partner throws error', () async {
      when(partnersInfoState.partnerExist).thenReturn(true);
      when(partnersInfoState.partnerPending).thenReturn(true);
      expectLater(subject.connectTo(linkCodeID), throwsA(isA<PrintableError>()));
    });

    test('linked partner throws error', () async {
      when(partnersInfoState.partnerExist).thenReturn(true);
      when(partnersInfoState.partnerPending).thenReturn(false);
      expectLater(subject.connectTo(linkCodeID), throwsA(isA<PrintableError>()));
    });

    test('null user info throws error', () async {
      when(partnersInfoState.partnerExist).thenReturn(false);
      subject.userInfo = null;
      expectLater(subject.connectTo(linkCodeID), throwsA(isA<PrintableError>()));
    });

    test('link code not in database throws error', () async {
      await firestore.collection(linkCodesCollection).doc(linkCodeID).delete();
      expectLater(subject.connectTo(linkCodeID), throwsA(isA<PrintableError>()));
    });

    test('link code has no user throws error', () async {
      LinkCode linkCode = LinkCode(linkCode: linkCodeID);
      await firestore.collection(linkCodesCollection).doc(linkCodeID).set(linkCode.toMap());
      expectLater(subject.connectTo(linkCodeID), throwsA(isA<PrintableError>()));
    });

    test('no user with link code throws error', () async {
      await firestore.collection(userInfoCollection).doc(userRef.id).delete();
      expectLater(subject.connectTo(linkCodeID), throwsA(isA<PrintableError>()));
    });

    test('user with link code already has partner throws error', () async {
      partnerInfo = UserInformation(userID: userID, partner: userRef, linkCode: linkCodeRef, firestore: firestore);
      await firestore.collection(userInfoCollection).doc(userRef.id).set(partnerInfo.toMap());
      expectLater(subject.connectTo(linkCodeID), throwsA(isA<PrintableError>()));
    });
  });

  group('acceptRequest', () {
    late MockDocumentReference<UserInformation?> userRef;
    late UserInformation userInfo;
    late UserInformation partnerInfo;

    setUp(() async {
      userRef = MockDocumentReference<UserInformation?>();
      userInfo = UserInformation(userID: userID, linkCode: linkCodeRef, firestore: firestore);
      partnerInfo = UserInformation(userID: '9876', linkCode: linkCodeRef, firestore: firestore);

      userInfo.partner = userRef;
      userInfo.linkPending = true;

      subject.userInfo = userInfo;
      when(partnersInfoState.partnerExist).thenReturn(false);
      when(userRef.id).thenReturn(userID);
      await firestore.collection(userInfoCollection).doc(userInfo.userID).set(userInfo.toMap());
    });

    test('valid request with incorrect local partner info adds partner to state', () async {
      await subject.acceptRequest();
      when(partnersInfoState.addPartner(partnerInfo, userInfo))
          .thenAnswer((realInvocation) => expect(realInvocation.positionalArguments.first['userID'], partnerInfo.userID));
    });

    test('valid request with correct local partner info notifies listeners', () async {
      when(partnersInfoState.partnersID).thenReturn(userInfo.partnerID);
      when(partnersInfoState.partnerExist).thenReturn(true);
      await subject.acceptRequest();
      when(partnersInfoState.notify()).thenReturn(null);
      verify(partnersInfoState.notify());
    });

    test('user already connected to partner throws error', () async {
      when(partnersInfoState.partnerExist).thenReturn(true);
      subject.userInfo?.linkPending = false;
      expectLater(subject.acceptRequest(), throwsA(isA<PrintableError>()));
    });

    test('no user info in state throws error', () async {
      subject.userInfo = null;
      expectLater(subject.acceptRequest(), throwsA(isA<PrintableError>()));
    });

    test('no partner in user info throws error', () async {
      UserInformation thisUserInfo = UserInformation(userID: linkCodeID, linkCode: MockDocumentReference(), firestore: firestore);
      subject.userInfo = thisUserInfo;
      expectLater(subject.acceptRequest(), throwsA(isA<PrintableError>()));
    });
  });

  group('unlink', () {
    late UserInfoState userInfoState;
    late UserInformation userInfo;
    late MockDocumentReference<UserInformation?> userRef;
    late UserInformation partnerInfo;

    setUp(() async {
      userInfoState = UserInfoState(firestore, partnersInfoState);
      userInfo = UserInformation(userID: userID, linkCode: linkCodeRef, firestore: firestore);
      partnerInfo = UserInformation(userID: '9876', linkCode: linkCodeRef, firestore: firestore);
      userRef = MockDocumentReference<UserInformation?>();

      userInfo.partner = userRef;
      userInfoState.userInfo = userInfo;
      when(userRef.id).thenReturn(userID);
      await firestore.collection(userInfoCollection).doc(userInfo.userID).set(userInfo.toMap());
      await firestore.collection(userInfoCollection).doc(partnerInfo.userID).set(partnerInfo.toMap());
    });

    test('valid user and partner infos updates infos and removes partner from state', () async {
      await userInfoState.unlink();
      when(partnersInfoState.removePartner(userInfo))
          .thenAnswer((realInvocation) => expect(realInvocation.positionalArguments.first['userID'], userInfo.userID));
      DocumentSnapshot user = await firestore.collection(userInfoCollection).doc(userInfo.userID).get();
      DocumentSnapshot partner = await firestore.collection(userInfoCollection).doc(partnerInfo.userID).get();
      expectLater(user.get('partner'), isNull);
      expectLater(partner.get('partner'), isNull);
    });

    test('no user info in state throws error', () async {
      userInfoState.userInfo = null;
      expectLater(userInfoState.unlink(), throwsA(isA<PrintableError>()));
    });

    test('no partner in user info throws error', () async {
      userInfoState.userInfo = UserInformation(userID: linkCodeID, linkCode: MockDocumentReference(), firestore: firestore);
      expectLater(userInfoState.unlink(), throwsA(isA<PrintableError>()));
    });
  });

  group('saveBars', () {
    late UserInformation userInfo;
    late RelationshipBarDocument barDocument;

    setUp(() async {
      subject = UserInfoState(firestore, partnersInfoState);
      userInfo = UserInformation(userID: userID, linkCode: linkCodeRef, firestore: firestore);
      barDocument = RelationshipBarDocument(id: "Test-ID", userID: userID, firestore: firestore);
      barDocument.barList = [
        RelationshipBar(label: 'Test1', order: 1, changed: true),
        RelationshipBar(label: 'Test2', order: 2, changed: false),
      ];
      subject.userInfo = userInfo;
      subject.latestRelationshipBarDoc = barDocument;
    });

    test('null userID does nothing', () async {
      subject.userInfo = null;
      await subject.saveBars();
      expect(subject.latestRelationshipBarDoc, isNull);
    });

    test('null barDoc does nothing', () async {
      await subject.saveBars();
      expect(subject.latestRelationshipBarDoc, isNull);
    });

    test('save resets bars changed and sets latestRelationshipBarDoc', () async {
      await subject.saveBars();

      expect(subject.latestRelationshipBarDoc, isNotNull);
      var barList = subject.latestRelationshipBarDoc?.barList;
      expect(barList, isNotNull);
      for (var bar in barList!) {
        expect(bar.changed, isFalse);
      }

      var firestoreDocs =
          await firestore.collection(userBarsCollection).doc(userID).collection(specificUserBarsCollection).get().then((snapshot) => snapshot.docs);
      expect(firestoreDocs, hasLength(1));
      var doc = firestoreDocs.single;
      expect(doc.id, equals(subject.latestRelationshipBarDoc?.id));
    });
  });
}
