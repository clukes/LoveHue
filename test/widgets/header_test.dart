import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/widgets/header.dart';

void main() {
  const heading = 'HEADING_TEST';
  const fontSize = 10.0;
  const Header testWidget = Header(heading: heading, fontSize: fontSize);
  const Widget testWidgetBuild = MaterialApp(home: testWidget);

  testWidgets('heading is displayed with font size', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    expect(find.text(heading), findsOneWidget);
    Text headingWidget = tester.widget(find.text(heading));
    expect(headingWidget.style!.fontSize, moreOrLessEquals(fontSize));
  });
}
