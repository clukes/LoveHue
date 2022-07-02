import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/pages/link_partner_screen.dart';
import 'package:lovehue/providers/partners_info_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.dart';
import '../mocker.mocks.dart';

//TODO: next do LinkPartnerForm
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
            value: partnersInfoState),
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
}
