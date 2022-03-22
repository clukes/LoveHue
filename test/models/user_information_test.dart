import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:mockito/annotations.dart';

import 'link_code_test.mocks.dart';

@GenerateMocks([])
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

}
