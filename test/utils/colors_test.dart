//TODO: getSliderColor test

import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/utils/colors.dart';

void main() {
  test('slider colors map correctly', () {
    SliderColor? color = getSliderColor(0);
    expect(color, equals(sliderColors[0]));

    for (int i = 0; i <= 4; i++) {
      // Get 1, 21, 41, 61, 81
      int value = (i * 20) + 1;
      SliderColor? color = getSliderColor(value);
      expect(color, equals(sliderColors[i]));

      // Get 20, 40, 60, 80, 100
      value += 19;
      color = getSliderColor(value);
      expect(color, equals(sliderColors[i]));
    }
  });

  test('out of bounds colors return nothing', () {
    SliderColor? color = getSliderColor(-1);
    expect(color, isNull);

    color = getSliderColor(101);
    expect(color, isNull);

    color = getSliderColor(500);
    expect(color, isNull);
  });
}
