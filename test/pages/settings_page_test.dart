import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/pages/settings_page.dart';
import 'package:lovehue/providers/application_state.dart';
import 'package:lovehue/utils/app_info_class.dart';
import 'package:lovehue/widgets/profile_page_widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

void main() {
  const appName = 'TEST_APP_NAME';
  const aboutText = 'TEST_ABOUT';
  const version = 'VERSION_TEST';
  const AppInfo appInfo = AppInfo(
    appName: appName,
    aboutText: aboutText,
  );

  final PackageInfo packageInfo = PackageInfo(
    buildNumber: '',
    packageName: appName,
    appName: appName,
    version: version,
  );

  late MockApplicationState appState;
  late MockAuthenticationInfo authenticationInfo;
  late MockNotificationService mockNotificationService;
  late Widget testWidget;
  late Widget testWidgetBuild;

  setUp(() {
    appState = MockApplicationState();
    authenticationInfo = MockAuthenticationInfo();
    mockNotificationService = MockNotificationService();
    testWidget = const SettingsPage();
    testWidgetBuild = MaterialApp(
        home: MultiProvider(
      providers: [
        ChangeNotifierProvider<ApplicationState>.value(value: appState),
      ],
      child: testWidget,
    ));
    when(appState.appInfo).thenReturn(appInfo);
    when(appState.authenticationInfo).thenReturn(authenticationInfo);
    when(authenticationInfo.packageInfo).thenReturn(packageInfo);
    when(appState.auth).thenReturn(MockFirebaseAuth());
    when(appState.notificationService).thenReturn(mockNotificationService);
    when(mockNotificationService.notificationDocumentPath(any))
        .thenReturn("nudge/12345");
  });

  testWidgets('displays settings page', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('displays about app dialog', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    await tester.tap(find.text('About this app'));
    await tester.pumpAndSettle();
    expect(find.text(appName), findsOneWidget);
    expect(find.text(aboutText), findsOneWidget);
    expect(find.text(version), findsOneWidget);
  });

  testWidgets('displays delete dialog', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text(DeleteAlertDialog.yesButtonText), findsOneWidget);
    expect(find.text(DeleteAlertDialog.noButtonText), findsOneWidget);
  });
}
