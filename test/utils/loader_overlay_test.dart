import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lovehue/utils/loader_overlay.dart';
import 'package:mockito/mockito.dart';

import '../mocker.mocks.dart';

void main() {
  group('withLoaderOverlay', () {
    late BuildContext mockBuildContext;
    late OverlayControllerWidget mockOverlayControllerWidget;

    setUp(() {
      mockBuildContext = MockBuildContext();
      mockOverlayControllerWidget = MockOverlayControllerWidget();
      when(mockBuildContext.findAncestorWidgetOfExactType())
          .thenReturn(mockOverlayControllerWidget);
      when(mockBuildContext.mounted).thenReturn(true);
    });

    test('shows and hides loaderOverlay', () async {
      //act
      await withLoaderOverlay(
          () => expectLater(mockBuildContext.loaderOverlay.visible, isTrue),
          currentContext: mockBuildContext);

      expect(mockBuildContext.loaderOverlay.visible, isFalse);
    });

    test('rethrows error, and hides loaderOverlay', () async {
      Exception expectedException = Exception("expected");

      //act
      act() => withLoaderOverlay(() => throw expectedException,
          currentContext: mockBuildContext);

      await expectLater(act, throwsA(expectedException));

      expect(mockBuildContext.loaderOverlay.visible, isFalse);
    });

    test('returns task result', () async {
      var expectedResult = 10;
      //act
      var result = await withLoaderOverlay(() => Future.value(expectedResult),
          currentContext: mockBuildContext);

      expect(result, equals(expectedResult));
    });
  });
}
