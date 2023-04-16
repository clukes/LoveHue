import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lovehue/main_emulated.dart' as app;

import 'test_driver/utilities.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tapping on skip login will sign in anonymously',
        (tester) async {
      await app.main();
      await tester.pumpAndSettle();
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
    });
  });
}
