import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/pages/link_partner_screen.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.dart';
import '../mocker.mocks.dart';

//TODO: IncomingLinkRequest next

void main() {
  late MockUserInfoState userInfoState;
  late MockPartnersInfoState partnersInfoState;
  late Widget testWidget;
  late Widget testWidgetBuild;
  setUp(() {
    userInfoState = MockUserInfoState();
    partnersInfoState = MockPartnersInfoState();
    testWidget = const LinkPartnerScreen();
    testWidgetBuild = MaterialApp(
        home: MultiProvider(
      providers: [
        ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
        ChangeNotifierProvider<PartnersInfoState>.value(
            value: partnersInfoState)
      ],
      child: Scaffold(body: testWidget),
    ));

    when(userInfoState.userPending).thenReturn(false);
    when(partnersInfoState.partnerPending).thenReturn(false);
    when(partnersInfoState.partnerExist).thenReturn(true);
    when(userInfoState.partnerLinked).thenReturn(false);
    when(partnersInfoState.linkCode).thenReturn(null);
    when(userInfoState.linkCode).thenReturn(null);
  });

  group('LinkPartnerScreen', () {
    testWidgets('userPending displays incoming link request',
        (WidgetTester tester) async {
      when(userInfoState.userPending).thenReturn(true);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byType(IncomingLinkRequest), findsOneWidget);
    });

    testWidgets('partnerPending displays link request sent',
        (WidgetTester tester) async {
      when(partnersInfoState.partnerPending).thenReturn(true);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byType(LinkRequestSent), findsOneWidget);
    });

    testWidgets('not partnerExist displays link partner form',
        (WidgetTester tester) async {
      when(partnersInfoState.partnerExist).thenReturn(false);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byType(LinkPartnerForm), findsOneWidget);
    });

    testWidgets('partnerLinked displays loading', (WidgetTester tester) async {
      when(userInfoState.partnerLinked).thenReturn(true);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('No user linkcode displays loading...',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      expect(find.text('Your link code is:'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('user linkcode is displayed', (WidgetTester tester) async {
      const linkCode = '1234';
      when(userInfoState.linkCode).thenReturn(linkCode);
      await tester.pumpWidget(testWidgetBuild);
      expect(find.text('Your link code is:'), findsOneWidget);
      expect(find.text(linkCode), findsOneWidget);
    });

    testWidgets('copy button copies to clipboard', (WidgetTester tester) async {
      final MockClipboard mockClipboard = MockClipboard();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, mockClipboard.handleMethodCall);

      const linkCode = '1234';
      when(userInfoState.linkCode).thenReturn(linkCode);
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byIcon(Icons.copy));
      expect(mockClipboard.clipboardData['text'], equals(linkCode));
    });
  });

  group('LinkPartnerForm', () {
    var linkButtonFinder = find.ancestor(
        of: find.byIcon(Icons.person_add_alt_1),
        matching: find.byWidgetPredicate((widget) => widget is OutlinedButton));
    var linkCodeFieldFinder = find.widgetWithText(TextFormField, 'Link code');

    setUp(() {
      when(partnersInfoState.partnerExist).thenReturn(false);
    });

    testWidgets('null link code gives error', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(linkButtonFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining('Please enter a code.'), findsOneWidget);
    });

    testWidgets('empty link code gives error', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.enterText(linkCodeFieldFinder, "");
      await tester.tap(linkButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text('Please enter a code.'), findsOneWidget);
    });

    testWidgets('short link code gives error', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.enterText(linkCodeFieldFinder, "1");
      await tester.tap(linkButtonFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining('Code too short.'), findsOneWidget);
    });

    testWidgets('long link code gives error', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.enterText(linkCodeFieldFinder, "123456789101112131415");
      await tester.tap(linkButtonFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining('Code too long.'), findsOneWidget);
    });

    testWidgets('users own link code gives error', (WidgetTester tester) async {
      String userCode = "12345";
      when(userInfoState.linkCode).thenReturn(userCode);
      await tester.pumpWidget(testWidgetBuild);
      await tester.enterText(linkCodeFieldFinder, userCode);
      await tester.tap(linkButtonFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining("You can't be your own partner."),
          findsOneWidget);
    });

    testWidgets('successful link gives no error', (WidgetTester tester) async {
      String linkCode = "12345";
      await tester.pumpWidget(testWidgetBuild);
      await tester.enterText(linkCodeFieldFinder, linkCode);
      await tester.tap(linkButtonFinder);
      await tester.pumpAndSettle();
      verify(userInfoState.connectTo(linkCode));
      expect(find.textContaining("Error"), findsNothing);
    });

    testWidgets('unsuccessful link displays error',
        (WidgetTester tester) async {
      String errorMsg = "TestError";
      String userCode = "12345";
      when(userInfoState.connectTo(userCode))
          .thenAnswer((_) async => throw PrintableError(errorMsg));
      await tester.pumpWidget(testWidgetBuild);
      await tester.enterText(linkCodeFieldFinder, userCode);
      await tester.tap(linkButtonFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining("Error: $errorMsg"), findsOneWidget);
    });

    testWidgets('linking submit shows then hides snack bar',
        (WidgetTester tester) async {
      String userCode = "12345";
      Completer completer = Completer();
      when(userInfoState.connectTo(userCode))
          .thenAnswer((_) async => completer.future);
      await tester.pumpWidget(testWidgetBuild);
      await tester.enterText(linkCodeFieldFinder, userCode);
      await tester.tap(linkButtonFinder);
      expect(find.widgetWithText(SnackBar, "Linking..."), findsNothing);
      await tester.pump();
      expect(find.widgetWithText(SnackBar, "Linking..."), findsOneWidget);
      // Complete the future to finish execution and hide snackbar
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Linking..."), findsNothing);
    });
  });

  group('LinkRequestSent', () {
    var cancelButtonFinder = find.widgetWithText(OutlinedButton, "Cancel");

    setUp(() {
      when(partnersInfoState.partnerPending).thenReturn(true);
    });

    testWidgets('null partner link code displays error',
        (WidgetTester tester) async {
      when(partnersInfoState.linkCode).thenReturn(null);

      await tester.pumpWidget(testWidgetBuild);

      expect(
          find.textContaining('[Error: no partner link code]'), findsOneWidget);
    });

    testWidgets('partner link code is displayed', (WidgetTester tester) async {
      String linkCode = "12345";
      when(partnersInfoState.linkCode).thenReturn(linkCode);

      await tester.pumpWidget(testWidgetBuild);

      expect(find.textContaining("Link request sent to: $linkCode"),
          findsOneWidget);
    });

    testWidgets('cancel button shows then hides snack bar',
        (WidgetTester tester) async {
      Completer completer = Completer();
      when(userInfoState.unlink()).thenAnswer((_) async => completer.future);
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(cancelButtonFinder);
      expect(find.widgetWithText(SnackBar, "Cancelling..."), findsNothing);
      await tester.pump();
      expect(find.widgetWithText(SnackBar, "Cancelling..."), findsOneWidget);
      // Complete the future to finish execution and hide snackbar
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Cancelling..."), findsNothing);
    });

    testWidgets('cancel button calls unlink', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(cancelButtonFinder);
      verify(userInfoState.unlink());
    });

    testWidgets('cancel button displays error on unlink',
        (WidgetTester tester) async {
      var error = PrintableError("Test-Error");
      when(userInfoState.unlink()).thenThrow(error);
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(cancelButtonFinder);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Error: $error."), findsOneWidget);
    });
  });
}
