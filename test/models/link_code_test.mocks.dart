// Mocks generated by Mockito 5.1.0 from annotations
// in lovehue/test/models/link_code_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i9;
import 'dart:ui' as _i8;

import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:firebase_auth/firebase_auth.dart' as _i10;
import 'package:flutter/material.dart' as _i4;
import 'package:lovehue/models/relationship_bar_document.dart' as _i7;
import 'package:lovehue/models/user_information.dart' as _i6;
import 'package:lovehue/providers/partners_info_state.dart' as _i2;
import 'package:lovehue/providers/user_info_state.dart' as _i5;
import 'package:lovehue/resources/authenticationInfo.dart' as _i11;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakePartnersInfoState_0 extends _i1.Fake
    implements _i2.PartnersInfoState {}

class _FakeFirebaseFirestore_1 extends _i1.Fake
    implements _i3.FirebaseFirestore {}

class _FakeValueNotifier_2<T> extends _i1.Fake implements _i4.ValueNotifier<T> {
}

class _FakeCollectionReference_3<T extends Object?> extends _i1.Fake
    implements _i3.CollectionReference<T> {}

class _FakeDocumentSnapshot_4<T extends Object?> extends _i1.Fake
    implements _i3.DocumentSnapshot<T> {}

class _FakeDocumentReference_5<T extends Object?> extends _i1.Fake
    implements _i3.DocumentReference<T> {}

