import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'custom_shapes.dart';

final ThemeData themeData = ThemeData.light().copyWith(
  primaryColor: primaryColor,
  backgroundColor: mobileBackgroundColor,
  scaffoldBackgroundColor: mobileBackgroundColor,
  brightness: Brightness.light,
  textTheme: textTheme,
  appBarTheme: const AppBarTheme(
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(10, 5), bottomRight: Radius.elliptical(10, 5))),
    backgroundColor: Colors.transparent,
    foregroundColor: primaryTextColor,
    elevation: 0.0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: navigationBackgroundColor,
    selectedItemColor: activeNavigationColor,
    unselectedItemColor: inactiveNavigationColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  cardTheme: const CardTheme(
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
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
    overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
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
);

final TextTheme dmSansTextTheme = GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme.copyWith(
  headline6: TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: primaryTextColor),
  subtitle1: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: primaryTextColor),
));

//Allows for other fonts
final TextTheme textTheme = dmSansTextTheme.copyWith(
  subtitle2: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 16, color: secondaryTextColor),
);