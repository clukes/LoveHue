import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lovehue/main_emulated.dart' as app;
import 'package:lovehue/widgets/bar_sliders.dart';

import 'test_driver/utilities.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('test sign in and updating bars', (WidgetTester tester) async {
      await startUpApp(tester);
      await testAnonymousSignIn(tester, binding);
      await testUpdatingBars(tester, binding);
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
  expect(find.text('Sign in'), findsOneWidget);

  // Find and tap the "Skip login" button.
  final skipLoginButton = find.text('Skip Login');
  expect(skipLoginButton, findsOneWidget);

  await tester.tap(skipLoginButton);

  // Wait for Firebase to complete its asynchronous operations.
  await tester.pumpAndSettle();

  // Verify that an anonymous user is created and signed in.
  final currentUser = FirebaseAuth.instance.currentUser;
  expect(currentUser, isNotNull);
  expect(currentUser!.isAnonymous, isTrue);

  // Verify that "Your bars" is displayed on the screen.
  final yourBarsText = find.text('Your Bars');
  expect(yourBarsText, findsOneWidget);
  await takeScreenshot(tester, binding, "SkipLogin-LoggedIn");
}

Future testUpdatingBars(
    WidgetTester tester, IntegrationTestWidgetsFlutterBinding binding) async {
  // Get current user
  final user = FirebaseAuth.instance.currentUser;
  expect(user, isNotNull);
  final userId = user!.uid;

  // Get initial saved bars count
  final userBarsCollection = FirebaseFirestore.instance
      .collection('UserBars')
      .doc(userId)
      .collection('YourBars');
  final originalBarsCount =
      await userBarsCollection.count().get().then((snapshot) => snapshot.count);

  // Find a bar and update it.
  expect(find.text('Your Bars'), findsOneWidget);
  final barToUpdate = find.byType(InteractableBarSlider);
  expect(barToUpdate, findsAtLeastNWidgets(1));
  await tester.drag(barToUpdate.first, const Offset(20, 0));

  await tester.pumpAndSettle();

  // Find save button and tap it.
  final saveButton = find.byTooltip('Save');
  expect(saveButton, findsOneWidget);
  await tester.tap(saveButton);

  // Wait for Firebase to complete its asynchronous operations.
  await tester.pumpAndSettle();

  // Verify that updated bars are saved in database.
  final updatedBarsCount =
      await userBarsCollection.count().get().then((snapshot) => snapshot.count);
  expect(updatedBarsCount, greaterThan(originalBarsCount));
}
