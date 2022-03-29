import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/resources/printable_error.dart';
import 'package:lovehue/widgets/profile_page_widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.dart';
import '../mocker.mocks.dart';

void main() {
  const buttonKey = Key("ALERT_DIALOG_BUTTON");

  group('showAlertDialog', () {
    const titleText = Text('TEST_ALERT_TITLE');
    const yesButtonText = Text('TEST_YES');
    const noButtonText = Text('TEST_NO');
    const contentWidget = Text('TEST_CONTENT');
    final yesPressed = MockFunction();
    final noPressed = MockFunction();

    final Widget testWidget = Builder(
        builder: (context) => MaterialButton(
              key: buttonKey,
              onPressed: () => showAlertDialog(
                context: context,
                alertTitle: titleText,
                alertContent: contentWidget,
                yesButtonText: yesButtonText,
                noButtonText: noButtonText,
                yesPressed: yesPressed,
                noPressed: noPressed,
              ),
            ));
    final Widget testWidgetBuild = MaterialApp(home: testWidget);

    testWidgets('dialog information is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.byWidget(titleText), findsOneWidget);
      expect(find.byWidget(yesButtonText), findsOneWidget);
      expect(find.byWidget(noButtonText), findsOneWidget);
      expect(find.byWidget(contentWidget), findsOneWidget);
    });

    testWidgets('yes pressed is called when yes clicked', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, yesButtonText.data!));

      verify(yesPressed.call());
    });

    testWidgets('yes pressed is called when yes clicked', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, noButtonText.data!));

      verify(noPressed.call());
    });
  });

  group('showUnlinkAlertDialog', () {
    const partnerName = 'PARTNER_NAME_TEST';
    const partnerLinkCode = 'PARTNER_LINK_CODE_TEST';

    late MockUserInfoState userInfoState;
    late MockPartnersInfoState partnersInfoState;
    late UnlinkAlertDialog unlinkAlertDialog;
    late Widget testWidget;
    late Widget testWidgetBuild;

    setUp(() {
      userInfoState = MockUserInfoState();
      partnersInfoState = MockPartnersInfoState();
      unlinkAlertDialog = UnlinkAlertDialog();
      testWidget = Builder(
          builder: (context) => MaterialButton(
                key: buttonKey,
                onPressed: () => unlinkAlertDialog.show(
                  context,
                  partnerName,
                  partnerLinkCode,
                ),
              ));
      testWidgetBuild = MaterialApp(
          home: MultiProvider(
        providers: [
          ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
          ChangeNotifierProvider<PartnersInfoState>.value(value: partnersInfoState),
        ],
        child: testWidget,
      ));
    });

    testWidgets('partner information is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.textContaining(partnerName), findsOneWidget);
      expect(find.textContaining(partnerLinkCode), findsOneWidget);
    });

    testWidgets('yes pressed calls unlink and closes dialog', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, UnlinkAlertDialog.yesButtonText));
      await tester.pumpAndSettle();

      verify(userInfoState.unlink());
      expect(find.textContaining(partnerName), findsNothing);
      expect(find.textContaining(partnerLinkCode), findsNothing);
    });

    testWidgets('unlink error is displayed', (WidgetTester tester) async {
      const String errorText = 'TEST_ERROR';
      when(userInfoState.unlink()).thenAnswer((realInvocation) async => throw PrintableError(errorText));
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, UnlinkAlertDialog.yesButtonText));
      await tester.pumpAndSettle();

      expect(find.textContaining(errorText), findsOneWidget);
    });

    testWidgets('no button closes dialog', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, UnlinkAlertDialog.noButtonText));
      await tester.pumpAndSettle();

      expect(find.textContaining(partnerName), findsNothing);
      expect(find.textContaining(partnerLinkCode), findsNothing);
    });
  });

  group('showDeleteAlertDialog', () {
    late MockUserInformation userInfo;
    late MockApplicationState appState;
    late MockUserInfoState userInfoState;
    late MockPartnersInfoState partnersInfoState;
    late MockFirebaseAuth auth;
    late MockAuthenticationInfo authInfo;
    late DeleteAlertDialog deleteAlertDialog;
    late Widget testWidget;
    late Widget testWidgetBuild;

    setUp(() {
      authInfo = MockAuthenticationInfo();
      auth = MockFirebaseAuth();
      userInfo = MockUserInformation();
      appState = MockApplicationState();
      userInfoState = MockUserInfoState();
      partnersInfoState = MockPartnersInfoState();
      deleteAlertDialog = DeleteAlertDialog(auth, authInfo);
      when(authInfo.providerConfigs).thenReturn([]);
      when(userInfoState.userInfo).thenReturn(userInfo);
      when(appState.authenticationInfo).thenReturn(authInfo);

      testWidget = Builder(
          builder: (context) => MaterialButton(
                key: buttonKey,
                onPressed: () => deleteAlertDialog.show(
                  context,
                ),
              ));
      testWidgetBuild = MultiProvider(
          providers: [
            ChangeNotifierProvider<ApplicationState>.value(value: appState),
            ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
            ChangeNotifierProvider<PartnersInfoState>.value(value: partnersInfoState),
          ],
          child: MaterialApp(
            home: testWidget,
          ));
    });

    testWidgets('dialog is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.text(DeleteAlertDialog.yesButtonText), findsOneWidget);
      expect(find.text(DeleteAlertDialog.noButtonText), findsOneWidget);
    });

    testWidgets('yes pressed calls delete user data and closes dialog', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, DeleteAlertDialog.yesButtonText));
      await tester.pumpAndSettle();

      verify(userInfo.deleteUserData(captureAny, captureAny, captureAny));
      expect(find.text(DeleteAlertDialog.yesButtonText), findsNothing);
      expect(find.text(DeleteAlertDialog.noButtonText), findsNothing);
    });

    testWidgets('delete error is displayed', (WidgetTester tester) async {
      const String errorText = 'TEST_ERROR';
      when(userInfo.deleteUserData(captureAny, captureAny, captureAny))
          .thenAnswer((realInvocation) async => throw PrintableError(errorText));
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, DeleteAlertDialog.yesButtonText));
      await tester.pumpAndSettle();

      expect(find.textContaining(errorText), findsOneWidget);
    });

    testWidgets('no button closes dialog', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, DeleteAlertDialog.noButtonText));
      await tester.pumpAndSettle();

      expect(find.text(DeleteAlertDialog.yesButtonText), findsNothing);
      expect(find.text(DeleteAlertDialog.noButtonText), findsNothing);
    });
  });
}
