import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/widgets/buttons.dart';
import 'package:mockito/mockito.dart';

import '../mocker.dart';

void main() {
  const findText = 'FIND_THIS_TEST';
  const child = Text(findText);

  late MockFunction onPressed;
  late Widget testWidget;
  late Widget testWidgetBuild;

  setUp(() {
    onPressed = MockFunction();
    testWidget = StyledButton(child: child, onPressed: onPressed);
    testWidgetBuild = MaterialApp(home: testWidget);
  });

  group('StyledButton', () {
    testWidgets('child displayed and calls onPressed function when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);

      await tester.tap(find.byWidget(testWidget));
      await tester.pumpAndSettle();

      expect(find.byWidget(child), findsOneWidget);
      expect(find.text(findText), findsOneWidget);
      verify(onPressed.call());
    });
  });
}
