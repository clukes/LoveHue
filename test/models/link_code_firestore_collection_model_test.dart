import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code_firestore_collection_model.dart';
import 'package:lovehue/models/userinfo_firestore_collection_model.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'link_code_firestore_collection_model_test.mocks.dart';

@GenerateMocks([PartnersInfoState, DocumentReference])
void main() {
  setUp(() {});
  tearDown(() {});

  MockDocumentReference<UserInformation?> ref = MockDocumentReference<UserInformation?>();

  group('fromMap', () {
    test('valid LinkCode should map', () {
      LinkCode expected = LinkCode(linkCode: '123', user: ref);
      Map<String, Object?> map = {'linkCode': '123', 'user': ref};
      LinkCode result = LinkCode.fromMap(map);
      expect(result.linkCode, expected.linkCode);
      expect(result.user, expected.user);
    });
  });

  group('toMap', () {
    test('valid LinkCode should map', () {
      Map<String, Object?> expected = {'linkCode': '123', 'user': ref};
      LinkCode code = LinkCode(linkCode: '123', user: ref);
      Map<String, Object?> result = code.toMap();
      expect(result['linkCode'], expected['linkCode']);
      expect(result['user'], expected['user']);
    });
  });

  group('connectTo', () {
    test('pending partner throws error', () async {
      MockPartnersInfoState partnerInfoState = MockPartnersInfoState();
      when(partnerInfoState.partnerLinked).thenAnswer((_)=>true);
      when(partnerInfoState.partnerPending).thenAnswer((_)=>true);
      expectLater(LinkCode.connectTo('123'), throwsA(isA<PrintableError>()));
    });

    test('linked partner throws error', () async {
      when(partnerInfoState.partnerExist).thenReturn(true);
      when(partnerInfoState.partnerPending).thenReturn(true);
      // when(PartnersInfoState.instance).thenReturn(partnerInfoState);
      expectLater(LinkCode.connectTo('123'), throwsA(isA<PrintableError>()));
    });
  });
}