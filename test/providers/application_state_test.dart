import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/link_code.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/resources/database_and_table_names.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../models/link_code_test.mocks.dart';

@GenerateMocks([])
void main() {
  setUp(() {});
  tearDown(() {});

  const Duration timeout = Duration(seconds: 5);

  group('ApplicationState', () {
    final MockPartnersInfoState partnersInfoState = MockPartnersInfoState();
    final MockUser user = MockUser(uid: '1234', isAnonymous: true);

    test('new user login setups up user and logs in', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockUserInfoState userInfoState = MockUserInfoState();
      final MockFirebaseAuth auth = MockFirebaseAuth(mockUser: user);

      when(userInfoState.userInfo).thenReturn(null);
      when(userInfoState.latestRelationshipBarDoc).thenReturn(null);

      ApplicationState appState = ApplicationState(userInfoState, partnersInfoState, firestore, auth);
      expect(appState.loginState, equals(ApplicationLoginState.loggedOut));
      await auth.signInAnonymously();

      when(userInfoState.notifyListeners()).thenAnswer((realInvocation) async {
        expect(appState.loginState, equals(ApplicationLoginState.loggedIn));
        Map<String, dynamic>? info =
            await firestore.collection(userInfoCollection).doc(user.uid).get().then((value) => value.data());
        expectLater(info, isNotNull);
      });
      await untilCalled(userInfoState.notifyListeners())
          .then((value) => verify(userInfoState.notifyListeners()))
          .timeout(timeout);
    });

    test('user login with partner adds partner to state and logs in', () async {
      final MockUserInfoState userInfoState = MockUserInfoState();
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockFirebaseAuth auth = MockFirebaseAuth(mockUser: user);

      when(userInfoState.userInfo).thenReturn(null);
      when(userInfoState.latestRelationshipBarDoc).thenReturn(null);

      UserInformation partnersInfo =
          UserInformation(userID: '6789', firestore: firestore, linkCode: MockDocumentReference<LinkCode>());
      DocumentReference partnersDoc = firestore.collection(userInfoCollection).doc(partnersInfo.userID);
      await partnersDoc.set(partnersInfo.toMap());
      UserInformation userInfo = UserInformation(
          userID: user.uid, partner: partnersDoc, firestore: firestore, linkCode: MockDocumentReference<LinkCode>());
      await firestore.collection(userInfoCollection).doc(user.uid).set(userInfo.toMap());

      ApplicationState appState = ApplicationState(userInfoState, partnersInfoState, firestore, auth);
      expect(appState.loginState, equals(ApplicationLoginState.loggedOut));
      await auth.signInAnonymously();
      when(userInfoState.notifyListeners()).thenAnswer((realInvocation) async {
        expect(appState.loginState, equals(ApplicationLoginState.loggedIn));
        Map<String, dynamic>? info =
            await firestore.collection(userInfoCollection).doc(user.uid).get().then((value) => value.data());
        expect(info, isNotNull);
        expect(userInfo, isNotNull);
        var captured = verify(partnersInfoState.addPartner(captureAny, captureAny)).captured;
        expect(captured[0].userID, partnersInfo.userID);
        expect(captured[1].userID, userInfo.userID);
      });
      await untilCalled(userInfoState.notifyListeners())
          .then((value) => verify(userInfoState.notifyListeners()))
          .timeout(timeout);
    });

    test('changed display name updates in database', () async {
      final MockUserInfoState userInfoState = MockUserInfoState();
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockUser user = MockUser(uid: '1234');
      final MockFirebaseAuth auth = MockFirebaseAuth(mockUser: user, signedIn: true);

      UserInformation userInfo = UserInformation(
          userID: user.uid,
          displayName: user.displayName,
          firestore: firestore,
          linkCode: MockDocumentReference<LinkCode>());
      await firestore.collection(userInfoCollection).doc(user.uid).set(userInfo.toMap());

      when(userInfoState.userExist).thenReturn(true);
      when(userInfoState.userInfo).thenReturn(userInfo);
      when(userInfoState.latestRelationshipBarDoc).thenReturn(null);

      ApplicationState appState = ApplicationState(userInfoState, partnersInfoState, firestore, auth);
      appState.loginState = ApplicationLoginState.loggedIn;

      String displayName = 'Test';
      await user.updateDisplayName(displayName);
      await untilCalled(
              userInfoState.userInfo?.firestoreUpdateColumns({UserInformation.columnDisplayName: displayName}))
          .then((value) =>
              verify(userInfoState.userInfo?.firestoreUpdateColumns({UserInformation.columnDisplayName: displayName})))
          .timeout(timeout);
    });

    test('sign out resets app state', () async {
      final MockUserInfoState userInfoState = MockUserInfoState();
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockUser user = MockUser(uid: '1234');
      final MockFirebaseAuth auth = MockFirebaseAuth(mockUser: user, signedIn: true);

      UserInformation userInfo = UserInformation(
          userID: user.uid,
          displayName: user.displayName,
          firestore: firestore,
          linkCode: MockDocumentReference<LinkCode>());
      await firestore.collection(userInfoCollection).doc(user.uid).set(userInfo.toMap());

      when(userInfoState.userExist).thenReturn(true);
      when(userInfoState.userInfo).thenReturn(userInfo);
      when(userInfoState.latestRelationshipBarDoc).thenReturn(null);

      ApplicationState appState = ApplicationState(userInfoState, partnersInfoState, firestore, auth);
      appState.loginState = ApplicationLoginState.loggedIn;

      await auth.signOut();
      when(userInfoState.removeUser()).thenAnswer((realInvocation) async {
        expect(appState.loginState, equals(ApplicationLoginState.loading));
        verify(partnersInfoState.removePartner(captureAny));
      });
      await untilCalled(userInfoState.removeUser()).then((value) =>
        verify(userInfoState.removeUser())).timeout(timeout);
      expect(appState.loginState, equals(ApplicationLoginState.loggedOut));
    });
  });
}
