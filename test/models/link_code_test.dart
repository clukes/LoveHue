import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/resources/database_and_table_names.dart';

import '../mocker.mocks.dart';

void main() {
  const String linkCodeID = '123';

  late MockDocumentReference<UserInformation?> userRef;
  late FakeFirebaseFirestore firestore;
  late LinkCode linkCode;

  setUp(() {
    userRef = MockDocumentReference<UserInformation?>();
    firestore = FakeFirebaseFirestore();
    linkCode = LinkCode(linkCode: linkCodeID, user: userRef);
  });

  group('fromMap', () {
    test('valid map should return link code', () {
      Map<String, Object?> map = {'linkCode': linkCodeID, 'user': userRef};
      LinkCode result = LinkCode.fromMap(map);
      expect(result.linkCode, linkCode.linkCode);
      expect(result.user, linkCode.user);
    });
  });

  group('toMap', () {
    test('valid LinkCode should return map', () {
      Map<String, Object?> expected = {'linkCode': linkCodeID, 'user': userRef};
      Map<String, Object?> result = linkCode.toMap();
      expect(result['linkCode'], expected['linkCode']);
      expect(result['user'], expected['user']);
    });
  });

  group('create', () {
    test('new link code reference is returned', () async {
      DocumentReference codeRef = await LinkCode.create(firestore);
      DocumentSnapshot codeSnapshot = await codeRef.get();
      expectLater(codeSnapshot.exists, isFalse);
    });

    test('link codes are different', () async {
      DocumentReference codeRef = await LinkCode.create(firestore);
      DocumentSnapshot codeSnapshot = await codeRef.get();
      expectLater(codeSnapshot.exists, isFalse);

      DocumentReference codeRef2 = await LinkCode.create(firestore);
      DocumentSnapshot codeSnapshot2 = await codeRef.get();
      expectLater(codeSnapshot2.exists, isFalse);

      expectLater(codeRef.id, isNot(codeRef2.id));
    });

    test('existing link code generates a new one', () async {
      firestore
          .collection(linkCodesCollection)
          .doc('1234')
          .set({'linkCode': '1234'});

      DocumentReference codeRef =
          await LinkCode.create(firestore, newCode: '1234');
      DocumentSnapshot codeSnapshot = await codeRef.get();
      expectLater(codeSnapshot.exists, isFalse);
      expectLater(codeRef.id, isNot('1234'));
    });
  });
}
