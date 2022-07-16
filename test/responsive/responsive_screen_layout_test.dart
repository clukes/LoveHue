import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/responsive/mobile_screen_layout.dart';
import 'package:lovehue/responsive/responsive_screen_layout.dart';
import 'package:lovehue/responsive/web_screen_layout.dart';
import 'package:lovehue/utils/globals.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

void main() {
  late WebScreenLayout webScreenLayout;
  late MobileScreenLayout mobileScreenLayout;
  late ResponsiveLayout testWidget;
  late MaterialApp testWidgetBuild;

  setUp(() {
    var appState = MockApplicationState();
    var userInfoState = MockUserInfoState();

    webScreenLayout = const WebScreenLayout();
    mobileScreenLayout = const MobileScreenLayout();
    testWidget = ResponsiveLayout(
        webScreenLayout: webScreenLayout,
        mobileScreenLayout: mobileScreenLayout);
    testWidgetBuild = MaterialApp(
        home: MultiProvider(
      providers: [
        ChangeNotifierProvider<ApplicationState>.value(value: appState),
        ChangeNotifierProvider<UserInfoState>.value(value: userInfoState),
      ],
      child: testWidget,
    ));
    when(appState.loginState).thenReturn(ApplicationLoginState.loading);
  });

  testWidgets('greater than webScreenSize displays web screen layout',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size.square(webScreenWidth + 1));
    await tester.pumpWidget(testWidgetBuild);
    expect(find.byWidget(webScreenLayout), findsOneWidget);
  });

  testWidgets('equal to webScreenSize displays web screen layout',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size.square(webScreenWidth + 0));
    await tester.pumpWidget(testWidgetBuild);
    expect(find.byWidget(webScreenLayout), findsOneWidget);
  });

  testWidgets('less than webScreenSize displays mobile screen layout',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size.square(webScreenWidth - 1));
    await tester.pumpWidget(testWidgetBuild);
    expect(find.byWidget(mobileScreenLayout), findsOneWidget);
  });
}
