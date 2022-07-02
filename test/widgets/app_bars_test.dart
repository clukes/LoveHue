import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/widgets/app_bars.dart';

void main() {
  const Text titleWidget = Text('Title Test', key: Key('Title'));
  const Size surfaceSize = Size(400, 400);
  const Widget testWidget = BarsPageAppBar(barTitleWidget: titleWidget);
  const Text findWidget = Text('Find this', key: Key('FIND'));

  final Widget testWidgetBuild = MaterialApp(
      home: Scaffold(
          primary: false,
          body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  testWidget,
                ];
              },
              body: ListView(
                  children: List<Widget>.generate(100, (i) => ListTile(key: Key('$i'), title: Text("Item $i"))) +
                      [(const ListTile(title: findWidget))]))));

  testWidgets('displays barTitleWidget', (WidgetTester tester) async {
    await tester.pumpWidget(testWidgetBuild);
    expect(find.byWidget(titleWidget), findsOneWidget);
  });

  testWidgets('disappears on scroll', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(testWidgetBuild);
    expect(find.byWidget(testWidget), findsOneWidget);

    await tester.scrollUntilVisible(find.byWidget(findWidget), surfaceSize.height / 2,
        scrollable: find.byType(Scrollable).last);
    expect(find.byWidget(testWidget), findsNothing);
  });
}
