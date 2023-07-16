import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lovehue/main_emulated.dart' as app;
import 'package:lovehue/widgets/bar_sliders.dart';

import 'test_driver/utilities.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('test sign in and updating bars', (WidgetTester tester) async {
      debugPrint("Starting app...");
      await startUpApp(tester);
      debugPrint("Testing anonymous sign in...");
      await testAnonymousSignIn(tester, binding);
      debugPrint("Testing updating bars...");
      await testUpdatingBars(tester, binding);
      debugPrint("Tests completed.");
    });
  });
}

Future<bool> waitForEmulator(
    WidgetTester tester, int retryCount, int delaySeconds) async {
  for (int i = 0; i < retryCount; i++) {
    try {
      await FirebaseAuth.instance.fetchSignInMethodsForEmail("test@test.com");
      return true;
    } on FirebaseAuthException catch (ex) {
      tester.printToConsole(
          "Emulator connection failed, retrying... attempt $i (Error: ${ex.message})");
      await Future.delayed(Duration(seconds: delaySeconds));
    }
  }
  return false;
}

Future startUpApp(WidgetTester tester) async {
  await app.main();
  await tester.pumpAndSettle();

  var emulatorLoaded = await waitForEmulator(tester, 10, 3);
  expect(emulatorLoaded, isTrue, reason: "Failure: Emulator wasn't ready");
}

Future testAnonymousSignIn(
    WidgetTester tester, IntegrationTestWidgetsFlutterBinding binding) async {
  expect(find.text('Sign in'), findsOneWidget, reason: "No sign in button");

  // Find and tap the "Skip login" button.
  final skipLoginButton = find.text('Skip Login');
  expect(skipLoginButton, findsOneWidget, reason: "No skip login button");

  await tester.tap(skipLoginButton);

  // Wait for Firebase to complete its asynchronous operations.
  await tester.pumpAndSettle();

  // Verify that an anonymous user is created and signed in.
  final currentUser = FirebaseAuth.instance.currentUser;
  expect(currentUser, isNotNull, reason: "User not signed in");
  expect(currentUser!.isAnonymous, isTrue, reason: "User was not anonymous");

  // Verify that "Your bars" is displayed on the screen.
  final yourBarsText = find.text('Your Bars');
  expect(yourBarsText, findsOneWidget, reason: "Your Bars title not found");
  await takeScreenshot(tester, binding, "SkipLogin-LoggedIn");
}

Future testUpdatingBars(
    WidgetTester tester, IntegrationTestWidgetsFlutterBinding binding) async {
  // Get current user
  final user = FirebaseAuth.instance.currentUser;
  expect(user, isNotNull, reason: "No user signed in");
  final userId = user!.uid;

  // Get initial saved bars count
  final userBarsCollection = FirebaseFirestore.instance
      .collection('UserBars')
      .doc(userId)
      .collection('YourBars');
  final originalBarsCount =
      await userBarsCollection.count().get().then((snapshot) => snapshot.count);

  // Find a bar and update it.
  expect(find.text('Your Bars'), findsOneWidget,
      reason: "Your bars title not found");
  final bars = find.byType(InteractableBarSlider);
  expect(bars, findsAtLeastNWidgets(1), reason: "No user bars found");
  final barToUpdate =
      find.descendant(of: bars.first, matching: find.byType(Slider));
  await tester.drag(barToUpdate, const Offset(20, 0));

  await tester.pumpAndSettle();

  // Find save button and tap it.
  final saveButton = find.byTooltip('Save');
  expect(saveButton, findsOneWidget, reason: "Save button not found");
  await tester.tap(saveButton);

  // Wait for Firebase to complete its asynchronous operations.
  await tester.pumpAndSettle();

  // Verify that updated bars are saved in database.
  final updatedBarsCount =
      await userBarsCollection.count().get().then((snapshot) => snapshot.count);
  expect(updatedBarsCount, greaterThan(originalBarsCount),
      reason: "Count of bars docs did not increase");
}
