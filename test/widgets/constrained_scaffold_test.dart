import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/widgets/constrained_scaffold.dart';

void main() {
  const maxWidth = 500.0;
  const Text titleWidget = Text('TITLE_TEST', key: Key('TITLE'));
  const Text contentWidget = Text('CONTENT_TEST', key: Key('CONTENT'));
  const ConstrainedScaffold testWidget = ConstrainedScaffold(
    title: titleWidget,
    content: contentWidget,
    maxScaffoldWidth: maxWidth,
  );
  const Widget testWidgetBuild = MaterialApp(home: testWidget);

  testWidgets('displays title and content', (WidgetTester tester) async {
    const screenSize = Size(maxWidth - 100, 400);

    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(testWidgetBuild);
    expect(find.byWidget(titleWidget), findsOneWidget);
    expect(find.byWidget(contentWidget), findsOneWidget);

    final contentWidth = tester.getSize(find.byWidget(contentWidget)).width;
    expect(contentWidth, lessThan(maxWidth));
  });

  testWidgets('content is constrained on larger width screen', (WidgetTester tester) async {
    const screenSize = Size(maxWidth + 500, 400);

    final SizedBox contentWidget = SizedBox.fromSize(size: screenSize);

    final ConstrainedScaffold testWidget = ConstrainedScaffold(
      title: titleWidget,
      content: contentWidget,
    );
    final Widget testWidgetBuild = MaterialApp(home: testWidget);

    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(testWidgetBuild);

    final contentWidth = tester.getSize(find.byWidget(contentWidget)).width;
    expect(contentWidth, moreOrLessEquals(maxWidth));
  });
}
