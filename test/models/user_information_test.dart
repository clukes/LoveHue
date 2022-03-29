import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/relationship_bar_document.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/resources/database_and_table_names.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocker.mocks.dart';
import 'user_information_test.mocks.dart';

// Have to generate these manually; can't use Firebase_Auth_Mocks as they don't implement user.delete().
@GenerateMocks([User, FirebaseAuth])
void main() {
  const String userID = '1234';

  late FakeFirebaseFirestore firestore;
  late MockDocumentReference<LinkCode?> linkCodeRef;
  late UserInformation userInfo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    linkCodeRef = MockDocumentReference<LinkCode?>();
    userInfo = UserInformation(firestore: firestore, userID: userID, displayName: 'Test', linkCode: linkCodeRef);
  });

  group('fromMap', () {
    test('valid map should return UserInformation', () {
      Map<String, Object?> map = {
        UserInformation.columnUserID: '1234',
        UserInformation.columnDisplayName: 'Test',
        UserInformation.columnLinkCode: linkCodeRef
      };
      UserInformation result = UserInformation.fromMap(map, firestore);
      expect(result.userID, equals(userInfo.userID));
      expect(result.linkCode, equals(userInfo.linkCode));
      expect(result.displayName, equals(userInfo.displayName));
    });
  });

  group('toMap', () {
    test('valid UserInformation should return map', () {
      Map<String, Object?> expected = {
        UserInformation.columnUserID: '1234',
        UserInformation.columnDisplayName: 'Test',
        UserInformation.columnLinkCode: linkCodeRef
      };
      Map<String, Object?> result = userInfo.toMap();
      expect(result[UserInformation.columnUserID], equals(expected[UserInformation.columnUserID]));
      expect(result[UserInformation.columnLinkCode], equals(expected[UserInformation.columnLinkCode]));
      expect(result[UserInformation.columnDisplayName], equals(expected[UserInformation.columnDisplayName]));
    });
  });

  group('getUserInDatabase', () {
    test('gets correct document reference for valid user info', () async {
      DocumentReference<UserInformation?> result = userInfo.getUserInDatabase();
      expect(result.id, equals(userInfo.userID));
    });
  });

  group('getUserInDatabaseFromID', () {
    test('gets correct document reference with user id', () async {
      DocumentReference<UserInformation?> result = UserInformation.getUserInDatabaseFromID(userID, firestore);
      expect(result.id, equals(userID));
    });
  });

  group('firestoreGetFromID', () {
    test('should get correct UserInformation', () async {
      await firestore.collection(userInfoCollection).doc(userID).set(userInfo.toMap());
      UserInformation? result = await UserInformation.firestoreGetFromID(userID, firestore);

      expect(result, isNotNull);
      expect(result!.userID, equals(userInfo.userID));
      expect(result.displayName, equals(userInfo.displayName));
    });
  });

  group('firestoreSet', () {
    test('should create new UserInformation in database if not exist', () async {
      await userInfo.firestoreSet();
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(userInfo.userID));
      expect(result[UserInformation.columnDisplayName], equals(userInfo.displayName));
    });

    test('should update barDoc in database if exist', () async {
      await firestore.collection(userInfoCollection).doc(userID).set(userInfo.toMap());
      userInfo.displayName = 'Foo';
      await userInfo.firestoreSet();
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(userInfo.userID));
      expect(result[UserInformation.columnDisplayName], equals(userInfo.displayName));
    });
  });

  group('firestoreUpdateColumns', () {
    test('should update UserInformation in database', () async {
      String expectedDisplayName = 'Foo';

      await firestore.collection(userInfoCollection).doc(userID).set(userInfo.toMap());
      await userInfo.firestoreUpdateColumns({UserInformation.columnDisplayName: expectedDisplayName});
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(userInfo.userID));
      expect(result[UserInformation.columnDisplayName], equals(expectedDisplayName));
    });
  });

  group('firestoreDelete', () {
    test('should remove UserInformation from database', () async {
      await firestore.collection(userInfoCollection).doc(userID).set(userInfo.toMap());
      await userInfo.firestoreDelete();
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      expect(result, isNull);
    });
  });

  group('deleteUserData', () {
    late MockBuildContext context;
    late MockUser user;
    late MockFirebaseAuth firebaseAuth;
    late MockAuthenticationInfo authenticationInfo;

    setUp(() {
      context = MockBuildContext();
      user = MockUser();
      firebaseAuth = MockFirebaseAuth();
      authenticationInfo = MockAuthenticationInfo();
    });

    test("should remove UserInformation from database, delete account in auth, and set partner's partner to null",
        () async {
      String partnerID = '5678';

      when(user.uid).thenReturn(userID);
      when(firebaseAuth.currentUser).thenReturn(user);
      when(user.delete()).thenAnswer((_) async => when(firebaseAuth.currentUser).thenReturn(null));

      DocumentReference userDoc = firestore.collection(userInfoCollection).doc(user.uid);
      DocumentReference partnerDoc = firestore.collection(userInfoCollection).doc(partnerID);
      UserInformation partner =
          UserInformation(firestore: firestore, userID: partnerID, partner: userDoc, linkCode: linkCodeRef);
      UserInformation currentUser =
          UserInformation(firestore: firestore, userID: userID, partner: partnerDoc, linkCode: linkCodeRef);

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
          UserInformation(firestore: firestore, userID: partnerID, partner: userDoc, linkCode: linkCodeRef);
      userInfo.partner = partnerDoc;

      await partnerDoc.set(partner.toMap());
      await userDoc.set(userInfo.toMap());
      await userInfo.deleteUserData(context, firebaseAuth, authenticationInfo);
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
      when(user.uid).thenReturn(userID);
      when(firebaseAuth.currentUser).thenReturn(user);
      when(user.delete()).thenAnswer((_) async {
        throw FirebaseAuthException(code: 'requires-recent-login');
      });
      when(authenticationInfo.reauthenticate(context, firebaseAuth))
          .thenAnswer((realInvocation) => Future.value(false));

      DocumentReference userDoc = firestore.collection(userInfoCollection).doc(user.uid);

      await userDoc.set(userInfo.toMap());
      await expectLater(
          userInfo.deleteUserData(context, firebaseAuth, authenticationInfo), throwsA(isA<PrintableError>()));
      verify(authenticationInfo.reauthenticate(context, firebaseAuth));
    });

    test("no user signed in throws error", () async {
      when(firebaseAuth.currentUser).thenReturn(null);

      expectLater(userInfo.deleteUserData(context, firebaseAuth, authenticationInfo), throwsA(isA<PrintableError>()));
    });

    test("incorrect current user throws error", () async {
      when(user.uid).thenReturn('5678');
      when(firebaseAuth.currentUser).thenReturn(user);

      expectLater(userInfo.deleteUserData(context, firebaseAuth, authenticationInfo), throwsA(isA<PrintableError>()));
    });
  });

  group('setupUserInDatabase', () {
    late MockUserInfoState userInfoState;

    setUp(() {
      userInfoState = MockUserInfoState();
    });
    test('should create new UserInformation in database with default bars', () async {
      when(linkCodeRef.id).thenReturn('1');
      await userInfo.setupUserInDatabase(userInfoState);
      Map<String, dynamic>? result =
          await firestore.collection(userInfoCollection).doc(userID).get().then((value) => value.data());
      List<RelationshipBarDocument> bars = await RelationshipBarDocument.getUserBarsFromID(userID, firestore)
          .get()
          .then((value) => value.docs.map((doc) => doc.data()).toList());
      expect(result, isNotNull);
      expect(result![UserInformation.columnUserID], equals(userInfo.userID));
      expect(result[UserInformation.columnDisplayName], equals(userInfo.displayName));
      expect(bars, isNotEmpty);
    });
  });
}
