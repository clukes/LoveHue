import 'package:flutter/material.dart';

import 'colors.dart';
import 'custom_shapes.dart';

final ThemeData themeData = ThemeData.light().copyWith(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: mobileBackgroundColor,
  brightness: Brightness.light,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  sliderTheme: const SliderThemeData(
    trackHeight: 30.0,
    // activeTrackColor: Colors.green,
    // inactiveTrackColor: Colors.green[800],
    // disabledActiveTrackColor: primaryColorDark.withAlpha(disabledActiveTrackAlpha),
    // disabledInactiveTrackColor: primaryColorDark.withAlpha(disabledInactiveTrackAlpha),
    // activeTickMarkColor: primaryColorLyight.withAlpha(activeTickMarkAlpha),
    // inactiveTickMarkColor: primaryColor.withAlpha(inactiveTickMarkAlpha),
    // disabledActiveTickMarkColor: primaryColorLight.withAlpha(disabledActiveTickMarkAlpha),
    // disabledInactiveTickMarkColor: primaryColorDark.withAlpha(disabledInactiveTickMarkAlpha),
    thumbColor: null,
    // overlappingShapeStrokeColor: Colors.white,
    // disabledThumbColor: primaryColorDark.withAlpha(disabledThumbAlpha),
    // overlayColor: primaryColor.withAlpha(overlayAlpha),
    // valueIndicatorColor: primaryColor.withAlpha(valueIndicatorAlpha),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
    tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0),
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0, elevation: 0, pressedElevation: 0),
    trackShape: CustomRoundedSliderTrackShape(),
    // valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
    // rangeTickMarkShape: const RoundRangeSliderTickMarkShape(),
    // rangeThumbShape: const RoundRangeSliderThumbShape(),
    // rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
    // rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
    // valueIndicatorTextStyle: valueIndicatorTextStyle,
    // showValueIndicator: ShowValueIndicator.onlyForDiscrete,
  ),
  appBarTheme: const AppBarTheme(
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(10, 5), bottomRight: Radius.elliptical(10, 5))),
    backgroundColor: mobileBackgroundColor,
    foregroundColor: darkTextColor,
  ),
  listTileTheme: const ListTileThemeData(),
  dividerTheme: const DividerThemeData(),
);