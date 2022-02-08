import 'package:flutter/material.dart';

import 'colors.dart';

final ThemeData themeData = ThemeData.light().copyWith(
    scaffoldBackgroundColor: mobileBackgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 30.0,
      activeTrackColor: Colors.green,
      inactiveTrackColor: Colors.green[800],
      // disabledActiveTrackColor: primaryColorDark.withAlpha(disabledActiveTrackAlpha),
      // disabledInactiveTrackColor: primaryColorDark.withAlpha(disabledInactiveTrackAlpha),
      // activeTickMarkColor: primaryColorLight.withAlpha(activeTickMarkAlpha),
      // inactiveTickMarkColor: primaryColor.withAlpha(inactiveTickMarkAlpha),
      // disabledActiveTickMarkColor: primaryColorLight.withAlpha(disabledActiveTickMarkAlpha),
      // disabledInactiveTickMarkColor: primaryColorDark.withAlpha(disabledInactiveTickMarkAlpha),
      thumbColor: null,
      // overlappingShapeStrokeColor: Colors.white,
      // disabledThumbColor: primaryColorDark.withAlpha(disabledThumbAlpha),
      // overlayColor: primaryColor.withAlpha(overlayAlpha),
      // valueIndicatorColor: primaryColor.withAlpha(valueIndicatorAlpha),
      overlayShape: const RoundSliderOverlayShape(),
      tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0, elevation: 0),
      trackShape: RectangularSliderTrackShape(),
      // valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      // rangeTickMarkShape: const RoundRangeSliderTickMarkShape(),
      // rangeThumbShape: const RoundRangeSliderThumbShape(),
      // rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
      // rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
      // valueIndicatorTextStyle: valueIndicatorTextStyle,
      // showValueIndicator: ShowValueIndicator.onlyForDiscrete,
    ),
  cardTheme: const CardTheme(
    clipBehavior: Clip.none,
    color: Color.fromRGBO(0, 0, 0, 0),
    shadowColor: Color.fromRGBO(0, 0, 0, 0),
    margin: EdgeInsets.zero,
  ),
  appBarTheme: const AppBarTheme(
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(10, 5), bottomRight: Radius.elliptical(10, 5))),
  ),
);