/// A class which mocks [UserInfoState].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserInfoState extends _i1.Mock implements _i5.UserInfoState {
  MockUserInfoState() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PartnersInfoState get partnersInfoState =>
      (super.noSuchMethod(Invocation.getter(#partnersInfoState),
          returnValue: _FakePartnersInfoState_0()) as _i2.PartnersInfoState);
  @override
  _i3.FirebaseFirestore get firestore =>
      (super.noSuchMethod(Invocation.getter(#firestore),
          returnValue: _FakeFirebaseFirestore_1()) as _i3.FirebaseFirestore);
  @override
  set userInfo(_i6.UserInformation? _userInfo) =>
      super.noSuchMethod(Invocation.setter(#userInfo, _userInfo),
          returnValueForMissingStub: null);
  @override
  set latestRelationshipBarDoc(
          _i7.RelationshipBarDocument? _latestRelationshipBarDoc) =>
      super.noSuchMethod(
          Invocation.setter(
              #latestRelationshipBarDoc, _latestRelationshipBarDoc),
          returnValueForMissingStub: null);
  @override
  bool get barsChanged =>
      (super.noSuchMethod(Invocation.getter(#barsChanged), returnValue: false)
          as bool);
  @override
  set barsChanged(bool? _barsChanged) =>
      super.noSuchMethod(Invocation.setter(#barsChanged, _barsChanged),
          returnValueForMissingStub: null);
  @override
  bool get barsReset =>
      (super.noSuchMethod(Invocation.getter(#barsReset), returnValue: false)
          as bool);
  @override
  set barsReset(bool? _barsReset) =>
      super.noSuchMethod(Invocation.setter(#barsReset, _barsReset),
          returnValueForMissingStub: null);
  @override
  bool get userExist =>
      (super.noSuchMethod(Invocation.getter(#userExist), returnValue: false)
          as bool);
  @override
  bool get userPending =>
      (super.noSuchMethod(Invocation.getter(#userPending), returnValue: false)
          as bool);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  bool partnerLinked() =>
      (super.noSuchMethod(Invocation.method(#partnerLinked, []),
          returnValue: false) as bool);
  @override
  void setupUserInfoSubscription() =>
      super.noSuchMethod(Invocation.method(#setupUserInfoSubscription, []),
          returnValueForMissingStub: null);
  @override
  void addUser(_i6.UserInformation? newUserInfo) =>
      super.noSuchMethod(Invocation.method(#addUser, [newUserInfo]),
          returnValueForMissingStub: null);
  @override
  void removeUser() => super.noSuchMethod(Invocation.method(#removeUser, []),
      returnValueForMissingStub: null);
  @override
  void barChange() => super.noSuchMethod(Invocation.method(#barChange, []),
      returnValueForMissingStub: null);
  @override
  void resetBarChange() =>
      super.noSuchMethod(Invocation.method(#resetBarChange, []),
          returnValueForMissingStub: null);
  @override
  void addListener(_i8.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i8.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [PartnersInfoState].
///
/// See the documentation for Mockito's code generation for more information.
class MockPartnersInfoState extends _i1.Mock implements _i2.PartnersInfoState {
  MockPartnersInfoState() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.ValueNotifier<String> get partnersName =>
      (super.noSuchMethod(Invocation.getter(#partnersName),
              returnValue: _FakeValueNotifier_2<String>())
          as _i4.ValueNotifier<String>);
  @override
  set partnersName(_i4.ValueNotifier<String>? _partnersName) =>
      super.noSuchMethod(Invocation.setter(#partnersName, _partnersName),
          returnValueForMissingStub: null);
  @override
  bool get partnerExist =>
      (super.noSuchMethod(Invocation.getter(#partnerExist), returnValue: false)
          as bool);
  @override
  bool get partnerPending => (super
          .noSuchMethod(Invocation.getter(#partnerPending), returnValue: false)
      as bool);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  void notify() => super.noSuchMethod(Invocation.method(#notify, []),
      returnValueForMissingStub: null);
  @override
  void setupPartnerInfoSubscription(_i6.UserInformation? currentUserInfo) =>
      super.noSuchMethod(
          Invocation.method(#setupPartnerInfoSubscription, [currentUserInfo]),
          returnValueForMissingStub: null);
  @override
  void addPartner(_i6.UserInformation? newPartnerInfo,
          _i6.UserInformation? currentUserInfo) =>
      super.noSuchMethod(
          Invocation.method(#addPartner, [newPartnerInfo, currentUserInfo]),
          returnValueForMissingStub: null);
  @override
  void removePartner(_i6.UserInformation? currentUserInfo) =>
      super.noSuchMethod(Invocation.method(#removePartner, [currentUserInfo]),
          returnValueForMissingStub: null);
  @override
  void addListener(_i8.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i8.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [DocumentReference].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockDocumentReference<T extends Object?> extends _i1.Mock
    implements _i3.DocumentReference<T> {
  MockDocumentReference() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.FirebaseFirestore get firestore =>
      (super.noSuchMethod(Invocation.getter(#firestore),
          returnValue: _FakeFirebaseFirestore_1()) as _i3.FirebaseFirestore);
  @override
  String get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: '') as String);
  @override
  _i3.CollectionReference<T> get parent =>
      (super.noSuchMethod(Invocation.getter(#parent),
              returnValue: _FakeCollectionReference_3<T>())
          as _i3.CollectionReference<T>);
  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: '') as String);
  @override
  _i3.CollectionReference<Map<String, dynamic>> collection(
          String? collectionPath) =>
      (super.noSuchMethod(Invocation.method(#collection, [collectionPath]),
              returnValue: _FakeCollectionReference_3<Map<String, dynamic>>())
          as _i3.CollectionReference<Map<String, dynamic>>);
  @override
  _i9.Future<void> delete() =>
      (super.noSuchMethod(Invocation.method(#delete, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> update(Map<String, Object?>? data) =>
      (super.noSuchMethod(Invocation.method(#update, [data]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<_i3.DocumentSnapshot<T>> get([_i3.GetOptions? options]) =>
      (super.noSuchMethod(Invocation.method(#get, [options]),
              returnValue: Future<_i3.DocumentSnapshot<T>>.value(
                  _FakeDocumentSnapshot_4<T>()))
          as _i9.Future<_i3.DocumentSnapshot<T>>);
  @override
  _i9.Stream<_i3.DocumentSnapshot<T>> snapshots(
          {bool? includeMetadataChanges = false}) =>
      (super.noSuchMethod(
              Invocation.method(#snapshots, [],
                  {#includeMetadataChanges: includeMetadataChanges}),
              returnValue: Stream<_i3.DocumentSnapshot<T>>.empty())
          as _i9.Stream<_i3.DocumentSnapshot<T>>);
  @override
  _i9.Future<void> set(T? data, [_i3.SetOptions? options]) =>
      (super.noSuchMethod(Invocation.method(#set, [data, options]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i3.DocumentReference<R> withConverter<R>(
          {_i3.FromFirestore<R>? fromFirestore,
          _i3.ToFirestore<R>? toFirestore}) =>
      (super.noSuchMethod(
              Invocation.method(#withConverter, [],
                  {#fromFirestore: fromFirestore, #toFirestore: toFirestore}),
              returnValue: _FakeDocumentReference_5<R>())
          as _i3.DocumentReference<R>);
}

/// A class which mocks [UserInformation].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserInformation extends _i1.Mock implements _i6.UserInformation {
  MockUserInformation() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get userID =>
      (super.noSuchMethod(Invocation.getter(#userID), returnValue: '')
          as String);
  @override
  set displayName(String? _displayName) =>
      super.noSuchMethod(Invocation.setter(#displayName, _displayName),
          returnValueForMissingStub: null);
  @override
  set partner(_i3.DocumentReference<Object?>? _partner) =>
      super.noSuchMethod(Invocation.setter(#partner, _partner),
          returnValueForMissingStub: null);
  @override
  _i3.DocumentReference<Object?> get linkCode =>
      (super.noSuchMethod(Invocation.getter(#linkCode),
              returnValue: _FakeDocumentReference_5<Object?>())
          as _i3.DocumentReference<Object?>);
  @override
  set linkCode(_i3.DocumentReference<Object?>? _linkCode) =>
      super.noSuchMethod(Invocation.setter(#linkCode, _linkCode),
          returnValueForMissingStub: null);
  @override
  bool get linkPending =>
      (super.noSuchMethod(Invocation.getter(#linkPending), returnValue: false)
          as bool);
  @override
  set linkPending(bool? _linkPending) =>
      super.noSuchMethod(Invocation.setter(#linkPending, _linkPending),
          returnValueForMissingStub: null);
  @override
  _i3.FirebaseFirestore get firestore =>
      (super.noSuchMethod(Invocation.getter(#firestore),
          returnValue: _FakeFirebaseFirestore_1()) as _i3.FirebaseFirestore);
  @override
  Map<String, Object?> toMap() =>
      (super.noSuchMethod(Invocation.method(#toMap, []),
          returnValue: <String, Object?>{}) as Map<String, Object?>);
  @override
  _i3.DocumentReference<_i6.UserInformation?> getUserInDatabase() =>
      (super.noSuchMethod(Invocation.method(#getUserInDatabase, []),
              returnValue: _FakeDocumentReference_5<_i6.UserInformation?>())
          as _i3.DocumentReference<_i6.UserInformation?>);
  @override
  _i9.Future<void> firestoreSet() =>
      (super.noSuchMethod(Invocation.method(#firestoreSet, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> firestoreUpdateColumns(Map<String, Object?>? data) =>
      (super.noSuchMethod(Invocation.method(#firestoreUpdateColumns, [data]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> firestoreDelete() =>
      (super.noSuchMethod(Invocation.method(#firestoreDelete, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> deleteUserData(
          _i4.BuildContext? context,
          _i10.FirebaseAuth? auth,
          _i11.AuthenticationInfo? authenticationInfo) =>
      (super.noSuchMethod(
          Invocation.method(
              #deleteUserData, [context, auth, authenticationInfo]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<void> setupUserInDatabase(_i5.UserInfoState? userInfoState) =>
      (super.noSuchMethod(
          Invocation.method(#setupUserInDatabase, [userInfoState]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i9.Future<void>);
}
