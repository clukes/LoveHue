import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/relationship_bar_document.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/resources/authenticationInfo.dart';
import 'package:lovehue/resources/database_and_table_names.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'link_code_test.mocks.dart';
import 'user_information_test.mocks.dart';

@GenerateMocks([BuildContext, FirebaseAuth, User, AuthenticationInfo])
void main() {
  setUp(() {});
  tearDown(() {});

  group('fromMap', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('valid map should return UserInformation', () {
      UserInformation expected =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      Map<String, Object?> map = {
        UserInformation.columnUserID: '1234',
        UserInformation.columnDisplayName: 'Test',
        UserInformation.columnLinkCode: ref
      };
      UserInformation result = UserInformation.fromMap(map, firestore);
      expect(result.userID, equals(expected.userID));
      expect(result.linkCode, equals(expected.linkCode));
      expect(result.displayName, equals(expected.displayName));
    });
  });

  group('toMap', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('valid UserInformation should return map', () {
      Map<String, Object?> expected = {
        UserInformation.columnUserID: '1234',
        UserInformation.columnDisplayName: 'Test',
        UserInformation.columnLinkCode: ref
      };
      UserInformation userInfo =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      Map<String, Object?> result = userInfo.toMap();
      expect(result[UserInformation.columnUserID], equals(expected[UserInformation.columnUserID]));
      expect(result[UserInformation.columnLinkCode], equals(expected[UserInformation.columnLinkCode]));
      expect(result[UserInformation.columnDisplayName], equals(expected[UserInformation.columnDisplayName]));
    });
  });

  group('toMap', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('valid UserInformation should return map', () {
      Map<String, Object?> expected = {
        UserInformation.columnUserID: '1234',
        UserInformation.columnDisplayName: 'Test',
        UserInformation.columnLinkCode: ref
      };
      UserInformation userInfo =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      Map<String, Object?> result = userInfo.toMap();
      expect(result[UserInformation.columnUserID], equals(expected[UserInformation.columnUserID]));
      expect(result[UserInformation.columnLinkCode], equals(expected[UserInformation.columnLinkCode]));
      expect(result[UserInformation.columnDisplayName], equals(expected[UserInformation.columnDisplayName]));
    });
  });

  group('getUserInDatabase', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('gets correct document reference for valid user info', () async {
      UserInformation userInfo = UserInformation(firestore: firestore, userID: '1234', linkCode: ref);
      DocumentReference<UserInformation?> result = userInfo.getUserInDatabase();
      expect(result.id, equals(userInfo.userID));
    });
  });

  group('getUserInDatabaseFromID', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    test('gets correct document reference with user id', () async {
      String userID = '1234';
      DocumentReference<UserInformation?> result = UserInformation.getUserInDatabaseFromID(userID, firestore);
      expect(result.id, equals(userID));
    });
  });

  group('firestoreGetFromID', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('should get correct UserInformation', () async {
      String userID = '1234';
      UserInformation userInfo =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      await firestore.collection(userInfoCollection).doc(userID).set(userInfo.toMap());
      UserInformation? result = await UserInformation.firestoreGetFromID(userID, firestore);

      expect(result, isNotNull);
      expect(result!.userID, equals(userInfo.userID));
      expect(result.displayName, equals(userInfo.displayName));
    });
  });

  group('firestoreSet', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('should create new UserInformation in database if not exist', () async {
      String userID = '1234';
      UserInformation expected =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      await expected.firestoreSet();
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(expected.userID));
      expect(result[UserInformation.columnDisplayName], equals(expected.displayName));
    });

    test('should update barDoc in database if exist', () async {
      String userID = '1234';
      UserInformation expected =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      await firestore.collection(userInfoCollection).doc(userID).set(expected.toMap());
      expected.displayName = 'Foo';
      await expected.firestoreSet();
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(expected.userID));
      expect(result[UserInformation.columnDisplayName], equals(expected.displayName));
    });
  });

  group('firestoreUpdateColumns', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('should update UserInformation in database', () async {
      String userID = '1234';
      String expectedDisplayName = 'Foo';
      UserInformation expected =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      await firestore.collection(userInfoCollection).doc(userID).set(expected.toMap());
      await expected.firestoreUpdateColumns({UserInformation.columnDisplayName: expectedDisplayName});
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(expected.userID));
      expect(result[UserInformation.columnDisplayName], equals(expectedDisplayName));
    });
  });

  group('firestoreDelete', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();

    test('should remove UserInformation from database', () async {
      String userID = '1234';
      UserInformation expected =
          UserInformation(firestore: firestore, userID: '1234', displayName: 'Test', linkCode: ref);
      await firestore.collection(userInfoCollection).doc(userID).set(expected.toMap());
      await expected.firestoreDelete();
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNull);
    });
  });

  group('deleteUserData', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();
    final MockBuildContext context = MockBuildContext();
    final MockUser user = MockUser();
    final MockFirebaseAuth firebaseAuth = MockFirebaseAuth();
    final MockAuthenticationInfo authenticationInfo = MockAuthenticationInfo();

    test("should remove UserInformation from database, delete account in auth, and set partner's partner to null",
        () async {
      String userID = '1234';
      String partnerID = '5678';

      when(user.uid).thenReturn(userID);
      when(firebaseAuth.currentUser).thenReturn(user);
      when(user.delete()).thenAnswer((_) async => when(firebaseAuth.currentUser).thenReturn(null));

      DocumentReference userDoc = firestore.collection(userInfoCollection).doc(user.uid);
      DocumentReference partnerDoc = firestore.collection(userInfoCollection).doc(partnerID);
      UserInformation partner =
          UserInformation(firestore: firestore, userID: partnerID, partner: userDoc, linkCode: ref);
      UserInformation currentUser =
          UserInformation(firestore: firestore, userID: userID, partner: partnerDoc, linkCode: ref);

      await partnerDoc.set(partner.toMap());
      await userDoc.set(currentUser.toMap());
      await currentUser.deleteUserData(context, firebaseAuth, authenticationInfo);
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      Map<String, dynamic>? partnerResult =
          await firestore.collection(userInfoCollection).doc(partnerID).get().then((value) => value.data());
      expect(result, isNull);
      expect(firebaseAuth.currentUser, isNull);
      expect(partnerResult![UserInformation.columnPartner], isNull);
    });

    test("no recent sign in reauthenticates then deletes", () async {
      String userID = '1234';
      String partnerID = '5678';

      when(user.uid).thenReturn(userID);
      when(firebaseAuth.currentUser).thenReturn(user);
      bool deleteCalled = false;
      when(user.delete()).thenAnswer((_) async {
        if (!deleteCalled) {
          deleteCalled = true;
          throw FirebaseAuthException(code: 'requires-recent-login');
        } else {
          when(firebaseAuth.currentUser).thenReturn(null);
        }
      });
      when(authenticationInfo.reauthenticate(context, firebaseAuth)).thenAnswer((realInvocation) => Future.value(true));

      DocumentReference userDoc = firestore.collection(userInfoCollection).doc(user.uid);
      DocumentReference partnerDoc = firestore.collection(userInfoCollection).doc(partnerID);
      UserInformation partner =
          UserInformation(firestore: firestore, userID: partnerID, partner: userDoc, linkCode: ref);
      UserInformation currentUser =
          UserInformation(firestore: firestore, userID: userID, partner: partnerDoc, linkCode: ref);

      await partnerDoc.set(partner.toMap());
      await userDoc.set(currentUser.toMap());
      await currentUser.deleteUserData(context, firebaseAuth, authenticationInfo);
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      Map<String, dynamic>? partnerResult =
          await firestore.collection(userInfoCollection).doc(partnerID).get().then((value) => value.data());

      verify(authenticationInfo.reauthenticate(context, firebaseAuth));
      expect(result, isNull);
      expect(firebaseAuth.currentUser, isNull);
      expect(partnerResult![UserInformation.columnPartner], isNull);
    });

    test("no recent sign and failed reauthentication throws error", () async {
      String userID = '1234';

      when(user.uid).thenReturn(userID);
      when(firebaseAuth.currentUser).thenReturn(user);
      when(user.delete()).thenAnswer((_) async {
          throw FirebaseAuthException(code: 'requires-recent-login');
      });
      when(authenticationInfo.reauthenticate(context, firebaseAuth)).thenAnswer((realInvocation) => Future.value(false));

      DocumentReference userDoc = firestore.collection(userInfoCollection).doc(user.uid);
      UserInformation currentUser =
      UserInformation(firestore: firestore, userID: userID, linkCode: ref);

      await userDoc.set(currentUser.toMap());
      await expectLater(currentUser.deleteUserData(context, firebaseAuth, authenticationInfo), throwsA(isA<PrintableError>()));
      verify(authenticationInfo.reauthenticate(context, firebaseAuth));
    });

    test("no user signed in throws error", () async {
      when(firebaseAuth.currentUser).thenReturn(null);

      UserInformation currentUser = UserInformation(firestore: firestore, userID: '1234', linkCode: ref);

      expectLater(currentUser.deleteUserData(context, firebaseAuth, authenticationInfo), throwsA(isA<PrintableError>()));
    });

    test("incorrect current user throws error", () async {
      String userID = '1234';

      when(user.uid).thenReturn('5678');
      when(firebaseAuth.currentUser).thenReturn(user);

      UserInformation currentUser = UserInformation(firestore: firestore, userID: userID, linkCode: ref);

      expectLater(currentUser.deleteUserData(context, firebaseAuth, authenticationInfo), throwsA(isA<PrintableError>()));
    });
  });

  group('setupUserInDatabase', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final MockDocumentReference<LinkCode?> ref = MockDocumentReference<LinkCode?>();
    final MockUserInfoState userInfoState = MockUserInfoState();

    test('should create new UserInformation in database with default bars', () async {
      when(ref.id).thenReturn('1');
      String userID = '1234';
      UserInformation expected = UserInformation(firestore: firestore, userID: userID, displayName: 'Test', linkCode: ref);
      await expected.setupUserInDatabase(userInfoState);
      Map<String, dynamic>? result = await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      List<RelationshipBarDocument> bars = await RelationshipBarDocument.getUserBarsFromID(userID, firestore).get().then((value) => value.docs.map((doc) => doc.data()).toList());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(expected.userID));
      expect(result[UserInformation.columnDisplayName], equals(expected.displayName));
      expect(bars, isNotEmpty);
    });
  });
}
