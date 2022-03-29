import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/relationship_bar.dart';
import 'package:lovehue/providers/user_info_state.dart';
import 'package:lovehue/utils/colors.dart';
import 'package:lovehue/widgets/bar_sliders.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocker.mocks.dart';

void main() {
  late MockUserInfoState userInfoState;
  late RelationshipBar bar;

  setUp(() {
    userInfoState = MockUserInfoState();
    when(userInfoState.barsReset).thenReturn(false);
    bar = RelationshipBar(order: 1, label: 'TEST_LABEL', value: 75, prevValue: 20);
  });

  group('InteractableBarSlider', () {
    late Widget testWidget;
    late Widget testWidgetBuild;

    setUp(() {
      testWidget = InteractableBarSlider(
        relationshipBar: bar,
      );
      testWidgetBuild =
          MaterialApp(home: ChangeNotifierProvider<UserInfoState>.value(value: userInfoState, child: testWidget));
    });

    testWidgets('bar information is displayed correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      expect(find.textContaining(bar.label), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      Slider slider = tester.widget(find.byType(Slider));
      SliderTheme theme = tester.widget(find.byType(SliderTheme));
      expect(slider.value, equals(bar.value));
      expect(theme.data.activeTrackColor, equals(getSliderColor(bar.value)?.active));
    });

    testWidgets('slider value updates on change', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      int originalValue = bar.value;

      Slider slider = tester.widget(find.byType(Slider));
      expect(slider.value, equals(originalValue));

      await tester.drag(find.byType(Slider), const Offset(-100.0, 0.0));
      await tester.pumpAndSettle();

      slider = tester.widget(find.byType(Slider));
      await expectLater(slider.value, isNot(originalValue));
    });

    testWidgets('bar value updates on change end', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      int originalValue = bar.value;

      Slider slider = tester.widget(find.byType(Slider));
      expect(slider.value, equals(originalValue));

      await tester.drag(find.byType(Slider), const Offset(-100.0, 0.0));
      await tester.pumpAndSettle();

      await expectLater(bar.value, isNot(originalValue));
    });

    testWidgets('sets bar to previous value on undo button press', (WidgetTester tester) async {
      bar.changed = true;

      await tester.pumpWidget(testWidgetBuild);

      Slider slider = tester.widget(find.byType(Slider));
      expect(slider.value, equals(bar.value));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.replay));
      await tester.pumpAndSettle();

      slider = tester.widget(find.byType(Slider));
      await expectLater(slider.value, equals(bar.prevValue));
      await expectLater(bar.value, equals(bar.prevValue));
    });
  });

  group('NonInteractableBarSlider', () {
    late Widget testWidget;
    late Widget testWidgetBuild;

    setUp(() {
      testWidget = NonInteractableBarSlider(relationshipBar: bar);
      testWidgetBuild =
          MaterialApp(home: ChangeNotifierProvider<UserInfoState>.value(value: userInfoState, child: testWidget));
    });

    testWidgets('bar information is displayed correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      expect(find.textContaining(bar.label), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      Slider slider = tester.widget(find.byType(Slider));
      SliderTheme theme = tester.widget(find.byType(SliderTheme));
      expect(slider.value, equals(bar.value));
      expect(theme.data.activeTrackColor, equals(getSliderColor(bar.value)?.active));
    });

    testWidgets("slider value doesn't update on change", (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      int originalValue = bar.value;

      Slider slider = tester.widget(find.byType(Slider));
      expect(slider.value, equals(originalValue));

      await tester.drag(find.byType(Slider), const Offset(-100.0, 0.0));
      await tester.pumpAndSettle();

      slider = tester.widget(find.byType(Slider));
      await expectLater(slider.value, equals(originalValue));
    });

    testWidgets("slider value doesn't update on change end", (WidgetTester tester) async {
      await tester.pumpWidget(testWidgetBuild);
      int originalValue = bar.value;

      Slider slider = tester.widget(find.byType(Slider));
      expect(slider.value, equals(originalValue));

      await tester.drag(find.byType(Slider), const Offset(-100.0, 0.0));
      await tester.pumpAndSettle();

      await expectLater(bar.value, equals(originalValue));
    });
  });
}
